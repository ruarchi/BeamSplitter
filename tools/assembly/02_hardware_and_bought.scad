// Step 02 picture: the printed hardware (plates 11-15) with the number needed, and the bought parts (stand-ins).
include <scene_lib.scad>

RX = 38;                        // camera tilt (--camera=...,RX,0,0,...): labels face it
R  = [RX, 0];
DX = 54;                        // grid pitch
module say(txt, at, size, bold = true, halign = "center") color(C_INK) translate(at) billboard(R) linear_extrude(0.3)
    text(txt, size = size, halign = halign, valign = "center", font = bold ? "Liberation Sans:style=Bold" : "Liberation Sans");

// " x " -> " \u00d7 " (multiplication sign)
function times(t) = chr([for (i = [0 : len(t) - 1])
    t[i] == "x" && i > 0 && i < len(t) - 1 && t[i - 1] == " " && t[i + 1] == " " ? 215 : ord(t[i])]);
function hw_size(e) = str(e[0] == "pin25" || e[0] == "pin12" || e[0] == "f38_pin" ? "\u00d8" : "", times(e[2]));

// printed hardware: 6 + 5, standing as printed
say("Printed hardware", [-30, 42, 0], 7.5, true, "left");
for (k = [0 : len(HW_LIST) - 1]) let(e = HW_LIST[k], col = k % 6, row = floor(k / 6), p = [col * DX, -row * 78, 0]) {
    translate(p) new1() hw_piece(e[0]);
    say(e[1], p + [0, -17, 0], 4.4);
    say(hw_size(e), p + [0, -24.5, 0], 3.9, false);
    say(str(e[0] == "clip" ? "about 60" : str("need ", e[3]), "  (plate ", e[4], ")"), p + [0, -31.5, 0], 3.9, false);
}

// bought parts (stand-ins; the glass is drawn smaller than it is)
YB = -190;
say("Bought parts (simple stand-ins)", [-30, YB + 58, 0], 7.5, true, "left");
translate([-30, YB - 12, 0]) scale(0.36) glass_bench();
say("glass 150 \u00d7 150 \u00d7 2, 50/50", [-3, YB - 30, 0], 4.2);
say("(drawn smaller)", [-3, YB - 37, 0], 3.6, false);
translate([67, YB + 8, 0]) f38_base_box();
translate([120, YB + 8, 0]) f38_plate_box();
say("2 F38 quick-release kits", [92, YB - 30, 0], 4.2);
say("(base and plate)", [92, YB - 37, 0], 3.6, false);
for (i = [0 : 2]) translate([166 + 16 * i, YB + 2, 0]) qtr_screw(i == 2 ? 12.5 : qtr_screw_len);
say("3 steel 1/4\"-20 screws", [182, YB - 30, 0], 4.2);
say("2 \u00d7 9.5 mm (3/8\")", [182, YB - 37, 0], 3.6, false);
say("1 \u00d7 plate screw + 3 mm", [182, YB - 43.5, 0], 3.6, false);
translate([232, YB + 2, 0]) color(C_BRASS) difference() { cylinder(d = 8.8, h = 8, $fn = 32); translate([0, 0, -1]) cylinder(d = 6.35, h = 10, $fn = 32); }
say("heat-set insert", [232, YB - 16, 0], 4.2);
say("1/4\"-20 \u00d7 8 mm", [232, YB - 23, 0], 3.6, false);
translate([258, YB - 10, 0]) felt_sheet(40, 26);
say("felt 0.5 mm", [278, YB - 30, 0], 4.2);
say("self-adhesive", [278, YB - 37, 0], 3.6, false);
