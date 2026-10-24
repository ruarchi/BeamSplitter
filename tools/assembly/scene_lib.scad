// Shared helpers for the assembly-guide pictures (docs/img/assembly/NN_*.png, see docs/ASSEMBLY.md).
//
// Use it from a scene file in this folder (tools/assembly/):
//
//     include <scene_lib.scad>
//     stereo_rear = 20;               // any model parameter can be overridden AFTER the include line
//     built(S_GLASS);                 // everything fitted before the glass step: frame dark grey, parts light grey
//     new1() glass_w(shift = 60);     // this step's new part, orange
//     arrow(pl2w([0, -150, 20]), pl2w([0, -95, 20]));
//
// The model is INCLUDED (not used), so a scene can read every model value (Zs, lid_bolts, preload_v, ...) and
// override parameters.  part = "none" keeps the model from drawing anything by itself.
// Render a scene with OpenSCAD's preview, 1400 x 1050, e.g. from the repository root:
//     openscad -o docs/img/assembly/NN_name.png --preview --imgsize=1400,1050 --colorscheme=Tomorrow \
//              --camera=cx,cy,cz,rx,0,rz,dist tools/assembly/NN_name.scad
// Camera: rx = 0 looks straight down, 90 is level, > 90 looks up from below; rz = 0 puts the camera at the front
// (scene side, -Y), rz > 0 swings it toward +X, 180 is behind the rig, 270 at -X.
//
// Colours: the frame is dark grey, parts fitted in earlier steps light grey, this step's new parts orange (C_NEW;
// a second kind of new part in the same step blue, C_NEW2), arrows red.  Bought parts that the model does not draw
// (felt, heat-set insert, F38 base / plate, steel screws, foil, flocking, paper clip) are simple stand-ins defined here.
// Nothing in this file changes the model: placements copy the model's own world positions.

include <../../model/beamsplitter_rig.scad>
part       = "none";     // the model draws nothing; the scene does
clip_check = false;      // no stereo ray sampling (it only feeds the console readout)
show_fov   = false;
show_hood  = false;

// Colours
C_FRAME = [0.46, 0.47, 0.51];        // the frame
C_DONE  = [0.74, 0.75, 0.78];        // parts fitted in earlier steps
C_NEW   = [1.00, 0.45, 0.05];        // this step's new parts
C_NEW2  = [0.12, 0.55, 1.00];        // a second kind of new part in the same step
C_ARROW = [0.86, 0.06, 0.10];        // arrows, turn arrows
C_GHOST = [0.62, 0.63, 0.68, 0.22];  // see-through context
C_GLASS = [0.55, 0.85, 1.00, 0.40];  // beam-splitter glass
C_COAT  = [1.00, 0.80, 0.10, 0.85];  // the coated face of the glass
C_FELT  = [0.35, 0.78, 0.25];        // felt (stand-in colour; real felt is usually black)
C_BRASS = [0.86, 0.66, 0.22];        // heat-set insert
C_STEEL = [0.58, 0.60, 0.64];        // steel screws, paper clip
C_F38   = [0.55, 0.12, 0.12];        // F38 quick-release base / plate (as in the model)
C_FOIL  = [0.08, 0.08, 0.09, 0.55];  // black foil wrap
C_FLOCK = [0.05, 0.05, 0.06];        // flocking film
C_PAINT = [0.10, 0.10, 0.11];        // matt black paint
C_INK   = [0.12, 0.12, 0.12];        // labels

// In OpenSCAD the OUTER color() wins, so these also recolour parts that set their own colour inside (glass,
// cameras, F38 stand-ins).  Leave the glass unwrapped to keep it blue with its coated face marked.
module done()  color(C_DONE)  children();
module new1()  color(C_NEW)   children();
module new2()  color(C_NEW2)  children();
// See-through context.
module ghost(a = 0.22) color([C_GHOST[0], C_GHOST[1], C_GHOST[2], a]) children();

function has(list, x) = len([for (e = list) if (e == x) 1]) > 0;

// Felt disc on each glass-thumbscrew tip.  8 mm, not the 10 mm thread size: the disc goes through the boss thread
// with the screw, and the boss thread's minor bore is 2 * (ps_d / 2 + ps_clear - thr_h(ps_pitch)) = 8.8 mm.
FELT_DISC_D = 8;

// Arrows
// Rotate +Z onto direction v.
module orient_to(v) let(L = norm(v)) rotate([0, acos(v[2] / L), atan2(v[1], v[0])]) children();
// Straight arrow from `from` to `to` (the head touches `to`).  d = shaft diameter.
module arrow(from, to, d = 2.5, c = C_ARROW) let(v = to - from, L = norm(v), hl = min(0.45 * L, 4 * d))
    color(c) translate(from) orient_to(v) {
        cylinder(d = d, h = L - hl + 0.01, $fn = 24);
        translate([0, 0, L - hl]) cylinder(d1 = 2.6 * d, d2 = 0, h = hl, $fn = 32);
    }
// Double-headed arrow (travel ranges).
module arrow2(a, b, d = 2.5, c = C_ARROW) let(m = (a + b) / 2) { arrow(m, a, d, c); arrow(m, b, d, c); }
// Curved "turn" arrow in the local XY plane around +Z, radius r, sweeping `a` degrees.  cw = true: clockwise when
// seen from +Z (looking down -Z).
module turn_arrow(r = 10, a = 270, d = 1.6, cw = true, c = C_ARROW) color(c)
    if (cw) mirror([0, 1, 0]) turn_arrow_ccw(r, a, d); else turn_arrow_ccw(r, a, d);
