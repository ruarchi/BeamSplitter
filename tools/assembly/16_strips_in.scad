// Step 16: slide the groove strips in (docs/ASSEMBLY.md).  Lid off, no glass thumbscrews in their bosses.  The +X strip
// (orange, felt green) slid partway into its channel from the open top-front end of the rib, end cap first, thin lip
// toward the middle; the -X strip (light grey) already home.
// Camera (the labels are placed for it): --camera=80,-62,230,58,0,292,340
include <scene_lib.scad>

DV = 60;                             // how far the +X strip still sticks out
built(S_STRIPS, hide = ["lid"]);
new1() strips_part(dv = DV, sides = [1]);  color(C_FELT) { felt_lip(dv = DV, sides = [1]); felt_endpad(dv = DV, sides = [1]); }
done() strips_part(sides = [-1]);  color(C_FELT) { felt_lip(sides = [-1]); felt_endpad(sides = [-1]); }
// push along the channel (+V): an arrow in line with the strip, behind its top-front end
arrow(pl2w_s([STRIP_PULL[0], v_s0 - DV - 48, STRIP_PULL[2]], 1), pl2w_s([STRIP_PULL[0], v_s0 - DV - 4, STRIP_PULL[2]], 1), d = 2);

// labels: in a plane in front of the rib, facing the camera (rx, rz); sizes keep the text about the same on screen
R = [58, 292];
UP = [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])];       // label "up" (next line = -1.5 * size * UP)
module tag2(l1, l2, at, size, to = undef, halign = "left") {
    tag(l1, at, R, to = to, size = size, halign = halign);
    tag(l2, at - 1.5 * size * UP, R, size = size, halign = halign);
}
tag("push in until it stops", [52.4, -108.5, 283.9], R, size = 2.3);
tag2("pull hole", "at this end", [47.2, -109.0, 276.0], 2.3, to = pl2w_s([x_gb_s, STRIP_PULL[1] - DV, STRIP_PULL[2]], 1));
tag2("no thumbscrews", "in the bosses yet", [66.0, -15.5, 235.6], 2.85, to = gs_pt(1, 0, w_hi + boss_h), halign = "right");
tag2("thin lip + felt:", "toward the middle", [52.3, -97.2, 254.9], 2.45, to = pl2w_s([x_lip + 1.5, -100, -felt_t / 2], 1));
tag("end cap first", [42.4, -23.4, 168.1], R, to = pl2w_s(STRIP_CAP - [0, DV, 0], 1), size = 3.0);
