// Step 05 picture: run each printed screw into its printed thread once, then out again.  Seen from behind the rig:
// the four lid thumbscrews (orange) above the threaded pads on the four post tops, the six glass thumbscrews (blue)
// behind their bosses on the two diagonal ribs.
include <scene_lib.scad>
include <screen_labels.scad>
CAM = [-103, -17, 150, 50, 205, 1150];  // = --camera=-103,-17,150,50,0,205,1150

LID_DZ = 40;       // lid thumbscrews held this high above their pads
GS_DW  = 25;       // glass thumbscrews held this far out of their bosses (tip flush with the channel roof + GS_DW)

built(S_THREADS);
new1() lid_screws(dz = LID_DZ);
for (sx = [-1, 1], b = lid_bolts) screw_turn([sx * b[0], b[1], frame_top + LID_DZ + lid_t + lid_sh[1] + 6], [0, 0, -1], r = 14);
new2() glass_screws(tip = TIP_BACK, dw = GS_DW);
for (s = [-1, 1], i = [0 : 2]) screw_turn(gs_pt(s, i, TIP_BACK + GS_DW + ps_len + ps_head[1] + 5), -W_DIR, r = 11);

lab("lid thumbscrews:", [900, 120], [-lid_bolts[0][0], lid_bolts[0][1], frame_top + LID_DZ + lid_t + lid_sh[1]]);
lab("in once, then out again", [900, 155]);
lab("glass thumbscrews:", [900, 420], gs_pt(-1, 1, TIP_BACK + GS_DW + ps_len + ps_head[1]));
lab("all the way through,", [900, 455]);
lab("then out again", [900, 490]);
lab("(keep them for step 20)", [900, 525]);
