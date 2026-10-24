// Step 14: bottom slide onto its carriage (docs/ASSEMBLY.md).  Front of the frame cut away (y < -30).  Slide
// (orange) with its F38 base (dark red) held out toward the front, teeth toward the carriage's teeth; thumb-nuts
// (blue) further out; arrows show the push toward the carriage (+Y).
// Camera (the labels are placed for it): --camera=-20,10,72,70,0,35,450
include <scene_lib.scad>

R = [70, 35];                        // label rotation = camera rx, rz
SZ = 25;  NZ = 60;                   // explode toward the front: slide, thumb-nuts
// carriage-local [x, y, z] -> world (bottom carriage: local y = world Z, local z = toward the front)
function bw(p) = [p[0] - stereo_bot, y_wf - p[2], wr_z + p[1]];

built(S_BOT_SLIDE, fclip = [[-500, -30, -50], [500, 500, 500]]);
new1() slide_part("bottom", dz = SZ);
f38_base_w("bottom", dz = SZ);  done() f38_pins("bottom", dz = SZ);
new2() c_slide_nuts("bottom", dz = NZ);
yf = y_wf - (bc_t + SZ + t_slide);  // slide front face (world y) while held out
for (s = [-1, 1]) {
    arrow(bw([s * slide_bolt_x, car_yc("bottom"), bc_t + t_slide + NZ - 2]), [s * slide_bolt_x - stereo_bot, yf - 2, bc_bolt_z], d = 1.8);  // nuts
    arrow([s * 47 - stereo_bot, yf + t_slide, z_bot_sock - 14], [s * 47 - stereo_bot, y_wf - bc_t - 2, z_bot_sock - 14], d = 2.2);     // slide
}
arrow2([-56 - stereo_bot, yf + 3, z_bot_sock - 14], [-56 - stereo_bot, yf + 3, z_bot_sock + 14], d = 1.8);   // up / down in 2 mm steps

// several label lines stacked under each other (the leader from the first line); card = a pale backing card
function bb_up(rot) = [-sin(rot[1]) * cos(rot[0]), cos(rot[1]) * cos(rot[0]), sin(rot[0])];
module tagn(lines, at, rot, to = undef, size = 6, halign = "left", card = false) {
    for (i = [0 : len(lines) - 1])
        tag(lines[i], at - i * 1.5 * size * bb_up(rot), rot, to = i == 0 ? to : undef, size = size, halign = halign);
    if (card) let(w = max([for (l = lines) 0.8 * size * len(l)]), x0 = halign == "left" ? 0 : halign == "right" ? -w : -w / 2,
                  h = (len(lines) - 1) * 1.5 * size + 1.6 * size)
        color([1, 1, 1]) translate(at) billboard(rot) translate([x0 - 0.5 * size, -h + 0.8 * size, -0.8]) cube([w + size, h, 0.3]);
}

// labels in a plane in front of everything (y = -40; the frame is cut away there), with pale cards
tagn(["slide teeth go", "against these"], [-2.7, -40, 127.6], R, to = [-35 - stereo_bot, y_wf - bc_t, 80], size = 4.2, halign = "right", card = true);
tagn(["start: push up,", "then 1 tooth", "(2 mm) down"], [-10.0, -40, 89.8], R, size = 4.2, halign = "right", card = true);
tagn(["thumb-nuts", "finger-tight"], [-24.9, -40, 53.7], R, to = [-slide_bolt_x - stereo_bot - 6, -12, bc_bolt_z], size = 4.2, halign = "right", card = true);
