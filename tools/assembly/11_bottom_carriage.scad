// Step 11: fit the bottom carriage on the wall rail's front face (docs/ASSEMBLY.md).  Front of the frame cut away
// (y < -30) to see in.  Carriage (orange, its T-bolts in) moved out toward the front; datum pins and clamp
// thumbscrews (blue) further out; arrows show the push toward the rail (+Y).
// Camera (the labels are placed for it): --camera=-30,0,72,68,0,30,560
include <scene_lib.scad>

R = [68, 30];                        // label rotation = camera rx, rz
CZ = 45;  PZ = 88;  SZ = 128;        // explode distances toward the front: carriage, datum pins, clamp thumbscrews
// carriage-local [x, y, z] -> world (bottom carriage: local y = world Z, local z = toward the front)
function bw(p) = [p[0] - stereo_bot, y_wf - p[2], wr_z + p[1]];
cf = bc_t + CZ;                      // carriage front face (local z) while held out

built(S_BOT_CAR, fclip = [[-500, -30, -50], [500, 500, 500]]);
new1() { carriage_part("bottom", dz = CZ); c_slide_bolts("bottom", dz = CZ); }
new2() { c_datum_pins("bottom", dz = PZ); c_clamp_screws("bottom", dz = SZ); }
for (s = [-1, 1]) {
    arrow(bw([s * bc_clamp_x, 0, SZ - 14]), bw([s * bc_clamp_x, 0, cf + 3]), d = 1.8);                       // thumbscrews
    arrow(bw([s * bc_datum_sep / 2, -wr_off, PZ - 12]), bw([s * bc_datum_sep / 2, -wr_off, cf + 3]), d = 1.8); // pins
    arrow(bw([s * 66, -12, CZ - 2]), bw([s * 66, -12, 3]), d = 2.5);                                           // carriage
}

tag("clamp thumbscrews", [-53.9, -63.8, 90.0], R, to = bw([-bc_clamp_x, 4, SZ + 6]), size = 5.5, halign = "right");
tag("finger-tight",      [-52.7, -65.9, 83.9], R, size = 5.5, halign = "right");
tag("datum pins = zero", [-49.3, -40.1, 42.7], R, to = bw([-bc_datum_sep / 2, -wr_off - 2, PZ + 4]), size = 5.5, halign = "right");
