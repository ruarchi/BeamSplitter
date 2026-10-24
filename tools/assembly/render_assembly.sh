#!/usr/bin/env bash
# Render the assembly-guide pictures (docs/img/assembly/NN_name.png) from the scenes in tools/assembly/NN_name.scad.
# OpenSCAD preview, 1400 x 1050, a few seconds to a minute each.
# Each --camera must match CAM / the "Camera:" line in its scene (labels are placed for it).
#
# Usage:  tools/assembly/render_assembly.sh
#         OPENSCAD=/path/to/openscad tools/assembly/render_assembly.sh
# A Windows OpenSCAD can be called from WSL: set OPENSCAD to openscad.com in the OpenSCAD install folder (as a WSL path).

OPENSCAD="${OPENSCAD:-openscad}"

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT" || exit 1
mkdir -p docs/img/assembly
command -v "$OPENSCAD" >/dev/null 2>&1 || { echo "OpenSCAD not found: $OPENSCAD (set OPENSCAD=...)" >&2; exit 1; }

# A Windows OpenSCAD called from WSL needs Windows paths.
winpath() {
  case "$OPENSCAD" in
    *.exe|*.com) command -v wslpath >/dev/null 2>&1 && { wslpath -w "$1"; return; } ;;
  esac
  printf '%s\n' "$1"
}

"$OPENSCAD" -o "$(winpath docs/img/assembly/01_parts.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-36,22,165,62,0,300,1700 "$(winpath tools/assembly/01_parts.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/02_hardware_and_bought.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --projection=ortho --camera=130,-96,0,38,0,0,690 "$(winpath tools/assembly/02_hardware_and_bought.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/03_clean_prints.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=76,10,182,105,0,285,330 "$(winpath tools/assembly/03_clean_prints.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/04_paint_and_flock.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-125,30,150,50,0,205,1080 "$(winpath tools/assembly/04_paint_and_flock.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/05_chase_threads.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-103,-17,150,50,0,205,1150 "$(winpath tools/assembly/05_chase_threads.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/06_tripod_insert.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=20,60,100,70,0,138,640 "$(winpath tools/assembly/06_tripod_insert.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/07_crosswall_pins_nuts.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,70,85,58,0,345,680 "$(winpath tools/assembly/07_crosswall_pins_nuts.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/08_wall_rail.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=38,18,70,65,0,330,780 "$(winpath tools/assembly/08_wall_rail.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/09_tbolts_in_carriages.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-5,-10,15,50,0,330,620 "$(winpath tools/assembly/09_tbolts_in_carriages.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/10_rear_carriage.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=10,135,155,50,0,225,600 "$(winpath tools/assembly/10_rear_carriage.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/11_bottom_carriage.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-30,0,72,68,0,30,560 "$(winpath tools/assembly/11_bottom_carriage.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/12_f38_bases.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,0,15,55,0,160,600 "$(winpath tools/assembly/12_f38_bases.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/13_rear_slide.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,140,130,45,0,215,420 "$(winpath tools/assembly/13_rear_slide.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/14_bottom_slide.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-20,10,72,70,0,35,450 "$(winpath tools/assembly/14_bottom_slide.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/15_strip_felt.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,0,-37,62,0,20,450 "$(winpath tools/assembly/15_strip_felt.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/16_strips_in.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=80,-62,230,58,0,292,340 "$(winpath tools/assembly/16_strips_in.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/17_strip_check.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=78,2,176,62,0,280,270 "$(winpath tools/assembly/17_strip_check.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/18_roof_felt.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=77,6,174,62,0,280,195 "$(winpath tools/assembly/18_roof_felt.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/19_glass_in.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,-30,195,99,0,310,800 "$(winpath tools/assembly/19_glass_in.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/20_glass_thumbscrews.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,20,208,50,0,200,760 "$(winpath tools/assembly/20_glass_thumbscrews.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/21_glass_stops.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,-45,232,64,0,345,600 "$(winpath tools/assembly/21_glass_stops.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/22_lid.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=10,-10,258,55,0,330,880 "$(winpath tools/assembly/22_lid.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/23_camera_prep.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,45,195,75,0,290,800 "$(winpath tools/assembly/23_camera_prep.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/24_cameras_in.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-95,20,115,62,0,295,1080 "$(winpath tools/assembly/24_cameras_in.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/25_camera_heights.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,40,120,85,0,270,800 "$(winpath tools/assembly/25_camera_heights.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/26_viewpoint.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=0,40,120,85,0,270,800 "$(winpath tools/assembly/26_viewpoint.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/27_side_wrap.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-95,50,120,75,0,300,850 "$(winpath tools/assembly/27_side_wrap.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/28_stereo.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=-52,90,110,55,0,330,1000 "$(winpath tools/assembly/28_stereo.scad)"
"$OPENSCAD" -o "$(winpath docs/img/assembly/29_service_strips.png)" --preview --imgsize=1400,1050 --colorscheme=Tomorrow --camera=70,-60,232,55,0,320,400 "$(winpath tools/assembly/29_service_strips.scad)"
