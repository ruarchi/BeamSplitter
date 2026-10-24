// Step 29: service.  Glass out, glass thumbscrews backed off three turns, the +X groove strip (orange) pulled out
// toward the top-front with a bent paper clip hooked in its pull hole.  Lid, stops and cameras off.
// Camera: --camera=70,-60,232,55,0,320,400
include <scene_lib.scad>

C = [70, -60, 232];  R = [55, 320];                        // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

DV = 45;                                                   // strip pulled out this far
built(S_ALL, hide = ["glass", "stops", "lid", "screws", "cams", "strips"]);
done() glass_screws(TIP_OUT);
done() strips_part(sides = [-1]);
color(C_FELT) felt_lip(sides = [-1]);
new1() strips_part(dv = DV, sides = [1]);
color(C_FELT) felt_lip(dv = DV, sides = [1]);
paper_clip(dv = DV);
arrow(pl2w_s([70, -150, 25], 1), pl2w_s([70, -190, 25], 1), d = 3);

GS = gs_pt(1, 0, TIP_OUT + ps_len + ps_head[1]);          // head top of the thumbscrew nearest the strip end
CLIP = pl2w_s(STRIP_PULL - [0, DV, 0] + [-6, -4, 5], 1);   // the paper clip just above the pull hole
tag("glass out first; lid and glass stops off", scr(-103, 72), R, size = 3.6);
tag("thumbscrews:", scr(-70, 30), R, size = 3.6, halign = "right");
tag("at least 3 full", scr(-70, 23), R, size = 3.6, halign = "right");
tag("turns back", scr(-70, 16), R, size = 3.6, halign = "right", to = GS);
tag("bent paper clip", scr(52, 8), R, size = 3.6, to = CLIP);
tag("in the pull hole", scr(52, 1), R, size = 3.6);
tag("pull toward the top-front", scr(17, 66), R, size = 3.6, halign = "right");

// inset (lower right): the strip's top-front end from its inner side, 2.6 x, with the paper clip in the pull hole
// (drawn for a camera at rx = 75, rz = 0, then turned to face the main camera)
V0 = v_s0 - 0.5;  V1 = spring_v[0] + 4;  K = 2.05;  LRX = 75;
function rotx(a, p) = [p[0], p[1] * cos(a) - p[2] * sin(a), p[1] * sin(a) + p[2] * cos(a)];
module ink(txt, at, size = 3.2, h = "left") color(C_INK) translate(at) linear_extrude(0.3)
    text(txt, size = size, halign = h, valign = "center", font = "Liberation Sans:style=Bold");
module end_zoom() {
    rotate([-LRX, 0, 0]) {
        strip_zoom(V0, V1, K);
        scale(K) rotate([0, 0, 90]) translate([-(x_lip + xo_s) / 2, -(V0 + V1) / 2, 0])
            intersection() { paper_clip_local(0); translate([60, V0 - 0.5, -20]) cube([40, 40, 60]); }
    }
    h = rotx(-LRX, sz_pt(STRIP_PULL - [(x_gb_s + xo_s) / 2 - x_gb_s, 0, 0], V0, V1, K));   // hole on the inner face
    b = rotx(-LRX, sz_pt(STRIP_BUMPS[0], V0, V1, K));                                         // spring bump top
    ink("pull hole", [12, -17, 8]);
    color(C_INK) hull() { translate([18, -14, 8]) sphere(d = 0.4, $fn = 8); translate(h) sphere(d = 0.4, $fn = 8); }
    color(C_INK) translate(h) sphere(d = 1.2, $fn = 12);
    ink("spring bump", [-30, -17, 8]);
    color(C_INK) hull() { translate([-22, -14, 8]) sphere(d = 0.4, $fn = 8); translate(b + [0, 0, 1]) sphere(d = 0.4, $fn = 8); }
    color(C_INK) translate(b + [0, 0, 1]) sphere(d = 1.2, $fn = 12);
    ink("strip end (top-front)", [0, 20, 0], 3.2, "center");
    color([0.99, 0.99, 0.99]) translate([-36, -24, -14]) cube([72, 50, 0.4]);
    color([0.45, 0.46, 0.5]) translate([-37, -25, -14.4]) cube([74, 52, 0.4]);
}
translate(scr(64, -48)) billboard(R) end_zoom();
