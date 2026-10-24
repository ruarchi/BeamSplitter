// Step 10: fit the rear carriage on the rear deck (docs/ASSEMBLY.md).  T-nuts (blue) slid into the deck's T-slot from
// its end; the carriage (orange, its T-bolts in) lowered onto the rail; datum pins and clamp thumbscrews (blue) above.
// Camera (the labels are placed for it): --camera=10,135,155,50,0,225,600
include <scene_lib.scad>

R = [50, 225];                       // label rotation = camera rx, rz
CZ = 40;  PZ = 75;  SZ = 125;        // explode heights: carriage, datum pins, clamp thumbscrews
ct = deck_top + CZ + t_rear_carriage;                                // carriage top while lowered

built(S_REAR_CAR, hide = ["lid"]);
new2() c_tnuts("rear");
arrow([wall_out + 40, y_rrail, deck_top - 8], [wall_out + 5, y_rrail, deck_top - 8], d = 2.5);   // nuts go in at the deck end
new1() { carriage_part("rear", dz = CZ); c_slide_bolts("rear", dz = CZ); }
new2() { c_datum_pins("rear", dz = PZ); c_clamp_screws("rear", dz = SZ); }
// pins and clamp thumbscrews go straight down into the carriage
for (s = [-1, 1]) {
    arrow([s * rc_clamp_x, y_rrail, deck_top + SZ - 14], [s * rc_clamp_x, y_rrail, ct + 3], d = 1.8);
    arrow([s * rc_datum_sep / 2, y_rrail - rc_idx_off, deck_top + PZ - 11], [s * rc_datum_sep / 2, y_rrail - rc_idx_off, ct + 3], d = 1.8);
}

tag("clamp thumbscrews", [58.5, 146.5, 248.1], R, to = [rc_clamp_x, y_rrail, deck_top + SZ + 10], size = 6, halign = "right");
tag("finger-tight",      [55.1, 149.9, 242.4], R, size = 6, halign = "right");
tag("datum pins = zero", [64.8, 146.1, 191.4], R, to = [rc_datum_sep / 2, y_rrail - rc_idx_off, deck_top + PZ + 4], size = 6, halign = "right");
tag("T-nuts: in from the end", [139, 140.7, 106], R, size = 6, halign = "right");
