// Step 06 picture: the bare frame lying on its -X side on a cloth, base toward the viewer; the 1/4"-20 heat-set insert
// (brass) set on the hole under the base at the crosswall foot and pressed in with the soldering iron.
include <scene_lib.scad>
include <screen_labels.scad>
CAM = [20, 60, 100, 70, 138, 640];      // = --camera=20,60,100,70,0,138,640

INS_OUT = 35;      // insert held this far out of its hole, the iron behind it
// the frame on its -X side: world z (up) becomes -x, world x becomes z (so the -X side lies on the cloth)
module on_side() translate([0, 0, wall_out]) rotate([0, -90, 0]) children();
color([0.80, 0.78, 0.70]) translate([-frame_top - 40, y_front - 40, -1]) cube([frame_top + 120, y_back - y_front + 80, 1]);
on_side() {
    built(S_INSERT);
    heat_insert(dz = -INS_OUT);
    soldering_iron([tri_xy[0], tri_xy[1], -INS_OUT - 2], [0, 0, -1]);
    arrow([16, tri_xy[1], -INS_OUT - 30], [16, tri_xy[1], -8], d = 3);
}

// labels (world points: the frame-local point [x, y, z] lies at [-z, y, x + wall_out])
function os(p) = [-p[2], p[1], p[0] + wall_out];
lab("1/4\"-20 \u00d7 8 mm heat-set insert:", [30, 300], os([tri_xy[0] + 4, tri_xy[1] - 4, -INS_OUT + tri_ins_dep]));
lab("press it in slowly and square", [30, 335]);
lab("until it is flush", [30, 370]);
lab("frame on its side, on a cloth", [40, 960], [-150, y_front, 0]);
