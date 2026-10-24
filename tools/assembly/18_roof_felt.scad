// Step 18: felt on the channel roof (docs/ASSEMBLY.md).  Seen from inside the rig as in step 17, with the +X rib's
// roof and bosses cut away so the felt shows: four green pieces on the roof underside, along its inner edge (over
// the glass edge, about 1.6 mm wide), with gaps at the three thumbscrew holes (blue axes).  The strip is already in.
// Camera (the labels are placed for it): --camera=77,6,174,62,0,280,195
include <scene_lib.scad>

clip_to(CLIP_NO_NX) frame_roof_off(sides = [1], ghost_a = 0);
done() strips_part(sides = [1]);  color(C_FELT) { felt_lip(sides = [1]); felt_endpad(sides = [1]); }
color(C_FELT) felt_roof(sides = [1]);
for (i = [0 : 2]) line3(gs_pt(1, i, w_hi + boss_h + 25), gs_pt(1, i, w_hi - 2), 1.4, C_NEW2);

// labels: in a plane a little in front of the rib, facing the camera (rx, rz); sizes keep the text about the same on screen
R = [62, 280];
UP = [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])];       // label "up" (next line = -1.5 * size * UP)
// two-line label; the leader (thin: this view is close up) runs from the left end of the first line to `to`
module tag2(l1, l2, at, size, to = undef) {
    tag(l1, at, R, size = size);
    tag(l2, at - 1.5 * size * UP, R, size = size);
    if (!is_undef(to)) let(a = at - 1.2 * size * [cos(R[1]), sin(R[1]), 0]) color(C_INK) {
        hull() { translate(a) sphere(d = 0.25, $fn = 8); translate(to) sphere(d = 0.25, $fn = 8); }
        translate(to) sphere(d = 1.3, $fn = 16);
    }
}
FW = x_gb - x_ul;                    // roof felt width (1.6 mm by default)
tag2("roof felt: 4 pieces,", str("about ", FW, " mm wide, no wider"), [54.9, -4.5, 181.1], 1.43, to = pl2w([(x_ul + x_gb) / 2, 0, w_hi - felt_t / 2]));
tag2("gap at each", "thumbscrew hole", [55.3, 5.6, 166.5], 1.5, to = pl2w([(x_ul + x_gb) / 2, preload_v[1], w_hi - felt_t / 2]));
tag2("lip felt", "(step 15)", [53.6, -21.8, 196.0], 1.34, to = pl2w([x_lip + 1.5, -25, -felt_t / 2]));
tag("roof and bosses cut away in this picture", [48.9, 1.7, 156.6], R, size = 1.5);
