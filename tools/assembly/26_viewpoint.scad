// Step 26: match the viewpoints with the two slides (bottom first, in 2 mm teeth; then the rear, continuous), using
// near and far targets.  Same side view as step 25, lid off, with the two cameras' fields of view.
// Camera: --camera=0,40,120,85,0,270,800
include <scene_lib.scad>
fov_len = 260;

C = [0, 40, 120];  R = [85, 270];                          // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

built(S_VIEWPOINT, fclip = CLIP_NO_NX, hide = ["lid"]);
fov_frusta();
arrow2([-70, y_rear_sock - 22, z_rear_tripod + 80], [-70, y_rear_sock + 22, z_rear_tripod + 80], d = 3);   // rear slide
arrow2([-70, 20, z_bot_sock - 14], [-70, 20, z_bot_sock + 14], d = 3);                                      // bottom slide

// labels 100 mm toward the camera (in front of the field-of-view wedges)
tag("2. then the rear slide: continuous,", scr(-84.0, 117.8, 100), R, size = 5.8);
tag("at most 5 mm forward of its start mark", scr(-84.0, 108.1, 100), R, to = [-70, y_rear_sock, z_rear_tripod + 83], size = 5.8);
tag("1. bottom slide first: 2 mm teeth,", scr(22.8, -116.8, 100), R, to = [-70, 20, z_bot_sock - 16], size = 5.8);
tag("keep the tooth that matches best", scr(22.8, -126.4, 100), R, size = 5.8);
tag("targets: near (0.5 m)", scr(94.5, -38.0, 100), R, size = 5.8);
tag("and far (5 m or more),", scr(94.5, -47.6, 100), R, size = 5.8);
tag("centre and edges", scr(94.5, -57.2, 100), R, size = 5.8);
