// Step 17: check the strips (docs/ASSEMBLY.md).  Seen from inside the rig (from the -X side, the -X half left out).
// The +X rib's roof and thumbscrew bosses are cut away so the strip in its channel shows: end cap home
// against the closed lower-rear end, the two spring bumps standing up into the roof, and a low notch under each
// thumbscrew axis (blue), so the screws reach the glass and never the strip.
// Camera (the labels are placed for it): --camera=78,2,176,62,0,280,270
include <scene_lib.scad>

clip_to(CLIP_NO_NX) frame_roof_off(sides = [1], ghost_a = 0);
new1() strips_part(sides = [1]);  color(C_FELT) { felt_lip(sides = [1]); felt_endpad(sides = [1]); }
for (i = [0 : 2]) line3(gs_pt(1, i, w_hi + boss_h + 25), gs_pt(1, i, strip_floor), 1.4, C_NEW2);

// labels: in a plane a little in front of the rib, facing the camera (rx, rz); sizes keep the text about the same on screen
R = [62, 280];
UP = [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])];       // label "up" (next line = -1.5 * size * UP)
module tag2(l1, l2, at, size, to = undef, halign = "left") {
    tag(l1, at, R, to = to, size = size, halign = halign);
    tag(l2, at - 1.5 * size * UP, R, size = size, halign = halign);
}
tag2("roof and bosses cut away", "in this picture", [72.7, 6.6, 227.6], 2.0);
tag("glass thumbscrew axes", [71.4, 11.2, 218.2], R, to = gs_pt(1, 0, w_hi + boss_h + 25), size = 2.0);
tag2("notch: the thumbscrew", "presses only the glass", [54.8, 2.8, 168.5], 2.1, to = pl2w(STRIP_NOTCH[1]));
tag2("spring bump presses", "on the roof", [53.5, 17.9, 151.2], 2.2, to = pl2w(STRIP_BUMPS[1]));
tag("end cap home", [54.7, 38.9, 130.2], R, to = pl2w(STRIP_CAP), size = 2.3);
