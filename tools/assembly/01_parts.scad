// Step 01 picture: every printed part (stl 01-10), each pulled out of its place on the rig.
include <scene_lib.scad>

include <screen_labels.scad>
CAM = [-36, 22, 165, 62, 300, 1700];     // = --camera=-36,22,165,62,0,300,1700

LID   = [0, 0, 170];
STOPS = [0, 0, 75];
STRIP = 90 * W_DIR;
REAR  = [0, 150, 0];                    // rear-camera parts: pulled out of the back
FRONT = [0, -200, 0];                   // bottom-camera parts: pulled out of the front
color(C_FRAME) part_w(0);
new1() {
    part_w(1, LID);                                  // 02 top lid
    part_w(6, STOPS);                                // 07 glass stops
    translate(STRIP) part_w(7);                      // 08 groove strips, lifted out of their channels
    part_w(3, REAR + [0, 0, 40]);                    // 04 rear carriage
    translate(REAR) slide_part("rear", 95);          // 06 rear F38 slide
    translate(REAR + [0, 0, 120]) part_w(8);         // 09 shims (they go on the rear slide)
    part_w(2, FRONT);                                // 03 wall rail
    part_w(4, FRONT + [0, -70, 0]);                  // 05 bottom carriage
    translate(FRONT + [0, -130, 0]) slide_part("bottom");   // 06 bottom F38 slide
    part_w(9, FRONT + [0, -190, 0]);                 // 10 3 mm riser
}

y_rs = y_rear_sock + REAR[1];
z_rs = deck_top + t_rear_carriage;                   // rear slide underside, in place
lab("09 shims", [40, 200], [-shim_fp[0] / 2, y_rs, z_rs + t_slide + f38_stack + 120 + 46 + 2]);
lab("06 F38 slide (rear)", [40, 300], [-slide_hw, y_rs, z_rs + 95 + t_slide]);
lab("04 rear carriage", [40, 410], [-60, y_rrail + REAR[1], deck_top + 40 + t_rear_carriage]);
lab("01 frame", [40, 600], [-95, 120, deck_top]);
lab("02 top lid", [990, 110], [60, lid_y0, frame_top + LID[2] + lid_t]);
lab("07 glass stops (pair)", [990, 250], [80, -55, frame_top + STOPS[2] + 2]);
lab("08 groove strips (pair)", [990, 360], [77, 0, 0] + pl2w([0, -20, 2]) + STRIP);
// the bottom-camera parts: labels under them, right ends under each part, one row lower each
lab("03 wall rail",          [905, 850],  [-60, y_wf + FRONT[1] - 10, 40], "right");
lab("05 bottom carriage",    [1020, 900], [-30, y_wf + FRONT[1] - 70 - bc_t, 20], "right");
lab("06 F38 slide (bottom)", [1125, 950], [-20, bc_y0 + FRONT[1] - 130 - t_slide, 25], "right");
lab("10 3 mm riser",         [1260, 1000], [0, cam_b[3] + swap_shim_t + FRONT[1] - 190, z_bot_sock - 13], "right");
