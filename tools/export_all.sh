#!/usr/bin/env bash
# Export the complete print set (stl/, stl/tests/, stl/alternatives/) from the model and convert it to binary STL.
#
# Usage:  tools/export_all.sh [extra OpenSCAD arguments]
#   tools/export_all.sh                              # default values
#   tools/export_all.sh -D 'ps_clear=0.3'            # every part with your thread_test result
#   OPENSCAD=/path/to/openscad JOBS=2 tools/export_all.sh
#
# Needs bash, OpenSCAD and Python 3 (standard library only).  The full set takes about 10-20 minutes;
# the frames take longest.  Console logs go to out/logs/.

# OpenSCAD executable.  Examples:
#   Linux:          openscad
#   macOS:          /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
#   Windows (WSL):  openscad.com from the OpenSCAD install folder, as a WSL path
OPENSCAD="${OPENSCAD:-openscad}"
PYTHON="${PYTHON:-python3}"
JOBS="${JOBS:-4}"                      # parallel renders (each one uses one CPU core and up to about 2 GB RAM)

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL="$ROOT/model/beamsplitter_rig.scad"
OUT="$ROOT/stl"
LOGS="$ROOT/out/logs"
EXTRA=("$@")

# file (relative to stl/)  part  [more OpenSCAD assignments]
PARTS=(
  "01_frame.stl                       frame"
  "02_top_lid.stl                     top_lid"
  "03_wall_rail.stl                   wall_rail"
  "04_rear_carriage.stl               rear_carriage"
  "05_bottom_carriage.stl             bottom_carriage"
  "06_f38_slides_x2.stl               f38_slide"
  "07_glass_stops_x2.stl              glass_stop"
  "08_groove_strips_x2.stl            groove_strip"
  "09_shim_set_print_2x.stl           shim_set"
  "10_swap_shim_3mm_riser.stl         swap_shim"
  "11_hardware_screws_solid.stl       hardware_screws"
  "12_hardware_nuts_solid.stl         hardware_nuts"
  "13_glass_thumbscrews_solid.stl     preload_screw"
  "14_pins_solid.stl                  pin_set"
  "15_wrap_clips.stl                  wrap_clips"
  "tests/groove_test.stl              groove_test"
  "tests/thread_test.stl              thread_test"
  "tests/pin_test.stl                 pin_test"
  "tests/rail_test.stl                rail_test"
  "alternatives/frame_tripod_printed.stl  frame       tripod_mount=\"printed\""
  "alternatives/frame_tripod_arca.stl     frame       tripod_mount=\"arca\""
  "alternatives/frame_for_0.6_nozzle.stl  frame       ps_clear=0.3"
  "alternatives/arca_plate.stl            arca_plate  tripod_mount=\"arca\""
)

command -v "$OPENSCAD" >/dev/null 2>&1 || { echo "OpenSCAD not found: $OPENSCAD (set OPENSCAD=...)" >&2; exit 1; }

# A Windows OpenSCAD called from WSL needs Windows paths.
winpath() {
  case "$OPENSCAD" in
    *.exe|*.com) command -v wslpath >/dev/null 2>&1 && { wslpath -w "$1"; return; } ;;
  esac
  printf '%s\n' "$1"
}

export_one() {
  local file=$1 part=$2; shift 2
  local name=${file%.stl}; local log="$LOGS/${name//\//_}.log"
  local args=(-o "$(winpath "$OUT/$file")" -D "part=\"$part\"")
  local d
  for d in "$@"; do args+=(-D "$d"); done
  local t0=$SECONDS
  if "$OPENSCAD" "${args[@]}" ${EXTRA[@]+"${EXTRA[@]}"} "$(winpath "$MODEL")" >"$log" 2>&1 \
     && [ -s "$OUT/$file" ] \
     && "$PYTHON" "$ROOT/tools/stl_ascii_to_binary.py" "$OUT/$file" >>"$log" 2>&1; then
    local w; w=$(grep -c "WARNING" "$log")
    printf 'ok    %-40s %4ds  %s warning(s)\n' "$file" $((SECONDS - t0)) "$w"
  else
    printf 'FAIL  %-40s see %s\n' "$file" "$log"
    return 1
  fi
}

mkdir -p "$OUT/tests" "$OUT/alternatives" "$LOGS"
pids=()
for entry in "${PARTS[@]}"; do
  read -r -a f <<<"$entry"
  while [ "$(jobs -rp | wc -l)" -ge "$JOBS" ]; do sleep 1; done
  export_one "${f[@]}" &
  pids+=($!)
done
fail=0
for p in "${pids[@]}"; do wait "$p" || fail=$((fail + 1)); done

big=$(find "$OUT" -name '*.stl' -size +25M)
[ -n "$big" ] && printf 'Larger than 25 MB (consider a coarser $fn):\n%s\n' "$big"
if [ "$fail" -gt 0 ]; then echo "$fail export(s) failed." >&2; exit 1; fi
echo "All ${#PARTS[@]} files exported to $OUT"
