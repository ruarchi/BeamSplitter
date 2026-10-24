// Step 23: prepare the cameras off the rig: F38 plates, the a5100's 3 mm riser, OSS off, zoom taped at 18 mm.
// The bottom camera is drawn moved next to the rear one (TB), lens up as it will sit in the rig.
// Camera: --camera=0,45,195,75,0,290,800
include <scene_lib.scad>

C = [0, 45, 195];  R = [75, 290];                        // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

// rear camera (a6400 + 15 mm), lifted off its plate; the plate's own 1/4"-20 screw from below
RZ = 45;  RP = 22;
PR = [stereo_rear, y_rear_sock, z_rear_tripod];            // the rear camera's tripod socket (seated)
rear_cam_body(dpos = [0, 0, RZ]);
f38_plate_w("rear", dz = RP);
translate(PR + [0, 0, RP - 22]) qtr_screw();
arrow(PR + [0, 0, RP - 42], PR + [0, 0, RP - 24], d = 2.5);

// bottom camera (a5100 + 10-18 mm, lens up), its 3 mm riser, its plate and the screw 3 mm longer
TB = [0, -40, 110];
BY = -45;  SY = -26;  PY = 8;
PB = [-stereo_bot, cam_b[3], z_bot_sock];                  // the bottom camera's tripod socket (seated)
ZR = z_bot_mount + 28;                                     // zoom ring (tape)
translate(TB) {
    bot_cam_body(dpos = [0, BY, 0]);
    new1() swap_shim_w(dy = SY);
    f38_plate_w("bottom", dz = PY);
    translate(PB + [0, 22, 0]) rotate([90, 0, 0]) qtr_screw(qtr_screw_len + swap_shim_t);
    arrow(PB + [0, 40, 0], PB + [0, 24, 0], d = 2.5);
    color([0.92, 0.92, 0.86]) translate([-stereo_bot, BY, ZR]) difference() {      // tape on the zoom ring
        cylinder(d = lens_1018[0] + 1.2, h = 10, $fn = 96); translate([0, 0, -1]) cylinder(d = lens_1018[0] - 1, h = 12, $fn = 96); }
}
function B(p) = TB + p;                                    // a bottom-group point, moved like the group

tag("rear camera (a6400)", scr(-190, 118), R, size = 8);
tag("bottom camera (a5100)", scr(25, 118), R, size = 8);
tag("F38 plate", scr(-112, -78), R, to = PR + [-14, 0, RP + 6], size = 6.5, halign = "right");
tag("with its own screw", scr(-112, -89), R, to = PR + [0, 0, RP - 16], size = 6.5, halign = "right");
tag("1/4\"-20 screw 3 mm longer", scr(40, -100), R, to = B(PB + [0, 16, -3]), size = 6.5, halign = "right");
tag("3 mm riser (part 10)", scr(92, -106), R, to = B([-stereo_bot, cam_b[3] + swap_shim_t + SY, z_bot_sock - 15]), size = 6.5);
tag("check: battery door opens", scr(92, -117), R, size = 6.5);
tag("10-18 mm lens: OSS off,", scr(78, 78, 140), R, to = B([-stereo_bot - 34, BY + 11, ZR + 5]), size = 5.5, halign = "right");
tag("zoom to 18 mm (end stop),", scr(78, 69, 140), R, size = 5.5, halign = "right");
tag("tape the zoom ring", scr(78, 60, 140), R, size = 5.5, halign = "right");
