// Step 07 picture: the crosswall (the wall behind the bottom camera); the front and the top of the frame cut away.  Two short
// pins O5 x 12 (orange) go into the two holes in its front band; four T-nuts (blue) drop into the four slots in the
// band's top edge, flat face toward the front (toward the rail).
include <scene_lib.scad>
include <screen_labels.scad>
CAM = [0, 70, 85, 58, 345, 680];        // = --camera=0,70,85,58,0,345,680

built(S_CROSSWALL, fclip = [[-200, 30, -50], [200, 300, 118]]);
new1() wr_pins(dy = -30);
for (x = wrl_dowel_x) arrow([x, y_cwm - 58, wr_z + wrl_bolt_h], [x, y_cwm - 27, wr_z + wrl_bolt_h], d = 2);
new2() wr_band_tnuts(dz = 70);
for (x = wrl_bolt_x) arrow([x, y_cwm + wrl_nut_f + 2.5, cw_top + 52], [x, y_cwm + wrl_nut_f + 2.5, cw_top + 8], d = 2);

lab("2 pins \u00d8 5 \u00d7 12: press in", [30, 965], [wrl_dowel_x[0], y_cwm - (wrl_dowel_len - wrl_dowel_wall) - 30 + 4, wr_z + wrl_bolt_h + pin_d / 2]);
lab("(about 5.5 mm stays out)", [30, 1000]);
lab("4 T-nuts: drop into the slots,", [40, 90], [wrl_bolt_x[0] - tn_l / 2, y_cwm + wrl_nut_f, wr_z + wrl_bolt_h + 70 + 2]);
lab("flat face to the front", [40, 125]);
