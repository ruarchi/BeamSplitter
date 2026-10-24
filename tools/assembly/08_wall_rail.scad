// Step 08 picture: the wall rail (orange) in front of the crosswall; the front and the top of the frame cut away.  Its two T-nuts
// (blue) are already in its T-slot; it is longer than the frame is wide inside, so its ends pass through the open
// sides.  It goes back onto the two pins, then the four wall-rail bolts (blue) go through it into the band T-nuts.
include <scene_lib.scad>
include <screen_labels.scad>
CAM = [38, 18, 70, 65, 330, 780];        // = --camera=38,18,70,65,0,330,780

RAIL_DY = -50;     // rail held this far in front of its place
BOLT_DY = -95;     // bolts held this far in front of theirs

built(S_WALLRAIL, fclip = [[-200, -5, -50], [200, 300, 140]]);
new1() wall_rail_part(dy = RAIL_DY);
new2() { translate([0, RAIL_DY, 0]) c_tnuts("bottom"); wr_bolts(dy = BOLT_DY); }
for (x = wrl_bolt_x) arrow([x, y_wf - 72, wr_z + wrl_bolt_h], [x, y_wf - 53, wr_z + wrl_bolt_h], d = 2);
arrow([wrl_half + 45, y_wf + RAIL_DY + 5, wr_z], [wrl_half + 8, y_wf + RAIL_DY + 5, wr_z], d = 2.5);   // nuts in at the end
hex_key_tool([wrl_bolt_x[3], y_wf + BOLT_DY - wb_head[1] + wrl_cb - 1, wr_z + wrl_bolt_h], [0, 1, 0], up = [0, 0, -1], long = 40);

lab("The rail is longer than the frame is wide inside:", [30, 50]);
lab("pass it in through an open side, T-slot to the front,", [30, 85]);
lab("then push it back onto the two pins.", [30, 120]);
lab("2 T-nuts: slide them into", [1030, 270], [bc_clamp_x + tn_l / 2, y_wf + RAIL_DY - 2, wr_z + 6]);
lab("the T-slot from one end,", [1030, 305]);
lab("bevels toward the opening", [1030, 340]);
lab("4 wall-rail bolts M8 \u00d7 21: start by hand,", [40, 975], [wrl_bolt_x[0] - wb_head[0] / 2, y_wf + BOLT_DY + wrl_cb - wb_head[1], wr_z + wrl_bolt_h]);
lab("snug with the short arm of the key only", [40, 1010]);
