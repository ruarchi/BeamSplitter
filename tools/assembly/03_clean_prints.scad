// Step 03 picture: the inside of the +X diagonal rib (the -X half of the frame cut away), seen from inboard and a little
// from below.  Orange: the lower inner corner of each glass-thumbscrew boss, which may droop into the groove (trim it).
// Blue: the strip channel, which must be free of brim and blobs.
include <scene_lib.scad>
include <screen_labels.scad>
CAM = [76, 10, 182, 105, 285, 330];     // = --camera=76,10,182,105,0,285,330

built(S_CLEAN, fclip = CLIP_NO_NX);
new1() boss_corners(sides = [1]);
new2() pl_box([[x_lip, v_top + 1, w_seat], [x_ch, v_bot - 4, w_hi - 0.2]]);   // the strip channel

lab("glass-thumbscrew boss", [470, 60], pl2w([boss_x0, preload_v[1] - 2, w_hi + 6]));
lab("strip channel: no brim, no blobs", [560, 135], pl2w([x_lip, -58, w_hi - 1]));
lab("trim this corner (all six)", [560, 210], pl2w([boss_x0 - 0.6, preload_v[0] - 3, w_hi]));