module turn_arrow_ccw(r, a, d) {
    rotate_extrude(angle = a, $fn = 64) translate([r, 0]) circle(d = d, $fn = 12);
    rotate([0, 0, a]) translate([r, 0, 0]) rotate([-90, 0, 0]) cylinder(d1 = 3 * d, d2 = 0, h = 4 * d, $fn = 24);
}
// Turn arrow around a screw axis: pos = a point on the axis (usually just above the head), tipdir = the direction the
// screw advances when tightened.  tighten = true: clockwise as seen from the head (right-hand thread).
module screw_turn(pos, tipdir, r = 12, tighten = true, a = 270, d = 1.6, c = C_ARROW)
    translate(pos) orient_to(-tipdir) turn_arrow(r, a, d, tighten, c);
// Thin line (axes, leader lines without a label).
module line3(a, b, d = 0.8, c = C_INK) color(c) hull() { translate(a) sphere(d = d, $fn = 8); translate(b) sphere(d = d, $fn = 8); }

// Labels
// Flat text that faces a camera with --camera=...,rx,0,rz,... : pass rot = [rx, rz].
module billboard(rot) rotate([0, 0, rot[1]]) rotate([rot[0], 0, 0]) children();
// Label at `at`; with `to`, a thin leader line from the nearer end of the text to `to` and a dot there.  The text
// width is estimated (0.58 x size per character), so the leader starts just outside the text, not across it.
function tag_w(txt, size) = 0.58 * size * len(txt);
module tag(txt, at, rot, to = undef, size = 6, halign = "left", c = C_INK) color(c) {
    translate(at) billboard(rot) linear_extrude(0.4)
        text(txt, size = size, halign = halign, valign = "center", font = "Liberation Sans:style=Bold");
    if (!is_undef(to)) {
        ux = [cos(rot[1]), sin(rot[1]), 0];
        w  = tag_w(txt, size);
        x0 = halign == "left" ? 0 : halign == "right" ? -w : -w / 2;      // text extent along ux, from `at`
        ends = [at + (x0 - 0.6 * size) * ux, at + (x0 + w + 0.6 * size) * ux];
        a = norm(ends[0] - to) <= norm(ends[1] - to) ? ends[0] : ends[1];
        hull() { translate(a) sphere(d = 0.7, $fn = 8); translate(to) sphere(d = 0.7, $fn = 8); }
        translate(to) sphere(d = 2.2, $fn = 16);
    }
}

// Clipping
// Cut-away: built(..., clip = [lo, hi]) keeps only what lies inside the box lo..hi (each part is cut separately,
// so the colours stay).  cl() is the per-part cut; it reads $clip.  The box is coloured so the cut faces take the
// part's colour (an uncoloured box would show the cut faces in the preview's default yellow).  With many clipped
// parts the preview can still paint cut faces gold or green: then cut only the frame (built(..., fclip = box)).
C_CUT = [0.60, 0.61, 0.65];
module cl() if (is_undef($clip)) children();
            else intersection() { children(); color(C_CUT) translate($clip[0]) cube($clip[1] - $clip[0]); }
