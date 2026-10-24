// Step 28: stereo.  Datum pins pulled (blue, lifted), carriages (orange) slid apart: the rear one toward +X, the bottom
// one toward -X, here 20 mm each; a vernier pin (blue) in the hole that lines up.  Lid, glass and cameras hidden; the
// frame's front is cut away.
// Camera: --camera=-52,90,110,55,0,330,1000
include <scene_lib.scad>
stereo_rear = 20;  stereo_bot = 20;

C = [-52, 90, 110];  R = [55, 330];                          // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

built(S_STEREO, hide = ["lid", "glass", "rear", "bottom", "cams"], fclip = [[-500, -48, -50], [500, 500, 500]]);
for (w = ["rear", "bottom"]) {
    new1() carriage_part(w);
    done() { c_slide_bolts(w); c_clamp_screws(w); slide_part(w); c_slide_nuts(w); f38_pins(w); }
    f38_base_w(w);
    new2() c_vernier_pin(w);
    new2() c_datum_pins(w, dz = 40);
}
arrow([stereo_rear - 15, y_rrail, deck_top + 45], [stereo_rear + 35, y_rrail, deck_top + 45], d = 4);
arrow([-stereo_bot + 15, bc_y0 - 12, bc_z1 + 26], [-stereo_bot - 35, bc_y0 - 12, bc_z1 + 26], d = 4);

// labels: left column, 150 mm toward the camera (in front of the frame)
RA = [stereo_rear + 10, y_rrail, deck_top + 45];                          // rear arrow middle
BA = [-stereo_bot - 10, bc_y0 - 12, bc_z1 + 26];                          // bottom arrow middle
L = -62;  Z = 150;  S = 6;
tag("1. pull the 4 datum pins", scr(L, 160, Z), R, size = S, halign = "right",
    to = [stereo_rear + car_dsep("rear") / 2, y_rrail - car_off("rear"), deck_top - dowel_depth + 40 + dowel_len]);
tag("2. loosen the 4 clamp thumbscrews", scr(L, 128, Z), R, size = S, halign = "right",
    to = [stereo_rear + car_cx("rear"), y_rrail, deck_top + clamp_seat + cs_head[1]]);
tag("3. slide the carriages apart", scr(L, 96, Z), R, size = S, halign = "right");
tag("rear: toward +X, up to 40 mm", scr(L, 72, Z), R, size = S, halign = "right", to = RA + [-20, 0, 0]);
tag("bottom: toward -X, up to 45 mm", scr(L, 12, Z), R, size = S, halign = "right", to = BA + [10, 0, 4]);
tag("vernier pin: 5 mm steps", scr(L, -22, Z), R, size = S, halign = "right",
    to = [-stereo_bot + vern_x("bottom")[0], y_wf - (-dowel_depth + dowel_len), wr_z + car_off("bottom")]);
tag("4. clamp finger-tight", scr(L, -54, Z), R, size = S, halign = "right");
tag("Back to zero: datum pins in, and push", scr(-212, -128, Z), R, size = S);
tag("each carriage toward +X (your left from", scr(-212, -140, Z), R, size = S);
tag("behind the rig) while you snug the clamps.", scr(-212, -152, Z), R, size = S);
