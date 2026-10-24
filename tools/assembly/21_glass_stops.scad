// Step 21: the two glass stops, lowered onto the lid pins on the front post tops.
// Inset (top middle): the +X stop seen from behind and below, showing the felt on its face that meets the glass.
// Camera: --camera=0,-45,232,64,0,345,600
include <scene_lib.scad>

C = [0, -45, 232];  R = [64, 345];                         // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

DZ = 30;                                                   // stops shown lifted
built(S_STOPS, hide = ["cams"]);
new1() stops_part(dz = DZ);
color(C_FELT) felt_stop(dz = DZ);
for (d = lid_dowels) arrow([d[0], d[1], frame_top + 70], [d[0], d[1], frame_top + 47], d = 2.5);

tag("ear over the lid pin", scr(58, 99), R, to = [lid_dowels[0][0], lid_dowels[0][1], fp_top + DZ + ear_t], size = 6.5);
tag("one per side (mirror pair)", scr(-150, 104), R, size = 6.5);

// inset: the +X stop drawn for a camera at rx = 115, rz = 215 (behind and below), then turned to face the main
// camera
LR = [115, 215];
STOP_C = [87, -50, 233];                                   // about the middle of the +X stop
K = 2.2;
function rotx(a, p) = [p[0], p[1] * cos(a) - p[2] * sin(a), p[1] * sin(a) + p[2] * cos(a)];
function rotz(a, p) = [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a), p[2]];
function inset_pt(p) = K * rotx(-LR[0], rotz(-LR[1], p - STOP_C));   // world point of the stop -> inset frame
module ink(txt, at, size = 5) color(C_INK) translate(at) linear_extrude(0.4)
    text(txt, size = size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
translate(scr(-15, 62)) billboard(R) {
    rotate([-LR[0], 0, 0]) rotate([0, 0, -LR[1]]) scale(K) translate(-STOP_C) {
        new1() glass_stop_world_p();
        color(C_FELT) felt_stop(sides = [1]);
    }
    f = inset_pt(pl2w([(stop_x0 + x_gb_s) / 2, v_top + end_pad, 1]));
    ink("felt, 2 layers (1 mm)", [0, -40, -36], 5);
    ink("on the face that meets the glass", [0, -48, -36], 4);
    color(C_INK) hull() { translate([22, -35, f[2] + 4]) sphere(d = 0.6, $fn = 8); translate(f + [0, 0, 4]) sphere(d = 0.6, $fn = 8); }
    color(C_INK) translate(f + [0, 0, 4]) sphere(d = 2, $fn = 16);
    color([0.99, 0.99, 0.99]) translate([-48, -54, -40]) cube([96, 98, 0.5]);
    color([0.45, 0.46, 0.5]) difference() { translate([-49, -55, -40.4]) cube([98, 100, 0.5]); translate([-48, -54, -41]) cube([96, 98, 2]); }
}
