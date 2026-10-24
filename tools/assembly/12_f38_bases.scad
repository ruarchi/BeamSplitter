// Step 12: F38 bases onto the slides, on the bench (docs/ASSEMBLY.md).  Both slides top face up; F38 pins (orange)
// above their holes, the F38 base (dark red, release-lever nub toward the camera) above them, the steel 1/4"-20 screw
// below.  Seen from behind the slides (local +y toward the camera) so the lever nub shows.
// Camera (the labels are placed for it): --camera=0,0,15,55,0,160,600
include <scene_lib.scad>

R = [55, 160];                       // label rotation = camera rx, rz
PZ = 18;  BZ = 45;  SZ = -35;        // explode: pins up, base up, screw down
X = [["rear", 58], ["bottom", -58]]; // the rear slide on the left of the picture (camera behind: +X is on the left)

for (c = X) translate([c[1], 0, 0]) {
    done() slide_local(c[0]);
    new1() f38_pins_local(dz = PZ);
    translate([0, 0, t_slide + BZ]) f38_base_box();
    f38_screw_local(dz = SZ);
    // arrows: pins down, base down, screw up
    for (s = [-1, 1]) arrow([s * f38_pin_sp / 2, 0, t_slide + PZ - 3], [s * f38_pin_sp / 2, 0, t_slide + 1], d = 1.5);
    for (s = [-1, 1]) arrow([s * 14, 0, t_slide + BZ + f38_stack - F38_PLATE_H + 22], [s * 14, 0, t_slide + BZ + f38_stack - F38_PLATE_H + 2], d = 2);
    arrow([0, 0, qtr_cb_top - qtr_head_h + SZ - 22], [0, 0, qtr_cb_top - qtr_head_h + SZ - 3], d = 2);
}

tag("rear slide: 40 mm slots",        [81.1, 57.3, -20], R, size = 5.5, halign = "center");
tag("bottom slide: teeth underneath", [-29.8, 65.4, -20], R, size = 5.5, halign = "center");
tag("steel 1/4\"-20 x 3/8\"", [-73.9, 4.4, -34.1], R, to = [-58 + qtr_head_d / 2, 0, qtr_cb_top - qtr_head_h + SZ + 2], size = 6);
tag("from below",                     [-72.2, 9.0, -41.1], R, size = 6);
tag("lever along",                    [-75.6, 30.9, 54.4], R, to = [-58 + 6, f38_base[1] / 2 + 4, t_slide + BZ + 5.5], size = 5.5);
tag("the travel",                     [-74.2, 35.0, 48.2], R, size = 5.5);
