// Step 04 picture: what to paint matt black (orange): the six glass-thumbscrew bosses and the bevelled upper groove
// flanks, the heads of the six glass thumbscrews and the ears of the two glass stops; and the flocking film (blue) on
// the underside of the lid, shown turned over beside the frame.
include <scene_lib.scad>
include <screen_labels.scad>
CAM = [-125, 30, 150, 50, 205, 1080];  // = --camera=-125,30,150,50,0,205,1080

LID_X  = -270;    // lid turned over (underside up), set down beside the frame
STOP_Z = 45;      // glass stops lifted

built(S_PAINT);
new1() paint_zones();
translate([LID_X, 0, 0]) lid_flipped(-frame_top + lid_t + 40, c_flock = C_NEW2);
for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) translate([0, 0, STOP_Z]) {
    done() place_plate() glass_stop_block_local();
    new1() glass_stop_ear_world();
}
// the six glass thumbscrews on the bench, head up: the head (to paint) orange, the thread grey
GS_ROW = [for (i = [0 : 5]) [LID_X + 80 - 32 * i, lid_y0 - 110, 0]];
module gs_up() translate([0, 0, ps_len + ps_head[1]]) rotate([180, 0, 0]) preload_screw();
module gs_head_zone() translate([-15, -15, ps_len - 0.01]) cube([30, 30, ps_head[1] + 1]);
for (q = GS_ROW) translate(q) {
    new1() render() intersection() { gs_up(); gs_head_zone(); }
    done() render() difference() { gs_up(); gs_head_zone(); }
}

lab("glass-stop ears: matt black", [830, 60], [-96, -50, frame_top + STOP_Z + 4]);
lab("bosses and groove flank: matt black", [830, 200], pl2w_s([x_pl - 4, preload_v[0], w_hi + boss_h], -1),
    more = [pl2w_s([x_ul + 1, -55, w_hi + 2], -1)]);
lab("glass-thumbscrew heads: matt black", [830, 440], GS_ROW[5] + [0, 0, ps_len + ps_head[1]]);
lab("flocking film on the lid underside", [700, 1015], [LID_X + 10, 10, lid_t + 41]);
