// Cross-section of the glass groove (docs/img/groove_section.png).
// An exact cut through the +X glass rib at the middle glass thumbscrew, drawn in the plate's own frame:
// x across the rig (glass centre to the left), w along the plate normal (up = the uncoated back of the glass).
// In the rig this whole picture is tilted 45°.  The glass and felt are not printed; they are drawn as plain bars.
// Render with tools/render_images.sh, or open it in OpenSCAD and press F5 (it uses the model's current parameters).
include <../model/beamsplitter_rig.scad>
part = "none";              // the model draws nothing by itself; this file draws the section

V     = preload_v[1];       // section plane: the middle thumbscrew
tip_w = plate_t + felt_t;   // thumbscrew tip: its felt disc presses on the back of the glass
x_l   = 58;                 // left end of the glass as drawn
lx    = 56;                 // labels end here (right-aligned)
ink   = [0.15, 0.15, 0.15];

module cut(z) translate([0, 0, z]) linear_extrude(0.2) projection(cut = true)
    translate([0, 0, V]) rotate([-90, 0, 0]) children();
module bar(x0, x1, w0, w1, z) translate([x0, w0, z]) cube([x1 - x0, w1 - w0, 0.2]);
module label(t, w, to) color(ink) translate([0, 0, 2]) {
    translate([lx, w]) linear_extrude(0.1) text(t, size = 1.2, halign = "right", valign = "center", font = "Liberation Sans");
    hull() for (p = [[lx + 0.6, w], to]) translate(p) cylinder(d = 0.16, h = 0.1, $fn = 8);
    translate(to) cylinder(d = 0.55, h = 0.1, $fn = 16);
}

color([0.45, 0.46, 0.5])  cut(0.0) rib_local();
color("tomato")           cut(0.3) groove_strip_local();
color([1.0, 0.68, 0.35])  cut(0.6) translate([x_pl, V, tip_w + ps_len + ps_head[1]]) rotate([0, 180, 0]) preload_screw();
color([0.35, 0.62, 0.95]) bar(x_l, strip_glass[0] / 2, 0, plate_t, 0.9);              // glass (coated face at w = 0)
color([0.8, 0.74, 0.58])  bar(x_lip, x_gb_s, -felt_t, 0, 0.9);                         // felt on the lower lip
color([0.1, 0.1, 0.1])    bar(x_pl - 4, x_pl + 4, plate_t, tip_w, 0.9);              // Ø8 felt disc on the thumbscrew tip

label("glass thumbscrew, M10 x 2 (printed)",       18.5, [67.5, 18.5]);
label("frame: glass rib with threaded boss",          9, [67.2, 9]);
label("felt disc on the thumbscrew tip",            2.9, [70, 2.25]);
label("glass, 2 mm, coated face down",              1.0, [61, 1.0]);
label("0.5 mm felt: the angle reference",          -1.3, [74.5, -0.25]);
label("groove strip (swappable)",                  -4.5, [75.6, -1.0]);
label("seat face: sets the 45° glass angle",       -8.0, [76.5, -1.5]);
color(ink) translate([lx - 26, -14, 2]) linear_extrude(0.1)
    text("Section through a glass thumbscrew, square to the glass (in the rig the glass sits at 45°)",
         size = 1.0, font = "Liberation Sans");
