// Step 13: rear slide onto its carriage (docs/ASSEMBLY.md).  Slide (orange) with its F38 base (dark red) set on the
// carriage at its starting position (7 mm forward of the slot middle), T-bolts up through the slots; thumb-nuts (blue)
// above; a pencil mark on the carriage along the slide's back edge.
// Camera (the labels are placed for it): --camera=0,140,130,45,0,215,420
include <scene_lib.scad>

R = [45, 215];                       // label rotation = camera rx, rz
NZ = 30;                             // thumb-nuts held above their bolts
st = deck_top + t_rear_carriage;     // carriage top = slide underside
sl = [2 * slide_hw, slide_len(rear_travel)];   // rear slide footprint (X, Y)
yb = y_rear_sock + sl[1] / 2;        // slide back edge

built(S_REAR_SLIDE, hide = ["lid"]);
new1() slide_part("rear");
f38_base_w("rear");  done() f38_pins("rear");
new2() c_slide_nuts("rear", dz = NZ);
for (s = [-1, 1]) arrow([s * slide_bolt_x + stereo_rear, y_rrail, st + t_slide + NZ - 2], [s * slide_bolt_x + stereo_rear, y_rrail, st + t_slide + 9], d = 2);
// pencil mark on the carriage top, along the slide's back edge, beside each back corner
color(C_INK) for (s = [-1, 1]) translate([stereo_rear + s * (sl[0] / 2 - 12) - 0, yb + 0.3, st]) translate([s < 0 ? -8 : 0, 0, 0]) cube([20, 1.2, 0.3]);

// several label lines stacked under each other (the leader from the first line); card = a pale backing card
function bb_up(rot) = [-sin(rot[1]) * cos(rot[0]), cos(rot[1]) * cos(rot[0]), sin(rot[0])];
module tagn(lines, at, rot, to = undef, size = 6, halign = "left", card = false) {
    for (i = [0 : len(lines) - 1])
        tag(lines[i], at - i * 1.5 * size * bb_up(rot), rot, to = i == 0 ? to : undef, size = size, halign = halign);
    if (card) let(w = max([for (l = lines) 0.8 * size * len(l)]), x0 = halign == "left" ? 0 : halign == "right" ? -w : -w / 2,
                  h = (len(lines) - 1) * 1.5 * size + 1.6 * size)
        color([1, 1, 1]) translate(at) billboard(rot) translate([x0 - 0.5 * size, -h + 0.8 * size, -0.8]) cube([w + size, h, 0.3]);
}

tagn(["thumb-nuts", "finger-tight"], [45.8, 141.4, 164.7], R, to = [slide_bolt_x + stereo_rear + 5, y_rrail, st + t_slide + NZ + 4], size = 4.5, halign = "right");
tagn(["start: slide", "7 mm forward of", "slot middle"], [-66.7, 157.1, 165.0], R,
     to = [-slide_bolt_x + stereo_rear, y_rear_sock - 10, st + t_slide], size = 4, card = true);
tagn(["pencil mark"], [-60, 175, 125], R, to = [stereo_rear - (sl[0] / 2 - 2), yb + 0.9, st + 0.3], size = 4.5, card = true);
