// Step 22: the lid, flocked side down, onto the two post-top pins; four M10 lid thumbscrews.
// Camera: --camera=10,-10,258,55,0,330,880
include <scene_lib.scad>

C = [10, -10, 258];  R = [55, 330];                         // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

DL = 60;  DS = 115;                                        // lid and screws shown lifted
built(S_LID, hide = ["cams"]);
new1() lid_part(dz = DL);
flock_lid(dz = DL);
new2() lid_screws(dz = DS);
for (sx = [-1, 1], b = lid_bolts) arrow([sx * b[0], b[1], frame_top + 105], [sx * b[0], b[1], frame_top + 80], d = 2.5);

ZT = frame_top + lid_t + lid_rib_h + DL;                   // top of the lifted lid's ribs
tag("pins locate the lid", scr(118, -38), R, to = [lid_dowels[0][0], lid_dowels[0][1], frame_top + 2], size = 6.5);
tag("(round hole / slot)", scr(118, -49), R, size = 6);
tag("cold shoe and 1/4\"-20", scr(118, 62), R, to = [shoe_pos[0], shoe_pos[1] + shoe_len / 2, ZT + 2], size = 6.5);
tag("thread for accessories", scr(118, 51), R, size = 6.5);
tag("front screws", scr(-160, -52), R, to = [-lid_bolts[0][0], lid_bolts[0][1], fp_top + ear_t], size = 6.5, halign = "right");
tag("also clamp", scr(-160, -63), R, size = 6.5, halign = "right");
tag("the stop ears", scr(-160, -74), R, size = 6.5, halign = "right");
tag("flocked side down", scr(-140, 8), R, to = [-lid_hw + 4, lid_y0 + 40, frame_top + DL], size = 6.5, halign = "right");