// Same cut for anything outside built(): clip_to([lo, hi]) children
module clip_to(box) let($clip = box) cl() children();
CLIP_NO_PX = [[-500, -500, -50], [0, 500, 500]];       // remove the +X half (like the model's cutaway)
CLIP_NO_NX = [[0, -500, -50], [500, 500, 500]];        // remove the -X half
// Plate-local cuts (x, v, w as in place_plate(); box = [lo, hi]); sides = which rib (+1 / -1).
module pl_box(box, sides = [1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate() translate(box[0]) cube(box[1] - box[0]);
module pl_cut(box, sides = [1]) difference() { children(); color(C_CUT) pl_box(box, sides); }
module pl_keep(box, sides = [1]) intersection() { children(); color(C_CUT) pl_box(box, sides); }
// The groove-zone roof of a rib (upper flank, the three thumbscrew bosses), cut off just below the channel roof
// (between the strip top and the roof) so the strip in its channel shows from behind / above.  The side plane
// (|x| >= inner_hw) stays.
ROOF_BOX = [[60, v_top - 12, w_hi - strip_top_clr / 2], [inner_hw - 0.05, v_bot + 6, 40]];
// frame with the roof of the chosen rib(s) cut away; ghost_a > 0 also draws the removed roof see-through
module frame_roof_off(sides = [1], ghost_a = 0.16) {
    color(C_FRAME) pl_cut(ROOF_BOX, sides) frame();
    if (ghost_a > 0) ghost(ghost_a) pl_keep(ROOF_BOX, sides) frame();
}

// Placements (world)
// Carriage-local frame (as the model's carriage_hw): z = 0 on the rail face, +z away from the rail
// (rear carriage: up; bottom carriage: toward the front, -Y).  local x = world X.
// Rear: local y = world Y.  Bottom: local y = world Z (up).  Includes the current stereo offset.
module carriage_frame(which) if (which == "rear") translate([stereo_rear, y_rrail, deck_top]) children();
                             else translate([-stereo_bot, y_wf, wr_z]) rotate([90, 0, 0]) children();
function car_t(w)    = w == "rear" ? t_rear_carriage : bc_t;
function car_cx(w)   = w == "rear" ? rc_clamp_x : bc_clamp_x;
function car_dsep(w) = w == "rear" ? rc_datum_sep : bc_datum_sep;
function car_off(w)  = w == "rear" ? rc_idx_off : wr_off;
function car_yc(w)   = w == "rear" ? 0 : bc_bolt_z - wr_z;
function car_vern(w) = w == "rear" ? rc_vern : bc_vern;
function car_shift(w) = w == "rear" ? stereo_rear : -stereo_bot;   // carriage offset along world X
// Explode offsets below are along local +z (dz) or local x (dx, along the rail).
module carriage_part(w, dz = 0) carriage_frame(w) translate([0, 0, dz])
    if (w == "rear") rear_carriage_local(); else bottom_carriage_local();
module c_clamp_screws(w, dz = 0) carriage_frame(w) for (s = [-1, 1])
    translate([s * car_cx(w), 0, clamp_seat + cs_head[1] + dz]) rotate([180, 0, 0]) clamp_screw();
// the two T-nuts in the rail's T-slot under the clamp screws (bevels toward the slot opening)
module c_tnuts(w, dx = 0) carriage_frame(w) for (s = [-1, 1])
    translate([s * car_cx(w) + dx, 0, nut_top_z - tn_t]) rotate([0, 0, 90]) tnut();
// the two slide T-bolts, square head in the diamond pocket under the carriage, shank up through it
module c_slide_bolts(w, dz = 0) carriage_frame(w) for (s = [-1, 1])
    translate([s * slide_bolt_x, car_yc(w), sb_pd - sb_head[1] + dz]) rotate([0, 0, 45]) slide_bolt();
// the two slide thumb-nuts on top of the slide
module c_slide_nuts(w, dz = 0) carriage_frame(w) for (s = [-1, 1])
    translate([s * slide_bolt_x, car_yc(w), car_t(w) + t_slide + dz]) slide_nut();
// datum pin pair (zero / compositing position), O5 x 25
module c_datum_pins(w, dz = 0) carriage_frame(w) for (s = [-1, 1])
    translate([s * car_dsep(w) / 2, -car_off(w), -dowel_depth + dz]) pin(pin_d, dowel_len);
// vernier pin: in whichever vernier hole lines up with a rail index hole at the current stereo offset
function vern_x(w) = [for (v = car_vern(w)) let(r = v + car_shift(w)) if (abs(r - 10 * round(r / 10)) < 0.01) v];
module c_vernier_pin(w, dz = 0) carriage_frame(w) for (v = vern_x(w))
    translate([v, car_off(w), -dowel_depth + dz]) pin(pin_d, dowel_len);

// Off the rig: a carriage lying upside down (rail face and tongue up, as printed for the rear carriage) at the
// origin, in its local x / y, and its two slide T-bolts hovering dz above their diamond pockets, shank down.
module c_flip(w) translate([0, 0, car_t(w)]) mirror([0, 0, 1]) children();
module carriage_flipped(w) c_flip(w) if (w == "rear") rear_carriage_local(); else bottom_carriage_local();
module slide_bolts_flipped(w, dz = 0) c_flip(w) for (s = [-1, 1])
    translate([s * slide_bolt_x, car_yc(w), sb_pd - sb_head[1] - dz]) rotate([0, 0, 45]) slide_bolt();

// Slide-local frame (as the model's slides_world): z = 0 on the slide underside (carriage face), +z away from the
// carriage; local y = the slide travel (rear: world Y; bottom: world Z, up).  Includes the stereo offset.
module slide_frame(w) if (w == "rear") translate([stereo_rear, y_rear_sock, deck_top + t_rear_carriage]) children();
                      else translate([-stereo_bot, bc_y0, z_bot_sock]) rotate([90, 0, 0]) children();
module slide_local(w) if (w == "rear") f38_slide_local(rear_travel); else f38_slide_local(bot_slot_trav, bot_serr, bot_slot_shift);
module slide_part(w, dz = 0) slide_frame(w) translate([0, 0, dz]) slide_local(w);
// F38 locating pins O4 x 8 pressed into the slide (about 3 mm proud)
module f38_pins(w, dz = 0) if (f38_pins) slide_frame(w) f38_pins_local(dz);
module f38_pins_local(dz = 0) for (s = [-1, 1]) translate([s * f38_pin_sp / 2, 0, t_slide - f38_pin_depth + dz]) pin(f38_pin_d, f38_pin_depth + 3);
// steel 1/4"-20 x 3/8" base screw from below, head in the counterbore inside the guide tongue (dz < 0 = below)
module qtr_screw(len = qtr_screw_len) color(C_STEEL) {
    cylinder(d = qtr_head_d - 1, h = qtr_head_h, $fn = 32);
    translate([0, 0, qtr_head_h - 0.01]) cylinder(d = 6.35, h = len + 0.01, $fn = 24);
}
module f38_screw(w, dz = 0) slide_frame(w) f38_screw_local(dz);
module f38_screw_local(dz = 0) translate([0, 0, qtr_cb_top - qtr_head_h + dz]) qtr_screw();
// F38 stand-ins (bought): the model draws base + clicked-in plate as one box f38_stack high; here they are split
// into a base (F38_PLATE_H less) and a plate F38_PLATE_H thick.  Proportions only, not a real F38 drawing.  The
// release-lever nub on the base marks the side to point along the slide travel.
F38_PLATE_H = 6;
module f38_base_box() color(C_F38) {
    translate([-f38_base[0] / 2, -f38_base[1] / 2, 0]) cube([f38_base[0], f38_base[1], f38_stack - F38_PLATE_H]);
    translate([-6, f38_base[1] / 2 - 0.01, 3]) cube([12, 4, 5]);   // release lever (stand-in)
}
module f38_plate_box() color([0.70, 0.20, 0.18]) translate([-shim_fp[0] / 2, -shim_fp[1] / 2, 0]) cube([shim_fp[0], shim_fp[1], F38_PLATE_H]);
module f38_base_w(w, dz = 0) slide_frame(w) translate([0, 0, t_slide + dz]) f38_base_box();
// F38 plate in its clicked-in place (dz: away from the base, i.e. toward the camera)
module f38_plate_w(w, dz = 0) slide_frame(w) translate([0, 0, t_slide + f38_stack - F38_PLATE_H + dz]) f38_plate_box();
// camera shim (09_shim_set: t = 0.5 / 1 / 2) between the F38 plate and the camera (on top of the swap shim at the
// bottom position); dz moves it toward the camera
module shim_w(w, t, dz = 0) slide_frame(w) translate([0, 0, t_slide + f38_stack + (w == "rear" ? 0 : swap_shim_t) + dz]) shim(t);

// Wall rail and its hardware (world).  dy < 0 moves a part toward the front (out of the frame).
module wall_rail_part(dy = 0) translate([0, dy, 0]) wall_rail_world();
module wr_pins(dy = 0) for (x = wrl_dowel_x)          // O5 x 12, pressed into the crosswall band, 5.5 mm proud
    translate([x, y_cwm - (wrl_dowel_len - wrl_dowel_wall) + dy, wr_z + wrl_bolt_h]) rotate([-90, 0, 0]) pin(pin_d, wrl_dowel_len);
module wr_band_tnuts(dz = 0) for (x = wrl_bolt_x)     // dropped into the band slots, flat face toward the rail
    translate([x, y_cwm + wrl_nut_f, wr_z + wrl_bolt_h + dz]) rotate([-90, 0, 0]) rotate([0, 0, 90]) tnut();
module wr_bolts(dy = 0) for (x = wrl_bolt_x)          // M8 x 21, round head in the rail-face counterbore
    translate([x, y_wf + wrl_cb - wb_head[1] + dy, wr_z + wrl_bolt_h]) rotate([-90, 0, 0]) wall_bolt();
// L-shaped 5 mm hex key stand-in: short arm along `dir` with its tip at `tip`, long arm along `up`
module hex_key_tool(tip, dir, up = [0, 0, 1], short = 22, long = 70) color([0.15, 0.15, 0.17]) {
    hull() { translate(tip) sphere(d = hex_key, $fn = 6); translate(tip - short * dir / norm(dir)) sphere(d = hex_key, $fn = 6); }
    hull() { translate(tip - short * dir / norm(dir)) sphere(d = hex_key, $fn = 6);
             translate(tip - short * dir / norm(dir) + long * up / norm(up)) sphere(d = hex_key, $fn = 6); }
}

// Glass groove (plate-local helpers are wrapped in place_plate(); sides = [1, -1] both ribs).
// strips slid dv mm out toward the top-front (0 = home)
module strips_part(dv = 0, sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate()
    translate([0, -dv, 0]) groove_strip_local();
// felt on the strip (moves with it): lower lip (one 0.5 layer, the angle reference) and end-cap pad (2 layers)
module felt_lip_local() translate([x_lip, v_s0, -felt_t]) cube([x_gb_s - x_lip, v_es_s - v_s0, felt_t]);
module felt_endpad_local() translate([x_lip, v_es_s - end_pad, 0]) cube([x_gb_s - x_lip, end_pad, w_hi - strip_top_clr]);
module felt_lip(dv = 0, sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate() translate([0, -dv, 0]) felt_lip_local();
module felt_endpad(dv = 0, sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate() translate([0, -dv, 0]) felt_endpad_local();
// felt on the channel roof (upper flank): x_ul .. x_gb (1.6 mm wide by default), cut at the three thumbscrew holes;
// dw > 0 = held below the roof (explode)
module felt_roof(sides = [-1, 1], dw = 0) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate() difference() {
    translate([x_ul, v_top + 1, w_hi - felt_t - dw]) cube([x_gb - x_ul, v_es_s - end_pad - v_top - 1, felt_t]);
    for (p = preload_v) translate([x_pl, p, w_hi - 5 - dw]) cylinder(d = ps_d + 1, h = 10, $fn = 32);
}
// the strip on the bench: plate-local frame without the 45° tilt (x across, y = v along the strip, z = w up), +X
// strip (s = 1) or its mirror (s = -1); felt = with its lip felt and end pad
// c = the strip's colour (felt stays green: do not wrap these in new1() / done())
module strip_bench(s = 1, felt = true, c = C_NEW) mirror([s < 0 ? 1 : 0, 0, 0]) {
    color(c) groove_strip_local();
    if (felt) color(C_FELT) { felt_lip_local(); felt_endpad_local(); }
}
// strip_view(): a bench strip turned to face a camera at the front (rz = 0): its length along world X (top-front
// end, the pull-hole end, on the right; end cap on the left), its inner face (thin lip, felt) toward the camera (-Y),
// top up; centred on x = 0 and on its own width
module strip_view(s = 1, felt = true, c = C_NEW) rotate([0, 0, 90]) translate([-(x_lip + xo_s) / 2, -(v_s0 + v_s1) / 2, 0]) strip_bench(s, felt, c);
// magnified piece (v0 .. v1 along the strip) of strip_view(), k times, centred on its own middle
module strip_zoom(v0, v1, k = 3, s = 1, felt = true, c = C_NEW) scale(k) rotate([0, 0, 90]) translate([-(x_lip + xo_s) / 2, -(v0 + v1) / 2, 0])
    intersection() { strip_bench(s, felt, c); color(c) translate([0, v0, -5]) cube([200, v1 - v0, 20]); }
// cross-section of the strip (a 1 mm slice at v), k times, seen from its top-front end: inboard (lip) on the left
module strip_section(v = 0, k = 6, s = 1, c = C_NEW) scale(k) translate([-(x_lip + xo_s) / 2, -v, 0])
    intersection() { strip_bench(s, true, c); color(c) translate([0, v - 0.5, -5]) cube([200, 1, 20]); }
// a strip-local point [x, v, w] -> its position in strip_view() / strip_zoom(v0, v1, k)
function sv_pt(p) = [(v_s0 + v_s1) / 2 - p[1], p[0] - (x_lip + xo_s) / 2, p[2]];
function sz_pt(p, v0, v1, k = 3) = k * [(v0 + v1) / 2 - p[1], p[0] - (x_lip + xo_s) / 2, p[2]];
// a strip-local point -> its position in strip_section(v, k) (seen from the top-front end: inboard on the left)
function ss_pt(p, k = 6) = k * [p[0] - (x_lip + xo_s) / 2, 0, p[2]];
// named strip features (plate-local, +X strip): [x, v, w]
STRIP_PULL   = [(x_gb_s + xo_s) / 2, v_s0 + 1.5 + strip_pull_d / 2, (w_lo + w_hi - strip_top_clr) / 2];  // pull hole centre
STRIP_BUMPS  = [for (c = spring_v) [(x_gb_s + xo_s) / 2, c, w_hi - strip_top_clr + sb_h]];                // spring bump tops
STRIP_NOTCH  = [for (p = preload_v) [(x_gb_s + xo_s) / 2, p, strip_floor]];                               // notch floors
STRIP_CAP    = [(x_lip + xo_s) / 2, (v_es_s + v_s1) / 2, w_hi - strip_top_clr];                           // end cap top
STRIP_LIP    = [x_lip + 1.5, 0, -felt_t];                                                                  // lip (felt) face
STRIP_STEP   = [key_x[0] - key_clr, 0, w_seat];                                                            // key step
// bent paper clip (1 mm wire) hooked into the pull hole of a strip slid dv out; plate-local, +X side
module paper_clip_local(dv = 0) let(p = STRIP_PULL - [0, dv, 0], r = 0.5) color(C_STEEL) {
    seg = [[xo_s + 1.5, p[1], p[2]], [x_gb_s - 4, p[1], p[2]], [x_gb_s - 8, p[1] - 6, p[2] + 6],
           [x_gb_s - 8, p[1] - 40, p[2] + 14], [x_gb_s - 2, p[1] - 46, p[2] + 14], [x_gb_s + 4, p[1] - 40, p[2] + 14]];
    for (i = [0 : len(seg) - 2]) hull() { translate(seg[i]) sphere(r = r, $fn = 12); translate(seg[i + 1]) sphere(r = r, $fn = 12); }
}
module paper_clip(dv = 0, s = 1) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate() paper_clip_local(dv);

// glass thumbscrews (printed M10 x 12): tip = plate-local w of the screw tip (default: pressing the felt disc on the
// glass back = tightened; TIP_OUT = backed off three turns, clear of strip springs and glass); dw > 0 moves them out
// along the screw axis (explode).  discs = also draw the felt discs on the tips.
TIP_TIGHT = plate_t + felt_t;
TIP_BACK  = w_hi;                       // tip (felt) flush with the channel roof
TIP_OUT   = TIP_TIGHT + 3 * ps_pitch;   // three turns back from tight
module glass_screws(tip = TIP_TIGHT, dw = 0, sides = [-1, 1], discs = false)
    for (sx = sides) mirror([sx < 0 ? 1 : 0, 0, 0]) place_plate() for (p = preload_v) {
        translate([x_pl, p, tip + dw + ps_len + ps_head[1]]) rotate([0, 180, 0]) mirror([sx < 0 ? 1 : 0, 0, 0]) preload_screw();
        if (discs) color(C_FELT) translate([x_pl, p, tip + dw - felt_t]) cylinder(d = FELT_DISC_D, h = felt_t, $fn = 32);
    }
module felt_discs(tip = TIP_TIGHT, dw = 0, sides = [-1, 1]) for (sx = sides) mirror([sx < 0 ? 1 : 0, 0, 0]) place_plate()
    for (p = preload_v) translate([x_pl, p, tip + dw - felt_t]) cylinder(d = FELT_DISC_D, h = felt_t, $fn = 32);
// screw-axis helpers for arrows: world point on the axis of thumbscrew i (0..2) on side sx at plate-local w
function gs_pt(sx, i, w) = let(p = pl2w([x_pl, preload_v[i], w])) [sx * p[0], p[1], p[2]];
// any plate-local point on side sx (mirrors x)
function pl2w_s(p, sx = 1) = let(q = pl2w(p)) [sx * q[0], q[1], q[2]];
W_DIR = [0, 1, 1] / s2;      // plate normal toward the back (uncoated side): screws advance along -W_DIR
V_DIR = [0, 1, -1] / s2;     // along the plate toward the lower-rear end: glass / strips slide in along +V_DIR

// glass: shift = mm slid out toward the top-front (0 = seated); coat = mark the coated face (it faces DOWN)
module glass_w(shift = 0, coat = true) place_plate() {
    color(C_GLASS) glass_local(shift);
    if (coat) let(gs = strip_glass) color(C_COAT)
        translate([-gs[0] / 2, -plate_size / 2 - shift, -0.25]) cube([gs[0], gs[1], 0.25]);
}
// pen stand-in for the coated-face test: tip at `tip`, body along `dir`
module pen(tip, dir = [0, 0, 1]) translate(tip) orient_to(dir) {
    color([0.2, 0.2, 0.25]) cylinder(d1 = 0.6, d2 = 8, h = 12, $fn = 24);
    color([0.15, 0.3, 0.75]) translate([0, 0, 12]) cylinder(d = 9, h = 110, $fn = 24);
}
// glass stops (printed: ear on the front post top, through the lid pin); dz = lifted
module stops_part(dz = 0, sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) translate([0, 0, dz]) glass_stop_world_p();
// felt pad (2 layers) on the stop face that meets the glass top edge
module felt_stop(dz = 0, sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) translate([0, 0, dz]) place_plate()
    translate([stop_x0, v_top, 0]) cube([x_gb_s - stop_x0, end_pad, plate_t + felt_t]);
// the stop ears (to paint them)
module stop_ears(dz = 0, sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) translate([0, 0, dz]) glass_stop_ear_world();

// lid and its four M10 thumbscrews; dz = lifted
module lid_part(dz = 0) translate([0, 0, dz]) top_lid_world();
module lid_screws(dz = 0) for (sx = [-1, 1], b = lid_bolts)
    translate([sx * b[0], b[1], frame_top + lid_t + lid_sh[1] + dz]) rotate([180, 0, 0]) lid_screw();
// flocking film on the lid underside (stand-in), drawn in the lid's world position (dz moves it with the lid); it
// covers the light trap between the glass stops and the rear posts
module flock_lid(dz = 0) color(C_FLOCK) translate([-(stop_x0 - 1), lid_y0 + 1, frame_top - 0.4 + dz])
    cube([2 * (stop_x0 - 1), rp_y[0] - 1 - lid_y0 - 1, 0.4]);
// the lid turned over (underside up, flipped about the Y axis so front stays front) with its flocking, its
// underside at height z
// (c_lid / c_flock: colours, e.g. C_DONE and C_NEW to highlight the flocking)
module lid_flipped(z, flock = true, c_lid = C_DONE, c_flock = C_FLOCK) translate([0, 0, z + frame_top]) rotate([0, 180, 0]) translate([0, 0, -frame_top]) {
    color(c_lid) top_lid_world();
    if (flock) color(c_flock) translate([0, 0, -0.01]) flock_lid();
}
// matt-black paint zones (highlight overlays, a hair proud of the frame): the six glass-thumbscrew bosses and the
// upper groove flank bevels (the faces the cameras can see above the glass)
module paint_zones(sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate() {
    for (p = preload_v) translate([boss_x0 - 0.2, p - boss_l / 2 - 0.2, w_hi + 0.01]) cube([x_rw - boss_x0 + 0.2, boss_l + 0.4, boss_h + 0.2]);
    let(xb = x_ul + back_flank * bevel_k) vextrude(v_top, v_bot) polygon([[x_ul, w_hi], [xb, w_back], [xb - 0.3, w_back], [x_ul - 0.3, w_hi]]);
}
// the lower inner corner of each glass-thumbscrew boss (the one that may droop into the groove): highlight blocks
module boss_corners(sides = [-1, 1]) for (s = sides) mirror([s < 0 ? 1 : 0, 0, 0]) place_plate()
    for (p = preload_v) translate([boss_x0 - 0.6, p - boss_l / 2 - 0.6, w_hi - 0.6]) cube([x_ul - boss_x0 + 1.2, boss_l + 1.2, 1.4]);

// heat-set insert (stand-in, brass) in the tripod pad; dz < 0 = below the frame
module heat_insert(dz = 0) color(C_BRASS) translate([tri_xy[0], tri_xy[1], dz]) difference() {
    cylinder(d = tri_ins_d + 0.8, h = tri_ins_dep, $fn = 24);
    translate([0, 0, -1]) cylinder(d = 6.35, h = tri_ins_dep + 2, $fn = 24);
}
// soldering iron stand-in, tip at `tip`, handle along `dir`
module soldering_iron(tip, dir = [0, 0, -1]) translate(tip) orient_to(dir) {
    color([0.75, 0.75, 0.78]) { cylinder(d1 = 1.2, d2 = 4, h = 12, $fn = 24); translate([0, 0, 12]) cylinder(d = 4, h = 40, $fn = 24); }
    color([0.15, 0.25, 0.55]) translate([0, 0, 52]) cylinder(d = 14, h = 70, $fn = 32);
}

// cameras without the clearance haze, F38 box or swap shim (copies of the model's mock-up bodies)
module rear_cam_body(dx = stereo_rear, dpos = [0, 0, 0]) translate([dx, 0, 0] + dpos) {
    c = cam_r;
    color("black") translate([0, y_rear_front, Zs]) rotate([-90, 0, 0]) cylinder(d = lens_15[0], h = L15, $fn = fn_big);
    color([0.25, 0.25, 0.28]) {
        translate([-c[0] / 2, y_rear_mount, z_rear_tripod]) cube([c[0], c[5], c[1]]);
        translate([-c[0] / 2, y_rear_mount - (c[2] - c[5]), z_rear_tripod]) cube([28, c[2] - c[5] + eps, c[1]]);
    }
}
module bot_cam_body(dx = -stereo_bot, dpos = [0, 0, 0]) translate([dx, 0, 0] + dpos) {
    c = cam_b;
    color("black") translate([0, 0, z_bot_mount]) cylinder(d = lens_1018[0], h = L1018, $fn = fn_big);
    color([0.15, 0.1, 0.2]) translate([0, 0, z_bot_front - eps]) cylinder(d = filt_od, h = filt_len + eps, $fn = fn_big);
    color([0.3, 0.3, 0.33]) {
        translate([-c[0] / 2, c[3] - c[1], z_bot_mount - c[5]]) cube([c[0], c[1], c[5]]);
        translate([c[0] / 2 - 25, c[3] - c[1], z_bot_mount - eps]) cube([25, c[1], c[2] - c[5] + eps]);
    }
}
// the 3 mm riser between the a5100 and its F38 plate (world, bottom position); dy > 0 toward the crosswall
module swap_shim_w(dy = 0) translate([-stereo_bot, dy, 0]) translate([0, cam_b[3] + swap_shim_t, z_bot_sock]) rotate([90, 0, 0]) shim(swap_shim_t);
// the cameras' lens axes (thin lines), meeting at the glass centre
module lens_axes(c = C_INK) {
    line3([stereo_rear, 0, Zs], [stereo_rear, y_rear_mount, Zs], 1.2, c);
    line3([-stereo_bot, 0, z_bot_mount], [-stereo_bot, 0, Zs], 1.2, c);
}

// wrap clip in a 4 mm hole through a side member (world): hole at [y, z] on side s (+1 / -1), T-head outside on
// the foil (foil = wrap thickness), stem through the member toward the inside.
module wrap_clip_side(y, z, s = 1, grip = wrap_grip[0], foil = 0.3)
    translate([s * (wall_out + foil), y, z]) rotate([0, 0, s > 0 ? 90 : -90]) translate([0, 0, -wc_t / 2]) wrap_clip(grip);
// all side-member wrap holes [y, z] (diagonal rib + front post; the rear post holes are at x = rp centre)
function side_wrap_holes() = concat(zips_diag(), zips_front());
// foil over one open side (stand-in): the side outline outside the side plane
module foil_side(s = 1, t = 0.3) color(C_FOIL) translate([s > 0 ? wall_out : -wall_out - t, 0, 0]) rotate([90, 0, 90])
    linear_extrude(t) polygon([[y_front, 0], [y_back, 0], [y_back, deck_top], [rp_y[1], deck_top], [rp_y[1], frame_top],
                               [y_front, frame_top]]);

// bought parts on the bench (stand-ins): glass plate, felt sheet, 1/4"-20 screws
module glass_bench() { color(C_GLASS) cube([strip_glass[0], strip_glass[1], plate_t]);
                       color(C_COAT) translate([0, 0, -0.25]) cube([strip_glass[0], strip_glass[1], 0.25]); }
module felt_sheet(w = 100, l = 70) color(C_FELT) cube([w, l, felt_t]);

// Printed hardware
// [key, name, size, number used, print file] -- counts as in docs/HARDWARE.md (the plates carry ~20 % spares)
HW_LIST = [
    ["lid_screw",   "lid thumbscrew",     "M10 x 20",               4, "11"],
    ["clamp_screw", "clamp thumbscrew",   "M8 x 17, 5 mm hex",      4, "11"],
    ["slide_bolt",  "slide T-bolt",       "M8, square head",        4, "11"],
    ["wall_bolt",   "wall-rail bolt",     "M8 x 21, 5 mm hex",      4, "11"],
    ["tnut",        "T-nut",              "M8, 45-degree bevels",   8, "12"],
    ["slide_nut",   "thumb-nut",          "M8",                     4, "12"],
    ["glass_screw", "glass thumbscrew",   "M10 x 12",               6, "13"],
    ["pin25",       "pin",                "5 x 25",                 6, "14"],
    ["pin12",       "pin",                "5 x 12",                 2, "14"],
    ["f38_pin",     "F38 pin",            "4 x 8",                  4, "14"],
    ["clip",        "wrap clip",          "grip 8.5 / 6.5 / 4.5",  60, "15"]];
// one piece, standing as printed (head or bed face down)
module hw_piece(key) {
    if      (key == "lid_screw")   lid_screw();
    else if (key == "clamp_screw") clamp_screw();
    else if (key == "slide_bolt")  slide_bolt();
    else if (key == "wall_bolt")   wall_bolt();
    else if (key == "tnut")        tnut();
    else if (key == "slide_nut")   slide_nut();
    else if (key == "glass_screw") preload_screw();
    else if (key == "pin25")       pin(pin_d, dowel_len);
    else if (key == "pin12")       pin(pin_d, wrl_dowel_len);
    else if (key == "f38_pin")     pin(f38_pin_d, f38_pin_depth + 3);
    else if (key == "clip")        wrap_clip(wrap_grip[0]);
    else assert(false, str("hw_piece: unknown key ", key));
}
// printed rig parts (01-10) in their world positions, [stl number, name]; part_w(k, d) draws part k moved by d
PARTS = [["01", "frame"], ["02", "top lid"], ["03", "wall rail"], ["04", "rear carriage"], ["05", "bottom carriage"],
         ["06", "F38 slides"], ["07", "glass stops"], ["08", "groove strips"], ["09", "shims"], ["10", "3 mm riser"]];
module part_w(k, d = [0, 0, 0]) translate(d) {
    if      (k == 0) frame();
    else if (k == 1) top_lid_world();
    else if (k == 2) wall_rail_world();
    else if (k == 3) carriage_part("rear");
    else if (k == 4) carriage_part("bottom");
    else if (k == 5) { slide_part("rear"); slide_part("bottom"); }
    else if (k == 6) stops_part();
    else if (k == 7) strips_part();
    else if (k == 8) for (i = [0 : len(shim_t) - 1]) shim_w("rear", shim_t[i], 30 + 8 * i);
    else if (k == 9) swap_shim_w();
}

// The rig as built so far
// Build stages = the guide's step numbers (keep in step with docs/ASSEMBLY.md).
S_PARTS = 1;  S_HARDWARE = 2;  S_CLEAN = 3;  S_PAINT = 4;  S_THREADS = 5;  S_INSERT = 6;  S_CROSSWALL = 7;
S_WALLRAIL = 8;  S_TBOLTS = 9;  S_REAR_CAR = 10;  S_BOT_CAR = 11;  S_F38 = 12;  S_REAR_SLIDE = 13;  S_BOT_SLIDE = 14;
S_STRIP_FELT = 15;  S_STRIPS = 16;  S_STRIP_CHECK = 17;  S_ROOF_FELT = 18;  S_GLASS = 19;  S_GLASS_SCREWS = 20;
S_STOPS = 21;  S_LID = 22;  S_CAM_PREP = 23;  S_CAMERAS = 24;  S_HEIGHTS = 25;  S_VIEWPOINT = 26;  S_WRAP = 27;
S_STEREO = 28;  S_SERVICE = 29;  S_ALL = 99;
// built(n): everything fitted in steps < n, frame dark grey, parts light grey (felt green, glass blue, insert brass,
// F38 dark red).  The side wrap is never drawn here (scenes add foil_side() themselves).
// hide: any of "frame", "lid", "cams", "glass", "felt", "hw" (printed hardware), "f38", "stops", "screws" (glass
// thumbscrews), "strips", "rear" (rear carriage + slide), "bottom" (bottom carriage + slide), "wallrail".
// clip = [lo, hi]: cut-away box applied to every part (see cl()).  fclip = [lo, hi]: cut only the frame and leave
// the parts inside whole -- the safer choice: with many clipped parts the preview sometimes paints their cut faces
// gold or green instead of the part colour.
module built(n, hide = [], clip = undef, fclip = undef) let($clip = clip) {
    hw = !has(hide, "hw");
    if (!has(hide, "frame")) color(C_FRAME) let($clip = is_undef(fclip) ? clip : fclip) cl() frame();
    if (n > S_INSERT && tripod_mount == "insert") cl() heat_insert();
    if (n > S_CROSSWALL && hw) done() cl() { wr_pins(); wr_band_tnuts(); }
    if (n > S_WALLRAIL && !has(hide, "wallrail")) { done() cl() wall_rail_part(); if (hw) done() cl() { c_tnuts("bottom"); wr_bolts(); } }
    if (n > S_REAR_CAR && hw && !has(hide, "rear")) done() cl() c_tnuts("rear");
    for (w = ["rear", "bottom"]) if (!has(hide, w) && n > (w == "rear" ? S_REAR_CAR : S_BOT_CAR)) {
        done() cl() carriage_part(w);
        if (hw) done() cl() {
            c_slide_bolts(w); c_clamp_screws(w);
            if (car_shift(w) == 0) c_datum_pins(w); else c_vernier_pin(w);
        }
        if (n > (w == "rear" ? S_REAR_SLIDE : S_BOT_SLIDE)) {
            done() cl() slide_part(w);
            if (hw) done() cl() { c_slide_nuts(w); f38_pins(w); }
            if (!has(hide, "f38")) cl() { f38_base_w(w); f38_screw(w); }
        }
    }
    if (n > S_STRIPS && !has(hide, "strips")) {
        done() cl() strips_part();
        if (!has(hide, "felt")) color(C_FELT) cl() { felt_lip(); felt_endpad(); }
    }
    if (n > S_ROOF_FELT && !has(hide, "felt")) color(C_FELT) cl() felt_roof();
    if (n > S_GLASS && !has(hide, "glass")) cl() glass_w(coat = false);
    if (n > S_GLASS_SCREWS && hw && !has(hide, "screws")) {
        done() cl() glass_screws(TIP_TIGHT);
        if (!has(hide, "felt")) color(C_FELT) cl() felt_discs(TIP_TIGHT);
    }
    if (n > S_STOPS && !has(hide, "stops")) {
        done() cl() stops_part();
        if (!has(hide, "felt")) color(C_FELT) cl() felt_stop();
    }
    if (n > S_LID && !has(hide, "lid")) { done() cl() lid_part(); if (hw) done() cl() lid_screws(); cl() flock_lid(); }
    if (n > S_CAMERAS && !has(hide, "cams")) {
        cl() { rear_cam_body(); bot_cam_body(); }
        if (!has(hide, "f38")) cl() { f38_plate_w("rear"); f38_plate_w("bottom"); }
        color("orange") cl() swap_shim_w();
    }
}
