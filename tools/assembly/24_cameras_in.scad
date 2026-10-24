// Step 24: click the cameras in.  Rear camera (orange): from behind and above onto its F38 base.  Bottom camera
// (blue): lens up, in through the open -X side about 15 mm forward of its place (see-through), then back onto its base.
// Camera: --camera=-95,20,115,62,0,295,1080
include <scene_lib.scad>

C = [-95, 20, 115];  R = [62, 295];                        // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

built(S_CAMERAS);
// rear camera, lifted up and back
RD = [0, 40, 40];
translate(RD) { new1() rear_cam_body(); f38_plate_w("rear"); }
arrow([-75, 190, 215], [-75, 150, 175], d = 4);
// bottom camera: outside the open -X side, then (see-through) inside 15 mm forward of its place
FW = -15;
translate([-260, FW, 0]) { new2() bot_cam_body(); f38_plate_w("bottom"); new1() swap_shim_w(); }
ghost(0.3) bot_cam_body(dpos = [0, FW, 0]);
arrow([-195, FW, 100], [-105, FW, 100], d = 4);
arrow([-48, FW - 22, 118], [-48, 8, 118], d = 3);

tag("rear camera:", scr(-150, 166), R, to = RD + [-60, 140, 190], size = 8, halign = "right");
tag("from behind and above,", scr(-150, 153), R, size = 8, halign = "right");
tag("lens forward under the lid,", scr(-150, 140), R, size = 8, halign = "right");
tag("push down until it clicks", scr(-150, 127), R, size = 8, halign = "right");
tag("1. bottom camera, lens up:", scr(-118, -66), R, to = [-294, FW + 8, 112], size = 8, halign = "right");
tag("in through the open side,", scr(-118, -79), R, size = 8, halign = "right");
tag("held 15 mm forward", scr(-118, -92), R, size = 8, halign = "right");
tag("2. push it back onto", scr(158, 35), R, to = [-48, 8, 118], size = 8);
tag("its base until it clicks", scr(158, 22), R, size = 8);
tag("never let a lens touch the glass", scr(25, -178), R, size = 8);
