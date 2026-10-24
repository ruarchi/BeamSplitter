// Step 20: the six glass thumbscrews, each with an 8 mm felt disc on its tip, turned in from above.
// Inset (upper left): one thumbscrew and its felt disc, enlarged.
// Camera: --camera=0,20,208,50,0,200,760
include <scene_lib.scad>

C = [0, 20, 208];  R = [50, 200];                          // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

DW = 30;                                                   // screws shown this far out along their axes
H  = TIP_TIGHT + DW + ps_len + ps_head[1];                 // plate-local w of the head tops
built(S_GLASS_SCREWS, hide = ["cams"]);
new1() glass_screws(dw = DW, discs = false);
color(C_FELT) felt_discs(dw = DW);
for (s = [-1, 1], i = [0 : 2]) {
    arrow(gs_pt(s, i, H + 22), gs_pt(s, i, H + 4), d = 2);
    screw_turn(gs_pt(s, i, H + 8), -W_DIR, r = 12);
}

L1 = "finger-tight, then 1/8 turn";
tag(L1, scr(-40, 136), R, to = gs_pt(1, 0, H + 8) + [12, 0, 0], size = 7.5, halign = "right");
tag("never with a tool", scr(-40 - tag_w(L1, 7.5), 122), R, size = 6.5);
tag("turn in until the felt", scr(80, 128), R, to = gs_pt(-1, 0, H + 8) + [-12, 0, 0], size = 7);
tag("touches the glass", scr(80, 115), R, size = 7);

// inset: one thumbscrew with its felt disc (drawn as if seen level from the front, then turned to the camera)
module ink(txt, x, z, size = 5) color(C_INK) translate([x, 21, z]) rotate([90, 0, 0])
    linear_extrude(0.4) text(txt, size = size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
module screw_zoom() {
    k = 2.6;
    scale(k) {
        new1() translate([0, 0, ps_len + ps_head[1]]) rotate([180, 0, 0]) preload_screw();      // head up, tip down
        color(C_FELT) translate([0, 0, -3.5]) cylinder(d = FELT_DISC_D, h = felt_t * 2, $fn = 48); // disc (thickness x2)
        arrow([0, 0, -9.5], [0, 0, -3.8], d = 0.9);
        color(C_INK) for (x = [-1, 1]) translate([x * FELT_DISC_D / 2 - 0.15, 0, -4.2]) cube([0.3, 0.3, 4]);   // 8 mm
        color(C_INK) translate([-FELT_DISC_D / 2, 0, -2.4]) cube([FELT_DISC_D, 0.3, 0.3]);
    }
    ink("8 mm felt disc", 0, -k * 11, 5.5);
    ink("on the flat tip", 0, -k * 11 - 8, 4.6);
    color([0.99, 0.99, 0.99]) translate([-36, 25, -46]) cube([72, 0.5, 100]);
    color([0.45, 0.46, 0.5]) difference() { translate([-37, 24.6, -47]) cube([74, 0.5, 102]); translate([-36, 23, -46]) cube([72, 4, 100]); }
}
translate(scr(-150, 25)) billboard(R) rotate([-90, 0, 0]) screw_zoom();
