#!/usr/bin/env bash
# Render the pictures in docs/img/ (OpenSCAD preview, 1600 x 1200, about a minute).
#
# Usage:  tools/render_images.sh
#         OPENSCAD=/path/to/openscad tools/render_images.sh
# frame_print.png and print_set.png show the files in stl/: run tools/export_all.sh first if you changed the model.

# OpenSCAD executable (see export_all.sh for examples)
OPENSCAD="${OPENSCAD:-openscad}"

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL="$ROOT/model/beamsplitter_rig.scad"
IMG="$ROOT/docs/img"
LOGS="$ROOT/out/logs"

command -v "$OPENSCAD" >/dev/null 2>&1 || { echo "OpenSCAD not found: $OPENSCAD (set OPENSCAD=...)" >&2; exit 1; }

# A Windows OpenSCAD called from WSL needs Windows paths.
winpath() {
  case "$OPENSCAD" in
    *.exe|*.com) command -v wslpath >/dev/null 2>&1 && { wslpath -w "$1"; return; } ;;
  esac
  printf '%s\n' "$1"
}

# render <png> <scad> <camera> [OpenSCAD arguments]
# camera: centre x,y,z, rotation x,y,z, distance (OpenSCAD's --camera; the GUI shows the current view at the bottom)
render() {
  local png=$1 scad=$2 cam=$3; shift 3
  if "$OPENSCAD" -o "$(winpath "$IMG/$png")" --preview --imgsize=1600,1200 --colorscheme=Tomorrow \
       --camera="$cam" "$@" "$(winpath "$scad")" >"$LOGS/${png%.png}.log" 2>&1; then
    echo "ok    $png"
  else
    echo "FAIL  $png (see $LOGS/${png%.png}.log)"; return 1
  fi
}

mkdir -p "$IMG" "$LOGS"
SET="$ROOT/tools/print_set.scad"
pids=()
render assembly.png       "$MODEL" 0,40,105,64,0,325,1000 -D 'show_fov=false' & pids+=($!)
render cutaway.png        "$MODEL" -7,21,120,64,0,40,820 -D 'show_fov=false' -D 'cutaway=true' -D 'show_lid=false' & pids+=($!)
render groove_section.png "$ROOT/tools/groove_section.scad" 60,5.5,0,0,0,0,124 --projection=o & pids+=($!)
render frame_print.png    "$SET" 0,52,100,64,0,325,1000 -D 'show="01_frame"' & pids+=($!)
fail=0
for p in "${pids[@]}"; do wait "$p" || fail=1; done
render print_set.png      "$SET" 0,-215,20,46,0,4,1500 || fail=1
exit $fail
