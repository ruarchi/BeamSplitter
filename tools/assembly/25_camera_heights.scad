// Step 25: match the lens heights with shims (09_shim_set) between camera and F38 plate.  Side view from -X with the
// frame's near (-X) half cut away; the lens axes meet at the glass.  On screen +Y (the back) is to the left.
// The shims (blue, drawn 2 mm) are shown half slid into their joints.
// Camera: --camera=0,40,120,85,0,270,800
include <scene_lib.scad>

C = [0, 40, 120];  R = [85, 270];                          // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

built(S_HEIGHTS, fclip = CLIP_NO_NX);
lens_axes();
RS = 45;  BS = -32;                                        // shims slid out: rear toward the back, bottom downward
new2() { translate([0, RS, 0]) shim_w("rear", 2); translate([0, 0, BS]) shim_w("bottom", 2); }
ZJ = z_rear_tripod + 1;                                    // rear joint height
arrow([-20, y_rear_sock + RS + 50, ZJ], [-20, y_rear_sock + RS + 25, ZJ], d = 3);
YJ = cam_b[3] - 1;                                         // bottom joint (camera base face)
arrow([-20, YJ, z_bot_sock + BS - 46], [-20, YJ, z_bot_sock + BS - 25], d = 3);

// screen positions: x = (px - 700) / 3.3, y = (525 - py) / 3.3 at this distance
tag("rear: shims raise", scr(-138, 46), R, size = 6.5, halign = "right");
tag("the camera", scr(-138, 35), R, to = [0, y_rear_sock + RS + 8, ZJ + 1], size = 6.5, halign = "right");
tag("bottom: shims move", scr(28, -132), R, to = [0, YJ, z_bot_sock + BS - 15], size = 6.5);
tag("the camera forward", scr(28, -143), R, size = 6.5);
tag("lens axes meet", scr(110, 72), R, to = [0, 0, Zs], size = 6.5);
tag("at the glass", scr(110, 61), R, size = 6.5);
tag("shim set (part 09):", scr(110, -20), R, size = 6.5);
tag("0.5, 1 and 2 mm", scr(110, -31), R, size = 6.5);

// card (top left): how to read the near / far targets
module ink(txt, at, size = 4.5, h = "left") color(C_INK) translate(at) linear_extrude(0.4)
    text(txt, size = size, halign = h, valign = "center", font = "Liberation Sans:style=Bold");
module frame_box(w, h, t = 0.8) difference() { square([w, h]); translate([t, t]) square([w - 2 * t, h - 2 * t]); }
module near_far_card() {
    color(C_INK) linear_extrude(0.5) frame_box(54, 40);                                       // the overlaid frames
    color(C_INK) translate([27, 31, 0]) linear_extrude(0.5) { circle(d = 4, $fn = 24); }          // far target
    color(C_NEW)  translate([22, 5, 0.6]) linear_extrude(0.4) frame_box(10, 14, 1.2);         // near target, image 1
    color(C_NEW2) translate([22, 11, 1.0]) linear_extrude(0.4) frame_box(10, 14, 1.2);        // near target, image 2
    ink("far", [31, 31, 0.5], 4);  ink("near", [34, 15, 1.2], 4);
    ink("overlay the two images,", [60, 33, 0.5]);
    ink("far target lined up.", [60, 26, 0.5]);
    ink("Near target higher in one", [60, 17, 0.5]);
    ink("image: that camera is low,", [60, 10, 0.5]);
    ink("add shims to it.", [60, 3, 0.5]);
    color([0.99, 0.99, 0.99]) translate([-4, -4, -1]) cube([150, 48, 0.5]);
    color([0.45, 0.46, 0.5]) translate([-5, -5, -1.4]) cube([152, 50, 0.5]);
}
translate(scr(-206, 104)) billboard(R) near_far_card();
