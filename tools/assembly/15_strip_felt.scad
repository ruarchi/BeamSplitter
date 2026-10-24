// Step 15: the groove strip and its felt (docs/ASSEMBLY.md).  No rig: the +X strip (orange, felt green) seen from
// its inner side, end cap on the left, pull-hole end on the right; below it three close-ups (end cap with its 2-layer
// pad, a leaf spring with its bump, the pull hole) and an end view of its cross-section.
// Camera (the labels are placed for it): --camera=0,0,-37,62,0,20,450
include <scene_lib.scad>

R = [62, 20];  fs = 4.2;             // label rotation = camera rx, rz; label size
Z1 = -40;  Z2 = -88;                 // rows: close-ups, cross-section
P = [v_s0 - 0.01, v_s0 + 16];  S = [spring_v[0] - 16, spring_v[0] + 16];  E = [v_es_s - 12, v_s1 + 1];
KP = 3;  KS = 2.5;  KE = 3;  KX = 6; // magnifications
XP = 82;  XS = 0;  XE = -82;         // close-up positions along X

strip_view();
translate([XE, 0, Z1]) strip_zoom(E[0], E[1], KE);
translate([XS, 0, Z1]) strip_zoom(S[0], S[1], KS);
translate([XP, 0, Z1]) strip_zoom(P[0], P[1], KP);
translate([0, 0, Z2]) strip_section(0, KX);

// labels (a little in front of the parts, facing the camera)
module dot_line(a, b) color(C_INK) { hull() { translate(a) sphere(d = 0.7, $fn = 8); translate(b) sphere(d = 0.7, $fn = 8); }
                                     translate(b) sphere(d = 2.2, $fn = 16); }
ECAP = [-75.9, -10.3, 16.5];      // end-cap label (two lines)
NA = [-13.1, -1.4, 23.9];            // the notch label: leaders to all three notches
tag("low notch under each glass thumbscrew", NA, R, size = fs);
for (n = STRIP_NOTCH) dot_line(NA - 0.6 * fs * [cos(R[1]), sin(R[1]), 0], sv_pt(n));
UP = [-sin(R[1]) * cos(R[0]), cos(R[1]) * cos(R[0]), sin(R[0])];     // label "up" (next line = -1.5 * fs * UP)
tag("end cap:", ECAP, R, to = sv_pt(STRIP_CAP), size = fs, halign = "right");
tag("goes in first", ECAP - 1.5 * fs * UP, R, size = fs, halign = "right");
tag("felt: 2 layers", [-105.2, -41.0, -52.3], R, to = [XE, 0, Z1] + sz_pt([x_lip + 0.5, v_es_s - 0.5, 1.5], E[0], E[1], KE), size = fs);
tag("leaf spring + bump", [11.1, -1.7, -15.2], R, to = [XS, 0, Z1] + sz_pt(STRIP_BUMPS[0], S[0], S[1], KS), size = fs);
tag("pull hole", [71.4, -14.7, -9.1], R, to = [XP, 0, Z1] + sz_pt([x_gb_s, STRIP_PULL[1], STRIP_PULL[2]], P[0], P[1], KP), size = fs);
tag("felt: 1 layer on the lip", [39.2, -28.8, -54.9], R, to = [XS, 0, Z1] + sz_pt([x_lip + 1.5, S[0] + 4, 0], S[0], S[1], KS), size = fs);
tag("thin lip + felt:", [-22.2, -18.0, -82.5], R, to = [0, 0, Z2] + ss_pt([x_lip + 1.5, 0, 0], KX), size = fs, halign = "right");
tag("toward the middle", [-22.2, -18.0, -82.5] - 1.5 * fs * UP, R, size = fs, halign = "right");
tag("step: over the ridge", [31.9, -6.7, -89.7], R, to = [0, 0, Z2] + ss_pt([key_x[0] - 0.6, 0, w_seat + 0.4], KX), size = fs);
