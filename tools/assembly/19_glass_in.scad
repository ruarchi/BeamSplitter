// Step 19: slide the glass in, coated face down.  Seen from slightly below so the coated face (yellow) shows.
// Inset (lower right): the pen test, glass seen edge-on.
// Camera: --camera=0,-30,195,99,0,310,800
include <scene_lib.scad>

C = [0, -30, 195];  R = [99, 310];                         // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

built(S_GLASS, hide = ["cams"]);
glass_w(shift = 80);                                       // blue glass, coated (lower) face yellow
arrow(pl2w([0, -190, -15]), pl2w([0, -128, -15]), d = 4);  // slide along the grooves, toward the lower rear

tag("coated face DOWN", scr(-75, 125, 60), R, to = pl2w([-55, -135, -0.3]), size = 8.5, halign = "right");
tag("slide in from the top-front", scr(-75, 109, 60), R, size = 6.5, halign = "right");
tag("rests on the felt", scr(95, -40), R, to = pl2w([x_lip + 1, v_es_s - 0.5, 1]), size = 8);
tag("of both end caps", scr(95, -54), R, size = 8);

// inset: the pen test, glass edge-on (drawn as if seen level from the front, then turned to face the camera;
// glass and coating thickness exaggerated)
module pen_short(tip, dir, a = 1) translate(tip) orient_to(dir) {
    color([0.2, 0.2, 0.25, a]) cylinder(d1 = 0.6, d2 = 7, h = 9, $fn = 24);
    color([0.15, 0.3, 0.75, a]) translate([0, 0, 9]) cylinder(d = 8, h = 10, $fn = 24);
}
module slab(coat_top) {
    color([0.55, 0.85, 1.0]) translate([-20, -2, 0]) cube([40, 4, 4]);
    color([1.0, 0.8, 0.1]) translate([-20, -2.2, coat_top ? 4 : -1.4]) cube([40, 4.4, 1.4]);
}
module ink(txt, x, z, size = 5) color(C_INK) translate([x, -4, z]) rotate([90, 0, 0])
    linear_extrude(0.4) text(txt, size = size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
module pen_test() {
    translate([-24, 0, 0]) { slab(true);  pen_short([0, 0, 5.4], [0.3, 0, 1]); pen_short([0, 0, 5.4], [0.3, 0, -1], 0.3); }
    translate([24, 0, 0])  { slab(false); pen_short([0, 0, 4], [0.3, 0, 1]);   pen_short([0, 0, -2.8], [0.3, 0, -1], 0.3); }
    ink("pen test: look at the reflection", 0, 29, 4.6);
    ink("touches:", -26, -24);  ink("coated face", -26, -31);
    ink("gap:", 26, -24);       ink("uncoated face", 26, -31);
    color([0.99, 0.99, 0.99]) translate([-54, 6, -37]) cube([108, 0.5, 72]);
    color([0.45, 0.46, 0.5]) difference() { translate([-55, 5.6, -38]) cube([110, 0.5, 74]); translate([-54, 4, -37]) cube([108, 4, 72]); }
}
translate(scr(146, -113)) billboard(R) rotate([-90, 0, 0]) pen_test();
