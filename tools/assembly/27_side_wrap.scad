// Step 27: wrap both open sides with black foil (stand-in, see-through here) held by printed wrap clips through the
// 4 mm holes along the frame members (shown on the -X side).  Inset: one clip in a side member, enlarged.
// Camera: --camera=-95,50,120,75,0,300,850
include <scene_lib.scad>

C = [-95, 50, 120];  R = [75, 300];                        // camera centre and [rx, rz]
E = [sin(R[1]) * sin(R[0]), -cos(R[1]) * sin(R[0]), cos(R[0])];   // toward the camera
// a point in the screen plane through the camera centre: x to the right, y up, z toward the camera (mm)
function scr(x, y, z = 0) = C + x * [cos(R[1]), sin(R[1]), 0] + y * [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])] + z * E;

built(S_WRAP);
foil_side(-1);
new1() for (p = side_wrap_holes()) wrap_clip_side(p[0], p[1], -1);

HOLE = side_wrap_holes()[2];                               // one clip on the diagonal rib (for the leader)
tag("black foil over each open side", scr(-222, 140), R, size = 7);
tag("(Cinefoil; test it in IR)", scr(-118, 127), R, to = [-wall_out - 0.3, 52, 222], size = 7, halign = "right");
tag("wrap clips in the 4 mm holes", scr(-88, 108), R, to = [-wall_out - 2, HOLE[0], HOLE[1]], size = 7, halign = "right");
tag("hang a cloth skirt from", scr(-222, 30), R, size = 7);
tag("the rear deck edge holes", scr(-110, 18), R, to = [-60, y_back, deck_top - 3], size = 7, halign = "right");

// inset (lower left): one clip in a side member, cut through the hole, 3 x
module ink(txt, at, size = 4) color(C_INK) translate(at) linear_extrude(0.4)
    text(txt, size = size, halign = "left", valign = "center", font = "Liberation Sans:style=Bold");
module clip_section() {
    k = 3;  m = wrap_grip[0] - 0.3;                       // side member thickness (the clip grips member + foil)
    translate([-34, 18, 0]) scale(k) {
        color(C_FRAME) for (s = [-1, 1]) translate([0, s > 0 ? 2.2 : -8, 0]) cube([m, 5.8, 3]);    // member, 4 mm hole
        color([0.08, 0.08, 0.09]) translate([-0.3, -9, 0]) cube([0.3, 18, 3]);
        new1() translate([-0.3, 0, 0]) rotate([0, 0, -90]) wrap_clip(wrap_grip[0]);
    }
    ink("outside", [-50, 48], 3.6);  ink("inside", [-28, 48], 3.6);
    ink("T-head on the foil,", [8, 30]);
    ink("barbs open behind", [8, 22]);
    ink("the member", [8, 14]);
    ink("remove: pinch the barbs with pliers", [-48, -15]);
    ink("grip: 8.5 mm side members,", [-48, -25]);
    ink("6.5 base and lid, 4.5 deck ribs", [-48, -33]);
    color([0.99, 0.99, 0.99]) translate([-52, -40, -1]) cube([120, 94, 0.5]);
    color([0.45, 0.46, 0.5]) translate([-53, -41, -1.4]) cube([122, 96, 0.5]);
}
translate(scr(-167, -106)) billboard(R) clip_section();
