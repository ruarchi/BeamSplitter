// BeamSplitter -- dual-camera beam-splitter rig (parametric, 3D-printable).
// A 150 x 150 x 2 mm 50/50 plate beam splitter at 45 deg between two cameras: the rear camera looks
// through the glass, the bottom camera looks up at the reflection. Both slide sideways for stereo.
// Parameters, measuring your gear: docs/CUSTOMIZE.md. Printing, assembly, design: see docs/.
//
// Usage: part = "assembly" draws the whole rig (F5). Any other part name draws one printable part
// in print orientation: F6, then File > Export > STL. Command line:
//   openscad -D 'part="frame"' -o frame.stl beamsplitter_rig.scad
// The console prints a summary of optical margins and clearances; an assert stops the run when a
// parameter combination does not fit. Everything below "DERIVED VALUES" is computed.
//
// Units: mm and degrees.
// World frame: X left/right, Y front/back (the scene is at -Y), Z up. X = 0 is the centreline,
//   Y = 0 the splitter centre, Z = 0 the underside of the base. Splitter centre S = (0, 0, Zs).
//   The coated face has normal (0,-1,-1)/sqrt2 (toward the scene and the bottom camera).
//   The rear camera looks -Y, the bottom camera looks +Z.
// Plate-local frame (grooves, ribs): x = world X; v = along the plate, +v = rear/lower edge
//   (world (0,1,-1)/sqrt2); w = plate normal toward the uncoated back (world (0,1,1)/sqrt2).
//   The coated face is w = 0 (through S); the glass occupies w = 0 .. plate_t, v = -75 .. +75.
//   Mapping: translate([0,0,Zs]) rotate([-45,0,0]) (see place_plate()).

/* [What to draw] */
// Part to draw: "assembly" = the whole rig; any other name = one printable part, laid flat for printing
part       = "assembly"; // [assembly, frame, top_lid, wall_rail, glass_stop, preload_screw, rear_carriage, bottom_carriage, f38_slide, hood, shim_set, swap_shim, groove_test, groove_strip, thread_test, rail_test, pin_test, hardware_screws, hardware_nuts, pin_set, wrap_clips, hood_hardware, arca_plate, splitter_mockup, camera_mockups, insert_check, strip_insert_check, world, none]
// With part = "world": one printed part in its assembled position (for mass, centre of gravity and clash checks)
world_piece = "frame";   // [frame, top_lid, wall_rail, groove_strip, glass_stop, preload_screw, rear_carriage, bottom_carriage, f38_slide, swap_shim, hood, hardware, arca_plate]
// Assembly: draw the camera fields of view (orange = rear, purple = bottom; not parts)
show_fov   = true;
// Assembly: draw the top lid (translucent in preview only)
show_lid   = true;
// Assembly: draw the optional front hood
show_hood  = false;
// Assembly: draw the camera, lens and F38 mock-ups
show_cams  = true;
// Assembly: remove the +X half of frame, lid and hood to look inside
cutaway     = false;
// Assembly: slide the glass this far up-front along its grooves (0 = seated; > 0 hides the lid and stops)
glass_insert = 0;
// Smaller printer: cut the rear deck off the frame at Y = split_y (bolted lap joint, steel M4 screws)
frame_split = false;
// With frame_split: which piece to draw ("both" = side by side)
split_piece = "both";    // [front, rear, both]

/* [Hardware and tripod mount] */
// "printed" = printed thumbscrews, nuts, pins and clips; "steel" = M4 bolts, square nuts, steel dowel pins, heat-set inserts
hardware   = "printed";  // [printed, steel]
// Tripod socket: "insert" = 1/4"-20 heat-set insert (recommended: the loaded rig hangs on it), "printed" = printed 1/4"-20 thread, "arca" = printed Arca-Swiss plate on 2 printed M10 thumbscrews
tripod_mount = "insert"; // [insert, printed, arca]

/* [Stereo] */
// Rear camera sideways offset toward +X, mm (stereo; at most rear_stereo)
stereo_rear = 0;         // [-40:5:40]
// Bottom camera sideways offset toward -X, mm (stereo; give a positive number; at most bot_stereo)
stereo_bot  = 0;         // [-45:5:45]
// Print the stereo clipping readout when a stereo offset is set (ray sampling, ~30 s; false = faster preview)
clip_check  = true;
// Rays across x down the target frame, per camera
clip_grid   = [64, 36];

/* [Measure first: cameras, lenses, F38, filter, glass] */
// Measure these on your own hardware before printing the frame (docs/CUSTOMIZE.md explains how).
// Entrance pupil depth behind the front element, rear lens (parallax method)
ep_15       = 25;
// Entrance pupil depth, bottom lens at its working focal length, from the BARE lens front (filter not counted)
ep_1018     = 25;
// Screw-in IR filter on the bottom lens: ring outer diameter
filt_od     = 65;
// How far the filter sticks out beyond the bare lens front (toward the glass)
filt_len    = 6;
// Camera axis heights: enter the UPPER end of your ruler reading.  An error then leaves the camera slightly LOW
// (rear) or slightly too close to the crosswall (bottom), which the shim_set (0.5 / 1 / 2 mm) takes up:
// shims can only space a camera away from its mount, never pull it closer.
// Rear camera (a6400): [axis height above the tripod face, flange -> tripod socket, flange -> rear LCD]
a6400_meas  = [35, 18, 45];
// Bottom camera (a5100): [axis height above the tripod face, flange -> tripod socket, flange -> rear LCD]
a5100_meas  = [32, 15, 33];
// Rear camera body envelope [width (X), height, depth incl. grip]
a6400_size  = [120.0, 66.9, 59.7];
// Bottom camera body envelope [width (X), height, depth incl. grip]
a5100_size  = [109.6, 62.8, 35.7];
// Rear lens (Sony E 15 mm F1.4 G): [diameter, length mount -> front]
lens_15   = [66.6, 69.5];
// Bottom lens (Sony E 10-18 mm F4 at 18 mm): [diameter, length mount -> front]
lens_1018 = [70.0, 63.5];
// F38 quick release: slide top -> camera tripod face, plate clicked into the base (enter the upper end of the reading)
f38_stack   = 17;
// F38 base footprint [along camera X, along the slide travel]
f38_base    = [54.3, 41.3];
// Locating pins pressed into the slide, into the holes in the F38 base (false = no pins)
f38_pins    = true;
// Locating hole / pin diameter (slide hole = f38_pin_d - 0.1, press fit)
f38_pin_d   = 4.0;
// Pin spacing along camera X, centred on the 1/4" screw
f38_pin_sp  = 30;
// Pin hole depth in the slide (pins stand about 3 mm proud; at most t_slide - 1)
f38_pin_depth = 5;
// Usable depth of the F38 base's 1/4"-20 thread (through hole: depth to the quick-release cavity floor)
f38_thread_depth = 8;
// Length of the 1/4"-20 screw that holds the F38 base (3/8" = 9.5); its engagement is checked
qtr_screw_len = 9.5;
// Release lever / safety knob: [how far it sticks out beyond the base along camera X (0 = inside), its lowest point above the base underside]
f38_lever   = [0, 99];
// Camera-side footprint of the F38 plate (the shims go between camera and F38 plate)
shim_fp     = [36, 44];
// Your glass, measured: [width across X, length along the slope]; the groove strips are made for it
strip_glass = [150, 150];

/* [Optics] */
// Splitter centre height above the base underside
Zs          = 176;
// Target common-frame focal length (19 = the smallest 0.5 mm step that passes with the default IR filter); set fov_f_rear / fov_f_bot the same
target_f    = 19;
// Target frame aspect: "16:9" or "3:2"
target_aspect = "16:9";
// Design distance plate centre -> lens front element
g           = 41.5;
// Required clearance of a lens rim from the other camera's field of view
rim_margin  = 3;
// Lens-to-glass clearance, measured normal to the plate
plate_clear_min = 3;
// Focal length of the drawn rear field of view
fov_f_rear  = 19;
// Focal length of the drawn bottom field of view
fov_f_bot   = 19;
// Aspect of the drawn fields of view: "16:9" or "3:2"
fov_aspect  = "16:9";
// How far the rear field of view is drawn from its pupil
fov_len     = 190;
// Frame / hood clearance outside the target field of view
aperture_margin = 3;
// Minimum clearance of groove lips, stops, bosses and screw heads outside both fields of view
lip_margin_min = 0.5;
// Sensor width (APS-C)
sensor_w    = 23.5;
// Sensor height, 3:2
sensor_h32  = 15.6;
// Frame height, 16:9
sensor_h169 = 13.22;
// Lens clearance envelope: diameter + this
lens_clear_d = 6;
// Lens clearance envelope: length + this
lens_clear_l = 10;
// Beam-splitter plate size (square)
plate_size  = 150;
// Beam-splitter plate thickness
plate_t     = 2.0;
// Glass edge engagement in the groove (clear aperture = plate_size - 2 * glass_engage)
glass_engage = 2;

/* [Glass groove and preload] */
// Groove stack (plate normal, from the coated face down): 0.5 mm hard felt on the LOWER flank (the angle reference;
// the glass rests on it by gravity), the 2 mm glass, then one 0.5 mm felt layer on the UPPER flank (add a second only
// if the glass rattles), pressed by the printed preload thumbscrews.  Cut the upper felt
// strip no wider than the groove roof (x_ul .. x_gb, printed in the summary): a wider strip hangs into the view.
// Groove width: deliberately generous so the glass always fits; the slack is taken up by the felt and the thumbscrews
groove_w    = 4.0;
// Lower-flank felt thickness (the lower flank face sits felt_t below the coated face)
felt_t      = 0.5;
// Gap glass edge -> groove bottom
edge_float  = 1.0;
// Lip rule: the lower flank face stands at most 1.5 mm proud of the coated face ...
lip_proud   = 1.5;
// ... for this width, then it bevels away
lip_flat    = 1.5;
// Bevel run in X per mm of depth (>= 1.46 = the grazing-ray slope; both flanks)
bevel_k     = 1.6;
// Upper flank starts this far outboard of the lower lip edge (+ 0.5 per mm of groove_w above 3.2, see x_ul_of())
ul_off      = 1.0;
// Upper flank thickness above the groove roof
back_flank  = 3.5;
// Felt pad on the closed lower-rear end stop
end_pad     = 1.0;
// Clearance glass (+ felt) -> top glass_stop
stop_gap    = 0.5;
// Closed end-stop thickness
end_t       = 5;
// Top-front glass stop, one per side (printed: hooked on the lid pin, clamped by the lid; steel: M4 bolt along the groove)
// Stop block thickness along the groove
stop_len    = 8;
// Stop inner edge |X| (beyond the glass end, outside the views: asserted)
stop_x0     = 71;
// w range of the stop block (covers the glass edge + felt)
stop_w      = [-6, 2.7];
// Steel: M4 x 16 socket head stop bolt
stop_bolt_len = 16;
// Minimum distance of anything to the frame front face y_front
front_margin = 2;
// Preload screws through the UPPER flank, perpendicular to the glass
// "printed" = printed M10 thumbscrews with felt on the tip; "m4" = M4 nylon screw + square nut
preload_type = "printed";// [printed, m4]
// Screw positions along the groove (the rear one sits where the rear lens clears its head at full stereo travel)
preload_v   = [-18, 20, 65];
// Screw axis |X| (the tip straddles the glass edge)
x_pl        = 74;
// Printed thread major diameter
ps_d        = 10;
// Printed thread pitch (45° flanks, support-free; 1.5 .. 2.5 allowed)
ps_pitch    = 2.0;
// Radial clearance of the printed internal threads: print thread_test and pick the best fit (0.2 / 0.3 / 0.4)
ps_clear    = 0.2;
// Boss wall around the thread
ps_wall     = 3;
// preload_screw threaded length (boss 10 + 2 mm adjustment)
ps_len      = 12;
// Thumb head [diameter over the lobes, height]
ps_head     = [17, 6];
// Preload boss height above the groove roof (= thread length)
boss_h      = 10;

/* [Swappable groove strips] */
// The glass sits in two printed groove strips (one per side) that slide into a channel in the frame's diagonal ribs.
// The ANGLE is still set by the frame: each strip's flat underside rests on the rib's seat face (the plane
// w = -lip_proud), so a strip of uniform thickness cannot change the angle.  The strip carries the lower lip (felt
// face = the reference face), a spine that fills the channel up to its roof, and the lower-rear end stop: a glass that
// is a little too wide / narrow / long / short only needs new strips (strip_glass, in "Measure first"), never a new
// frame.  Two leaf springs in the spine press the strip onto the seat, so it stays in by itself; under each thumbscrew
// the spine drops below the glass top, so the screws press only the glass.  The strips stay inside the rib envelope
// (same optical margins).  They print on their outer face (springs = vertical walls, no bridges).
// true = swappable strips; false = groove integral in the frame (always with hardware = "steel")
groove_strips = hardware == "printed";
// Frame channel length clearance at the lower-rear end (frame geometry)
strip_clr   = 0.2;
// Channel outer wall |X| (frame geometry; the rib keeps x_ch .. x_rw of wall for the roof and the bosses)
x_ch        = 81;
// Strip spine height above the coated face under each thumbscrew (the screw tips must reach the glass top first)
strip_floor = 1.0;
// Strip top -> channel roof clearance (the springs take up the rest)
strip_top_clr = 0.5;
// Strip outer face -> channel wall clearance
strip_side_clr = 0.4;
// Lower-rear end cap thickness (glass end stop) at the nominal glass length (frame geometry: sets the channel length)
strip_cap   = 2.0;
// Lateral key: a ridge on the rib seat (|X| range, under the strip's spine; frame geometry) ...
key_x       = [78.8, 80.2];
// ... ridge height above the seat (frame geometry); the strip underside is relieved over it (a step, open outboard)
key_h       = 0.6;
// ... play between the strip's step and the ridge's inner face (the ridge stops the strip moving outboard)
key_clr     = 0.3;
// Hold-down springs: a thin leaf in the spine top with a bump that stands proud of the roof.  Centres along the groove
// (between the thumbscrews) ...
spring_v    = [-50, 42.5];
// ... free length of each leaf
spring_len  = 26;
// ... leaf thickness
spring_t    = 0.8;
// ... free room under the leaf
spring_gap  = 1.0;
// ... how far the bump stands above the roof (= how far the leaf bends when the strip is in)
spring_bump = 0.35;
// Pull hole through the spine near the open end (hook a bent paper clip in it to pull the strip out)
strip_pull_d = 2.5;

/* [Frame] */
// Side-truss member thickness (X): side plane x = inner_hw .. wall_out
wall_t      = 8;
// Inner face of the side plane |X| (glass + groove + rib)
inner_hw    = 87;
// Base plate thickness (bottom chord; the X-braces take the racking)
base_t      = 6;
// Frame front face Y (glass stop + margin: asserted)
y_front     = -65;
// Frame rear face Y
y_back      = 170;
// Lid rear edge Y (splitter zone)
y_zone_end  = 65;
// Rear deck plate thickness (the rail band under it is rail_band_d deep)
deck_t      = 6;
// Rear carriage plate thickness
t_rear_carriage = 6;
// f38_slide thickness, both slides
t_slide     = 6;
// Front column outboard width (X) at the front face
col_w       = 15;
// Front post depth (Y)
col_d       = 16;
// Clearance highest glass / stop / rib point -> lid underside
lid_clear   = 3;
// Lid rib thickness
rib_t       = 3;
// Rear-deck rib thickness
deck_rib_t  = 3.5;
// Structural deck ribs at x = 0, +-rib_pitch_x (the rear W-truss nodes) ...
rib_pitch_x = 46;
// ... plus intermediate deck ribs at these |x| (keeps the deck / rail-band bridges <= 20 mm)
deck_rib2_x = [23, 69];
// Rear post Y span (carries the rear lid screws)
rp_y        = [51, 65];
// Rear post inner face |X|
rp_x0       = 85;
// Deck strut (rib -> deck front edge) depth in Y
strut_d     = 12;
// Deck side-rib web thickness (outer part of the side plane)
side_rib_t  = 5;
// Diagonal rib cross-section (w) below the groove zone (its underside continues the groove-zone band: no mid-air start)
diag_w_lo   = [-7, 7];
// Tapered gusset at the rib's lower-rear end (where the thick groove rib meets the side-plane band and the rear post):
// longest length (shortened automatically to stay 3 mm above the crosswall top)
gusset_max  = 21;
// Lightening: floor of the blind base pockets (4 layers at 0.4)
skin_t      = 1.6;
// Lattice web thickness (base)
web_t       = 3.5;
// Through-truss members (deck ribs)
truss_web   = 4;
// Diamond lattice pitch, deck ribs (through)
truss_pitch = 40;
// Triangle lattice edge, base pockets (open-top, blind)
base_tri    = 56;
// Recess in the base under the bottom camera's LCD
lcd_recess  = true;
// Window: the recess goes right through the base, so you can see the bottom camera's screen and reach its buttons
lcd_window  = true;
// Window corner radius
lcd_window_r = 6;
// LCD recess floor thickness
lcd_floor_t = 2.0;
// Minimum clearance bottom camera LCD -> base / recess floor at the lowest slide position
lcd_clear_min = 3;
// Side accessory points (1/4"-20 sockets in the front column outer faces): heights
acc_z       = [117.5, 167.5];
// Hood mounting screw heights
hood_bolt_z = [Zs + 17.5, Zs + 42.5];
// Rear rail band depth below the deck top (T-slot 12.7 printed / 9.8 steel)
rail_band_d = hardware == "printed" ? 15 : 13;
// CROSSWALL: vertical wall between the side trusses behind the bottom camera.  The bottom carriage rides on the front
// face y_wf of the WALL_RAIL (a separate bar with the T-slot, printed lying flat), which is bolted to the flat
// mounting face of the wall at y_wf + wrl_t.
// Wall band thickness (Y) behind the wall_rail (bolts, nut slots, pin holes)
cw_band_t   = hardware == "printed" ? 12 : 9;
// Base kept solid under the wall foot: y_wf - web_t .. y_wf + cw_foot_t + web_t
cw_foot_t   = 12;
// Wall thickness below the rail (its front face sits wrl_relief behind the rail face) ...
cw_web_t    = 6;
// ... with blind triangular pockets from the back, leaving this front skin
cw_skin     = 1.6;
// Pocket webs (45° members) in the wall
cw_web      = 4;
// Pocket lattice pitch (45° diamonds; the bottom row is cut into triangles)
cw_pitch    = 24;
// Two vertical stiffening ribs on the wall's back face at x = +-cw_rib_x ...
cw_rib_x    = 30;
// ... [width X, depth Y beyond the web], from the base to the 45° knee under the band
cw_rib      = hardware == "printed" ? [6, 14] : [6, 10];
// Wall rail (T-slot) centre height (the clamp screws sit in the front X-brace window: asserted)
wr_z        = 70;
// Pin rows at wr_z +- wr_off (index row up, datum pair down)
wr_off      = hardware == "printed" ? 11 : 9;
// Scale strip on the rail face above the carriage top (engraved ticks)
wr_scale_h  = 5;
// Index holes over this length (x = -90 .. 90, 10 mm pitch)
wr_idx_len  = 180;
// WALL_RAIL: printed lying flat (back face on the bed), so its T-slot opens upward: no overhangs, no mid-air starts.
// Rail thickness (Y): T-slot (12.7 printed / 9.8 steel deep) + floor
wrl_t       = hardware == "printed" ? 15 : 12;
// Rail bottom edge relative to wr_z (through-bolt row + its counterbore + wall)
wrl_lo      = hardware == "printed" ? -31 : -18;
// The wall web face sits this far behind the rail face: the carriage bears on the rail only
wrl_relief  = 0.5;
// Rail bottom edge above the wall's rail seat (the pins locate the rail, not the seat)
wrl_gap     = 0.3;
// Through-bolt + alignment-pin row relative to wr_z (below the datum row)
wrl_bolt_h  = hardware == "printed" ? -21 : -11;
// Through-bolts: head in a counterbore in the rail face (under the carriage), nut dropped into a slot from the band top
wrl_bolt_x  = [-72, -20, 20, 72];
// Through-bolt length (printed M8 x 21 + printed T-nut / steel M4 x 16 + square nut)
wrl_bolt_len = hardware == "printed" ? 21 : 16;
// Wall material between the mounting face and the nut slot
wrl_nut_f   = 3;
// 2 alignment pins: round rail hole at [0], slotted (along X) at [1]; wall holes round (teardrop)
wrl_dowel_x = hardware == "printed" ? [-56, 56] : [-50, 50];
// Alignment pin length (printed 5 mm pins pressed in; steel: 4 mm dowels, reamed, glued)
wrl_dowel_len = 12;
// Alignment pin hole depth in the wall
wrl_dowel_wall = 6.5;
// X-braces between the two side trusses (racking in the X-Z plane): member width (in the brace plane)
brace_w     = 5;
// X-brace member thickness (Y)
brace_t     = 6;
// Steel: 2 x 4 mm lid dowels in the front post tops (the lid does not rely on screw friction): length
lid_dowel_len   = 12;
// Steel: lid dowel glued into the post top this deep (3 mm proud)
lid_dowel_depth = 9;
// Steel: blind dowel hole depth in the lid underside
lid_dowel_lid   = 3.5;

/* [Printed hardware] */
// Printed threads: two standards with the same 2 mm pitch and 45° flanks: M10 x 2 (ps_d / ps_pitch / ps_clear) where
// space allows (lid, Arca plate), M8 x 2 where a 13 mm head must fit (carriage and slide clamps, wall_rail bolts, hood).
// Screws and bolts print standing (head on the bed), nuts print flat (thread axis vertical), 100 % infill.
// Second printed standard: M8 x 2 (pitch ps_pitch, clearance ps_clear, same 45° form)
t8_d        = 8;
// Lid thumbscrew M10: thread length under the head
lid_sl      = 20;
// Lid thumbscrew lobed head [diameter over the lobes, height]
lid_sh      = [20, 7];
// Carriage rail clamp thumbscrew M8: thread length under the head (tip past the T-nut: asserted)
cs_len      = 17;
// Clamp thumbscrew lobed head [diameter, height], with a hex socket (long key through the front brace window)
cs_head     = [13, 7];
// Hex socket across flats in the clamp thumbscrews and wall_rail bolts
hex_key     = 5;
// T-nut M8 [across the slot, along the slot, thickness]; its 45° top bevels bear on the slot roof
tnut        = [14, 11.6, 5];
// Slide clamp T-bolt M8: square head [side, thickness], sits in a diamond pocket under the carriage
sb_head     = [11, 3.5];
// Slide clamp T-bolt thread length above the head (carriage + slide + thumb-nut)
sb_len      = 16;
// Slide thumb-nut M8 [diameter over the lobes, height]; its bed face is the bearing face
sn_size     = [13, 7];
// wall_rail bolt M8 head [diameter, height] (counterbored under the carriage, hex socket)
wb_head     = [14, 4];
// Printed pins: datum / vernier / wall_rail alignment pin diameter (F38 pins: f38_pin_d)
pin_d       = 5;
// Slip-fit pin hole = pin_d + pin_clr (print pin_test and pick: 0.1 / 0.2 / 0.3)
pin_clr     = 0.2;
// Press-fit pin hole = pin_d + pin_press (alignment pins in the crosswall band)
pin_press   = 0.0;
// glass_stop ear thickness = how far the front post tops sit below frame_top (the ear lies there under the lid)
ear_t       = 4;
// Integral lid pins stand this far above frame_top
lid_pin_up  = 3.0;
// Printed 1/4"-20 UNC female threads for steel screws (printed tripod socket, lid and side accessory points):
// radial clearance at the major diameter (thread_test: 0.1 / 0.2 / 0.3)
unc_clr     = 0.2;
// Printed minor (hole) diameter (UNC 2B: 4.98 .. 5.26; printed holes come out ~0.1 small)
unc_minor   = 5.35;
// tripod_mount = "printed": thread depth (tripod screws engage at most this deep)
tri_thr_depth = 12;
// wrap_clip grip lengths: side members / base + lid / deck ribs
wrap_grip   = [8.5, 6.5, 4.5];
// Number of clips of each length on the wrap_clips plate (incl. spares)
wrap_qty    = [48, 16, 8];

/* [Holes, inserts and steel hardware] */
// 1/4"-20 clearance hole
qtr_clear   = 6.8;
// 1/4"-20 screw head diameter (counterbored into the slide underside)
qtr_head_d  = 13;
// 1/4"-20 screw head height
qtr_head_h  = 4;
// M4 clearance hole
m4_clear    = 4.6;
// Counterbore for an M4 socket head: diameter
m4_head_d   = 8.5;
// Counterbore for an M4 socket head: depth
m4_head_h   = 4.2;
// M4 square nut: width
sqnut_w     = 7.0;
// M4 square nut: thickness
sqnut_t     = 2.5;
// Added to nut width / thickness for nut traps
nut_clear   = 0.3;
// Pin holes (printed pins: slip fit; steel: 3.8, reamed to 4.0)
dowel_hole  = hardware == "printed" ? pin_d + pin_clr : 3.8;
// Steel: lid dowel holes in the post tops (reamed to 4.0, pin glued in with a drop of CA)
lid_dowel_hole = 3.8;
// Carriage datum / vernier pin length (printed 5 x 25 / steel 4 x 25; at least 3 mm proud of the carriage: asserted)
dowel_len   = 25;
// Blind pin / index hole depth in the rails
dowel_depth = 9;
// Heat-set insert 1/4"-20: hole diameter
ins14_d     = 8.0;
// Side accessory points: 1/4"-20 x 10 insert depth
ins14_depth = 10;
// Heat-set insert 3/8"-16: hole diameter
ins38_d     = 11.5;
// Heat-set insert 3/8"-16: hole depth
ins38_depth = 12;
// Lid 1/4"-20 socket depth (leaves 3 mm over the flocked underside)
lid_ins_depth = 8;
// Zip-tie / wrap hole diameter
zip_d       = 4;
// Zip-tie / wrap hole pitch
zip_pitch   = 25;

/* [Tripod] */
// One socket in the base underside, in the crosswall foot just behind the wall front face: stiff plate contact on
// both sides of the screw.
// Socket X
tri_x       = 0;
// The socket pad starts this far behind the crosswall front face
tri_gap     = 2.4;
// 1/4"-20 x 8 mm insert depth (tripod screws engage <= 6.5)
tri_ins_depth = 8;
// Material above the insert (>= 2)
tri_roof    = 2;
// Pad diameter (round boss merged into the base)
tri_pad_d   = 16;
// Base left solid around the socket = tripod plate contact area
tri_solid_d = 46;
// true: 3/8"-16 insert instead of 1/4"-20
tri_38      = false;

/* [Rails, carriages and slides] */
// Rear rail band width (Y)
rail_w      = 36;
// Index hole pitch
rail_pitch  = 10;
// Guide groove width at the rail top (the carriage tongue rides in it); tongues and grooves have 45° sides
key_w       = hardware == "printed" ? 13 : 10;
// Guide groove depth
key_d       = 2;
// T-slot neck width (retains the T-nut)
neck_w      = hardware == "printed" ? 9 : 5;
// T-slot neck depth
neck_d      = 2.5;
// Extra nut-chamber depth below the nut (bolt tip room)
bolt_runout = 1.0;
// Tongue clearance per side
tongue_clear = 0.2;
// Carriage -> rail clamp head seat above the carriage's rail face (printed: the thumbscrew head sits on the carriage)
clamp_seat  = hardware == "printed" ? 6 : 3;
// Rear (deck T-slot) clamp screw length
clamp_bolt_len = hardware == "printed" ? cs_len : 12;
// Bottom (wall_rail T-slot, same profile) clamp screw length
wclamp_bolt_len = hardware == "printed" ? cs_len : 12;
// Rear carriage (clamp screws + pins outside the F38 slide, reachable from above): length X
rc_len      = hardware == "printed" ? 116 : 110;
// Rear carriage width Y
rc_width = 60;
// Rear carriage clamp axis |x|
rc_clamp_x  = hardware == "printed" ? 48.5 : 46;
// Rear carriage datum pin spacing
rc_datum_sep = hardware == "printed" ? 90 : 86;
// Rear carriage vernier pin holes x
rc_vern = [-50, 45];
// Rear rail pin rows at +-rc_idx_off
rc_idx_off = 11;
// Rear rail index holes over this length
rc_idx_len = 180;
// Bottom carriage (flat plate on the wall_rail; clamp screws + pins outside the slide): length X
bc_len      = hardware == "printed" ? 116 : 110;
// Bottom carriage clamp axis |x|
bc_clamp_x  = hardware == "printed" ? 48.5 : 46;
// Bottom carriage datum pin spacing
bc_datum_sep = hardware == "printed" ? 90 : 86;
// Bottom carriage vernier pin holes x
bc_vern = [-50, 45];
// Rear slide travel (fore-aft, Y) for viewpoint matching
rear_travel = 40;
// Bottom slide travel (up-down, Z) for viewpoint matching
bot_travel  = 20;
// Rated rear stereo travel +- (5 mm index steps via the vernier holes; lens clearance asserted)
rear_stereo = 40;
// Rated bottom stereo travel +-
bot_stereo  = 45;
// Slide <-> carriage guide: 45° trapezoid tongue under the slide (root width) in a carriage groove ...
guide_w     = 20;
// ... its depth; wide enough to hide the 1/4" screw head inside it
guide_d     = 2;
// Steel: carriage material between its slide face and the slide clamp nut
slide_nut_roof = 1.5;
// Steel: M4 x 12 slide clamp bolts ...
slide_bolt_len = 12;
// ... under M4 fender washers DIN 9021 (12 mm OD, 0.8 .. 1.2 thick)
slide_washer_t = 1.0;
// Bottom carriage plate thickness
bc_t        = 6;
// Bottom slide slots sit this far above the slide centre (the clamp heads are then in a front X-brace window: asserted)
bot_slot_shift = 4.5;
// Serrations between the bottom slide and its carriage: the camera weight is held by teeth, not clamp friction
// (Z then indexes in serr_pitch steps; false = smooth, friction only)
bot_serr    = true;
// Serration pitch = Z index step (45° teeth)
serr_pitch  = 2;
// Serration tooth height (peak to valley)
serr_depth  = 1;

/* [Lid, hood and shims] */
// Lid plate thickness
lid_t       = 5;
// Lid plate left under the top pockets (light-tight, flocked underneath)
lid_skin    = 2.0;
// Lid rib height
lid_rib_h   = 6;
// ISO 518 cold shoe: slot width
shoe_w      = 18.8;
// Cold shoe slot height
shoe_h      = 2.2;
// Cold shoe throat width
shoe_throat = 12.6;
// Cold shoe length
shoe_len    = 20;
// Cold shoe lip thickness
shoe_lip    = 3.0;
// Cold shoe side walls
shoe_wall   = 5.0;
// Optional hood length
hood_len    = 25;
// Hood wall thickness
hood_wall   = 2.0;
// shim_set thicknesses (camera <-> F38 plate)
shim_t      = [0.5, 1, 2];

/* [Printer] */
// Printer build volume [X, Y, Z]; every large part is checked against it
bed_limit   = [250, 250, 245];

/* [Resolution] */
// Facets: small holes
fn_small = 24;
// Facets: bosses, grips, lens envelopes
fn_big   = 64;
// Printed threads: facets per turn (helical-grid polyhedron, see thread_rod())
fn_thr   = 64;

/* [Hidden] */
// --- DERIVED VALUES (computed; do not edit) ---
// camera vectors: [W (X), H, D (incl. grip), axis height above tripod face, flange->tripod-socket, flange->rear LCD]
cam_a6400 = concat(a6400_size, a6400_meas);
cam_a5100 = concat(a5100_size, a5100_meas);
swap_shim_t = cam_a6400[3] - cam_a5100[3];
s2   = sqrt(2);
eps  = 0.01;

nut_ch_w  = sqnut_w + 2 * nut_clear;
nut_ch_h  = sqnut_t + 0.5 + bolt_runout;
hw_p      = hardware == "printed";
t8_clear  = t8_d + 0.6;
tn_w      = hw_p ? tnut[0] : sqnut_w;
tn_l      = hw_p ? tnut[1] : sqnut_w;
tn_t      = hw_p ? tnut[2] : sqnut_t;
tn_top_w  = hw_p ? neck_w + 0.4 : sqnut_w;
tn_ch_w   = tn_w + 2 * nut_clear;
tn_ch_l   = tn_l + 2 * nut_clear;
cl_d      = hw_p ? t8_clear : m4_clear;
ch_r      = hw_p ? cs_head[0] / 2 : m4_head_d / 2;
sl_slot_w = hw_p ? t8_clear : m4_clear;
sl_edge   = hw_p ? 3.0 : 3.5;
sl_stack  = hw_p ? sn_size[1] : slide_washer_t + m4_head_h;
sl_flange = hw_p ? sn_size[0] : 12;
wrl_clr   = hw_p ? t8_clear : m4_clear;
wrl_hd    = hw_p ? wb_head[0] + 0.6 : m4_head_d;
wrl_hh    = hw_p ? wb_head[1] : m4_head_h;
wrl_half  = hw_p ? 100 : inner_hw + wall_t;
pin_hole  = pin_d + pin_clr;
pin_phole = pin_d + pin_press;
unc_P     = 25.4 / 20;

function tan_h(f)      = sensor_w / 2 / f;
function tan_v(f, asp) = (asp == "3:2" ? sensor_h32 : sensor_h169) / 2 / f;

R15   = lens_15[0] / 2;
R1018 = lens_1018[0] / 2;
L15   = lens_15[1];
L1018 = lens_1018[1];
tv_t  = tan_v(target_f, target_aspect);
th_t  = tan_h(target_f);
wall_out = inner_hw + wall_t;

// Lens rim at y=-R outside the other camera's half-angle theta seen from
// pupil distance D = g + ep:  tan(theta) <= (g - m) / (g + ep + R).
// The rear lens sits on the uncoated side -> the glass thickness is added.
function g_min_for(R, ep, extra) =
    max(R + (plate_clear_min + extra) * s2,
        (rim_margin + tv_t * (ep + R)) / (1 - tv_t));
// The bottom lens wears a screw-in IR filter: a ring of radius Rfilt reaching filt_len beyond the bare front.
// Its front rim sits filt_len closer to the glass (g - filt_len) but ep_1018 is still measured from the bare front,
// so the pupil (and D) do not move with it: the filter rim is a second, narrower "lens rim" nearer the plate.
Rfilt = filt_od / 2;
function g_min_filt(Rf, fl, ep) = fl + max(Rf + plate_clear_min * s2, (rim_margin + tv_t * (fl + ep + Rf)) / (1 - tv_t));
g_min_rear = g_min_for(R15,   ep_15,   plate_t);
g_min_bot  = max(g_min_for(R1018, ep_1018, 0), g_min_filt(Rfilt, filt_len, ep_1018));
g_min      = max(g_min_rear, g_min_bot);
// common pupil distance D: each lens front at least g (design) and its own g_min
D          = max(max(g, g_min_rear) + ep_15, max(g, g_min_bot) + ep_1018);
g_rear     = D - ep_15;
g_bot      = D - ep_1018;

// --- rear camera (a6400, looks -Y) on carriage + f38_slide + F38 stack ---
cam_r      = cam_a6400;
y_rear_front = g_rear;
y_rear_mount = g_rear + L15;
y_rear_sock  = y_rear_mount + cam_r[4];
z_rear_tripod = Zs - cam_a6400[3];
deck_top   = z_rear_tripod - f38_stack - t_slide - t_rear_carriage;
y_rrail    = g + rear_travel / 4 + L15 + cam_r[4];
rear_slot_off = y_rear_sock - y_rrail;
deck_y0    = y_rrail - rc_width / 2;
split_y    = deck_y0 - 1;   // frame_split cut (1 mm ahead of the deck face: avoids a coplanar Nef cut)

// --- bottom camera (a5100, looks +Z, tripod face toward +Y) ---
cam_b      = cam_a5100;
z_bot_front = Zs - g_bot;
z_bot_filt  = z_bot_front + filt_len;
z_bot_mount = z_bot_front - L1018;
z_bot_sock  = z_bot_mount - cam_b[4];
bc_y0      = cam_a6400[3] + f38_stack + t_slide;
bc_yb      = bc_y0 + bc_t;
y_wf       = bc_yb;
y_cwm      = y_wf + wrl_t;
y_cwb      = y_cwm + cw_band_t;
function bot_sock_hi(c)  = Zs - g - L1018 - c[4];
function bot_sock_low(c) = bot_sock_hi(c) - bot_travel;
z_bsock_hi = max([for (c = [cam_a6400, cam_a5100]) bot_sock_hi(c)]);
z_bsock_lo = min([for (c = [cam_a6400, cam_a5100]) bot_sock_low(c)]);
bot_slot_trav = z_bsock_hi - z_bsock_lo;
bc_slot_c  = (z_bsock_hi + z_bsock_lo) / 2;
bot_slot_off = z_bot_sock - bc_slot_c;
bc_bolt_z  = bc_slot_c + bot_slot_shift;
function bot_lcd_low(c)   = Zs - g - bot_travel - L1018 - c[5];

// --- F38 slides ---
slide_bolt_x = f38_base[0] / 2 + 7;
slide_hw     = slide_bolt_x + sl_slot_w / 2 + sl_edge;
serr_wx      = slide_hw - slide_bolt_x + 5 + (hw_p ? 0 : 1);
function slide_len(travel) = max(f38_base[1] + 4, travel + sl_slot_w + 8);
tongue_h     = guide_d - 0.2;
qtr_cb_top   = -tongue_h + qtr_head_h + 0.3;
slide_nut_d  = slide_nut_roof + (sqnut_t + 0.4) / 2;
slide_tip_d  = slide_bolt_len - t_slide - slide_washer_t;

// --- CROSSWALL + bottom carriage (world) ---
bc_z0      = z_bsock_lo - slide_len(bot_slot_trav) / 2 - 1;
bc_z1      = max(z_bsock_hi + slide_len(bot_slot_trav) / 2 + 1, wr_z + wr_off + dowel_hole / 2 + 2);
cw_top     = bc_z1 + 1 + wr_scale_h + 1;
// crosswall + bottom carriage (y >= bc_y0, z <= cw_top) vs the frusta: vertical distance outside the rear frustum
// (15 mm, full 3:2 sensor = widest the rear camera ever sees; 0 if behind its pupil) and horizontal (Y) distance
// outside the bottom frustum (target frame).  Independent of stereo (the cameras move in X only).
m_wall_rear = (Zs - cw_top) - max(0, D - bc_y0) * tan_v(15, "3:2");
m_wall_bot  = bc_y0 - max(0, cw_top - (Zs - D)) * tan_v(fov_f_bot, fov_aspect);
function z_rib_lo(y) = Zs + s2 * w_rib_lo - y;
z_wrl0     = wr_z + wrl_lo;
z_wseat    = z_wrl0 - wrl_gap;
wclamp_tip = wclamp_bolt_len - clamp_seat;
wrl_cb     = wrl_hh + 0.3;
wrl_nut_u  = [wrl_t + wrl_nut_f, wrl_t + wrl_nut_f + tn_t];
wrl_tip_u  = wrl_cb + wrl_bolt_len;
wrl_rib_clr = 1;
// tripod socket pad: ONE socket (1/4"-20, or 3/8"-16 with tri_38) in a round pad in the crosswall foot, just behind
// the wall front face; top of the pad; floor height under a y-range.  tripod_mount: "insert" (heat-set insert),
// "printed" (printed 1/4"-20 UNC in a deeper 20 mm boss), "arca" (no socket; 2 printed M10 threads in bosses for
// the printed Arca-Swiss plate)
tri_pr      = tripod_mount == "printed";
tri_arca    = tripod_mount == "arca";
tri_ins_d   = tri_pr ? unc_minor : tri_38 ? ins38_d : ins14_d;
tri_ins_dep = tri_pr ? tri_thr_depth : tri_38 ? ins38_depth : tri_ins_depth;
tri_pad_dd  = tri_pr ? 20 : (tri_38 && !tri_arca) ? ins38_d + 8 : tri_pad_d;
tri_xy      = [tri_x, y_wf + tri_pad_dd / 2 + tri_gap];
tri_pad_top = max(base_t, tri_ins_dep + tri_roof);
function pad_under(y0, y1) = tri_xy[1] + tri_pad_dd / 2 > y0 && tri_xy[1] - tri_pad_dd / 2 < y1;
function floor_under(y0, y1) = pad_under(y0, y1) ? tri_pad_top : base_t;

// --- glass groove cross-section (x = |X|, w = plate normal) ---
x_lip  = plate_size / 2 - glass_engage;
// upper flank inner edge: x_lip + ul_off at groove_w <= 3.2; a wider groove raises the roof, so the
// edge moves outboard 0.5 per mm of extra width (keeps the lid-view margin)
function x_ul_of(gw) = x_lip + ul_off + max(0, gw - 3.2) / 2;
x_ul   = x_ul_of(groove_w);
x_gb   = plate_size / 2 + edge_float;
x_rw   = inner_hw + 1;
w_lo   = -felt_t;
function w_hi_of(gw) = w_lo + gw;
function w_back_of(gw) = w_hi_of(gw) + back_flank;
w_hi   = w_hi_of(groove_w);
w_back = w_back_of(groove_w);
w_fl   = -lip_proud;
function w_front(x) = x <= x_lip + lip_flat ? w_fl : w_fl - (x - x_lip - lip_flat) / bevel_k;
function w_upper(x, gw = groove_w) = min(w_back_of(gw), w_hi_of(gw) + max(0, x - x_ul_of(gw)) / bevel_k);
w_fr_rw = w_front(x_rw);
v_es   = plate_size / 2 + end_pad;
v_bot  = v_es + end_t;
v_top  = -(plate_size / 2 + end_pad + stop_gap);
w_seat   = w_fl;
x_gb_s   = strip_glass[0] / 2 + edge_float;
v_es_s   = strip_glass[1] - plate_size / 2 + end_pad;
v_s0     = v_top + strip_clr;
v_s1     = v_es + strip_cap;
v_ch_end = v_s1 + strip_clr;
xo_s     = x_ch - strip_side_clr;
sn_half  = ps_d / 2 + 1.5;
sb_h     = strip_top_clr + spring_bump;
sb_run   = 3;
x_sb   = 81.5;  w_sb = 1;   // counterbore (8.5) keeps >= 0.6 wall to the stop's outer face (asserted)
v_seat = v_top - stop_len + m4_head_h;
v_sbnut = v_seat + stop_bolt_len - 0.5 - (sqnut_t + 0.4) / 2;
function boss_r()  = preload_type == "printed" ? ps_d / 2 + ps_clear + ps_wall : nut_ch_w / 2 + 1.2;
boss_x0 = x_pl - boss_r();
boss_l  = 2 * boss_r();
diag_w_up = [w_fr_rw - 0.6, w_back];
w_rib_lo  = min(diag_w_lo[0], diag_w_up[0]);
// rib gusset length: gusset_max, or less so its end stays 3 mm above the crosswall top (z_rib_lo() at its end)
gusset_len = min(gusset_max, s2 * (Zs + s2 * w_rib_lo - cw_top - 3) - v_bot - w_rib_lo);

function pz(v, w) = (w - v) / s2;
function py(v, w) = (v + w) / s2;
top_rel = max([pz(-plate_size / 2, plate_t), pz(v_top, w_back), pz(v_top - stop_len, stop_w[1]),
               for (p = preload_v) pz(p - boss_l / 2, w_hi + boss_h)]);
frame_top = ceil(Zs + top_rel + lid_clear);
rib_front_y  = py(v_top, diag_w_up[0]);
stop_clip_y  = y_front + front_margin;               // glass_stop is clipped to world y >= this
sear_y1      = stop_clip_y + 11;                     // printed: glass_stop ear inboard part only at y <= this
sb_pd        = sb_head[1] + 0.2;

// --- front aperture: posts flare so the target frustum stays clear ---
x_front_in = max(inner_hw, (D - y_front) * th_t + aperture_margin);
y_flare    = min(-30, D - (inner_hw - aperture_margin) / th_t);
x_col_out  = x_front_in + col_w;
z_ap_lo    = Zs - (D - y_front) * tv_t - aperture_margin;
z_ap_hi    = Zs + (D - y_front) * tv_t + aperture_margin;

// --- rail T-slot geometry (nut: tn_* see the top of this section) ---
nut_top_z   = -(key_d + neck_d) - (tn_top_w - neck_w) / 2;
tslot_depth = hw_p ? -nut_top_z + tn_t + 0.5 + bolt_runout + 1.5
                   : key_d + neck_d + (nut_ch_w - neck_w) / 2 + nut_ch_h;
clamp_tip_z = clamp_seat - clamp_bolt_len;

// --- lid bolt positions [x, y] (mirrored in X): front posts, rear posts ---
col_yc     = y_front + col_d / 2;
col_x_bolt = x_front_in + col_w / 2;
rp_xc      = (rp_x0 + wall_out) / 2;
rp_yc      = (rp_y[0] + rp_y[1]) / 2;
lid_y0 = y_front;
lid_y1 = y_zone_end;
fp_x0      = inner_hw;
fp_x1      = x_col_out + 2;
lid_hw     = hw_p ? fp_x1 : x_col_out;
lid_bolts  = hw_p ? [[(fp_x0 + fp_x1) / 2, y_front + col_d + 7], [(rp_x0 + x_col_out) / 2, lid_y1 - 8]]
                  : [[col_x_bolt, col_yc], [rp_xc, rp_yc]];
thr_r      = ps_d / 2 + ps_clear;
lid_thr    = [lid_sl - lid_t - ear_t + 2, lid_sl - lid_t + 2];
fp_top     = frame_top - (hw_p ? ear_t : 0);
fp_y1      = lid_bolts[0][1] + thr_r + 3;
fp_z0      = fp_top - lid_thr[0] - 0.5 - 2 - (lid_bolts[0][1] + thr_r - (y_front + col_d));
                                                     // back face; 45° up to fp_y1 -> >= 2 under the thread everywhere
rp_py0     = lid_bolts[1][1] - thr_r - 3;
rpz0       = frame_top - lid_thr[1] - 0.5 - 2 - max(0, lid_bolts[1][0] + thr_r - wall_out, rp_y[0] - (lid_bolts[1][1] - thr_r));

// --- plate coverage ---
h_plate = plate_size / 2 - glass_engage;
function cov_ok(f, asp, d) =
    let(tv = tan_v(f, asp), th = tan_h(f))
    (s2 * d * tv / (1 - tv) <= h_plate) && (d * th / (1 - tv) <= h_plate);
function f_min_cov(asp, d) = [for (f = [8 : 0.1 : 80]) if (cov_ok(f, asp, d)) f][0];

// --- lens rim vs other camera's frustum ---
rim_ang_bot_lens  = atan((g_bot  - rim_margin) / (D + R1018)); // rear cam must stay inside this (bare barrel rim)
rim_ang_bot_filt  = atan((g_bot - filt_len - rim_margin) / (D + Rfilt));
rim_ang_rear_lens = atan((g_rear - rim_margin) / (D + R15));   // bottom cam must stay inside this
theta_v_target    = atan(tv_t);

// --- lens <-> glass clearance measured normal to the plate ---
clr_rear_plate = (g_rear - R15) / s2 - plate_t;
clr_bot_plate  = min((g_bot - R1018) / s2, (g_bot - filt_len - Rfilt) / s2);

// --- frusta vs rib / lips / stops / bosses / heads (pinhole pupils, target frame) ---
// A plate-local point p = [x, v, w] -> world; margin = distance (mm, lateral)
// outside the rear camera's straight frustum and the bottom camera's straight
// frustum.  At stereo 0 the straight frusta cover everything: the rear camera's
// reflected view (upward, the "lid view") coincides with the bottom one's, and vice
// versa.  In stereo the lid views shift with the pupils -> see the clipping readout.
function pl2w(p) = [p[0], (p[1] + p[2]) / s2, Zs + (p[2] - p[1]) / s2];
function m_rear(P) = let(d = D - P[1]) d <= 1 ? 999 : max(abs(P[0]) - d * th_t, abs(P[2] - Zs) - d * tv_t);
function m_bot(P)  = let(d = P[2] - (Zs - D)) d <= 1 ? 999 : max(abs(P[0]) - d * th_t, abs(P[1]) - d * tv_t);
function m_pt(p) = let(P = pl2w(p)) min(m_rear(P), m_bot(P));
function min_m(pts) = min([for (p = pts) m_pt(p)]);
v_samp  = [for (v = [v_top : 0.1 : v_bot]) v];
x_bev   = [for (t = [0 : 1 / 16 : 1]) x_lip + lip_flat + t * (x_rw - x_lip - lip_flat)];
x_bevu  = [for (t = [0 : 1 / 16 : 1]) x_ul + t * (x_rw - x_ul)];
m_lower = min_m([for (v = v_samp) each concat([[x_lip, v, w_fl]], [for (x = x_bev) [x, v, w_front(x)]])]);
m_upper = min_m([for (v = v_samp) each concat([[x_lip, v, w_lo], [x_ul, v, w_hi]], [for (x = x_bevu) [x, v, w_upper(x)]])]);
m_boss  = min_m([for (p = preload_v, dv = [-boss_l / 2 : boss_l / 8 : boss_l / 2], w = [w_hi : boss_h / 8 : w_hi + boss_h]) [boss_x0, p + dv, w]]);
ph_r    = preload_type == "printed" ? ps_head[0] / 2 : m4_head_d / 2;
ph_w    = preload_type == "printed" ? [w_hi + boss_h + 2 - 0.7, w_hi + boss_h + 2 + ps_head[1]] : [w_hi + boss_h - 0.7, w_hi + boss_h + m4_head_h];
m_head  = min_m([for (p = preload_v, a = [0 : 5 : 355], w = [ph_w[0], ph_w[0] + 0.7, ph_w[1]]) [x_pl + ph_r * cos(a), p + ph_r * sin(a), w]]);
m_stop  = min_m([for (v = [v_top - stop_len : stop_len / 8 : v_top], w = [stop_w[0] : 0.5 : stop_w[1]], x = [stop_x0, x_rw]) [x, v, w]]);
m_side  = min_m([for (v = [v_top : 0.5 : v_bot + 120], w = [diag_w_up[0], w_rib_lo]) [inner_hw, v, w]]);
m_foam  = min_m([for (v = v_samp, w = [plate_t, w_hi]) [x_ul, v, w]]);
m_tip   = min_m([for (p = preload_v, dv = [-ps_d / 2 : ps_d / 8 : ps_d / 2]) [x_pl - ps_d / 2, p + dv, plate_t]]);

// --- stereo: bottom lens front rim vs the rib underside (plate-local w of a rim point vs the lower flank; the rim is
//     the barrel's highest-w part, so the rim check covers the whole bottom lens) ---
function wloc(y, z) = (y + z - Zs) / s2;
clr_bot_rib = min([for (rz = [[R1018, z_bot_front], [Rfilt, z_bot_filt]], a = [0 : 5 : 355])
                   let(x = abs(-bot_stereo + rz[0] * cos(a)), y = rz[0] * sin(a))
                   x > x_lip ? w_front(x) - wloc(y, rz[1]) : 99]);
// Rear lens: the WHOLE barrel (not only its front rim: a thumbscrew head can sit beside the barrel in stereo)
// vs the +X rib's upper flank, every preload boss (all faces, 0.5 mm grid) and every thumbscrew head
// (discs at the bottom / tightened / top), as signed distances to the finite lens cylinder at x = sx (the -X side is
// the mirror image).  Real lens (>= 2 asserted) and its clearance envelope (+3 radius, +5 each end; >= 0 asserted).
function rng(a, b, st) = [for (i = [0 : ceil((b - a) / st - 1e-9)]) min(b, a + i * st)];
function d_lens(P, sx, R, y0, y1) = let(r = norm([P[0] - sx, P[2] - Zs]), Y = P[1])
    (Y >= y0 && Y <= y1) ? (r >= R ? r - R : -min([R - r, Y - y0, y1 - Y]))
                         : let(dy = Y < y0 ? y0 - Y : Y - y1) (r <= R ? dy : norm([r - R, dy]));
function box_pts(x0, x1, v0, v1, w0, w1, st = 0.5) = let(xs = rng(x0, x1, st), vs = rng(v0, v1, st), ws = rng(w0, w1, st)) concat(
    [for (x = [x0, x1], v = vs, w = ws) [x, v, w]], [for (v = [v0, v1], x = xs, w = ws) [x, v, w]],
    [for (w = [w0, w1], x = xs, v = vs) [x, v, w]]);
lens_pts = concat(
    [for (p = preload_v) each box_pts(boss_x0, x_rw, p - boss_l / 2, p + boss_l / 2, w_hi, w_hi + boss_h)],
    [for (p = preload_v, w = [ph_w[0], ph_w[0] + 0.7, ph_w[1]], r = [ph_r, ph_r * 2 / 3, ph_r / 3, 0], a = [0 : 5 : 355])
        [x_pl + r * cos(a), p + r * sin(a), w]],
    [for (x = rng(x_ul, x_rw, 1), v = rng(v_top, v_bot, 1)) [x, v, w_upper(x)]]);
function clr_rear_lens(sx, grow = 0) = min([for (q = lens_pts)
    d_lens(pl2w(q), sx, R15 + grow, y_rear_front - (grow > 0 ? lens_clear_l / 2 : 0), y_rear_mount + (grow > 0 ? lens_clear_l / 2 : 0))]);
clr_rear_rib = clr_rear_lens(rear_stereo);
clr_rear_env = clr_rear_lens(rear_stereo, lens_clear_d / 2);
clr_rear_stereo = rp_x0 - (rear_stereo + R15);
clr_bot_stereo  = inner_hw - (bot_stereo + R1018);

// --- part sizes in print orientation (analytic, verified from STL output) ---
hood_x_far = (D - y_front + hood_len) * th_t + aperture_margin + hood_wall;
size_frame    = [2 * lid_hw, y_back - y_front, frame_top + (hw_p ? lid_pin_up : 0)];
size_lid      = [2 * lid_hw, lid_y1 - lid_y0, lid_t + lid_rib_h + shoe_h + shoe_lip + 1];
size_wrl      = [2 * wrl_half, cw_top - (wr_z + wrl_lo), wrl_t];
size_hood     = [2 * hood_x_far, hood_len + 4, 2 * ((D - y_front + hood_len) * tv_t + aperture_margin + hood_wall)];

// --- Stereo clipping readout ---
//  Pinhole rays over a clip_grid of the target frame (target_f, target_aspect) from each pupil; rear = transmitted,
//  bottom = reflected by the coated face.  Every pixel carries TWO views:
//   * SCENE legs (pupil -> plate -> out of the front): the ray is CLIPPED if it
//     meets the plate outside the clear aperture (+-h_plate) or crosses any
//     obstacle on its way; for a WRAPPED rig also if it leaves through the side
//     plane (= hits the wrap on its outer face) before the front face;
//   * the LID-VIEW leg: from the coated-face point P straight up, direction
//     (u th, -s tv, 1) for BOTH cameras (rear: 50 % reflection, bottom: 50 %
//     transmission).  At stereo 0 it lands on the flocked lid underside; in stereo
//     it shifts with the pupil.  First hit on another part (flank, boss,
//     thumbscrew head, stop, post, rear lens) = "part" (imaged at 50 %: flock /
//     paint it matt black); missing the lid = "outside" (sees the world through
//     the open truss: the side wrap stops it).
//  Crops (largest centred crop, same aspect, clean in BOTH images): "wrapped" = scene
//  legs + wrap; "unwrapped" = scene legs | lid view sees a part | lid view outside.
//  Obstacles are convex solids = lists of half-spaces [nx, ny, nz, c] (inside:
//  n.p <= c).  Same geometry in tools/stereo_clip.py (an independent re-implementation
//  with exact cylinders, used as a cross-check).
function hs_box(lo, hi) = [[1, 0, 0, hi[0]], [-1, 0, 0, -lo[0]], [0, 1, 0, hi[1]], [0, -1, 0, -lo[1]],
                           [0, 0, 1, hi[2]], [0, 0, -1, -lo[2]]];
// plate-local half-space a x + b v + c w <= k  ->  world
function hs_pl(a, b, c, k) = [a, (b + c) / s2, (c - b) / s2, k - (b - c) * Zs / s2];
function hs_plpoly(pts, v0, v1, sx = 1) = concat(
    [for (i = [0 : len(pts) - 1]) let(p = pts[i], q = pts[(i + 1) % len(pts)], nx = q[1] - p[1], nw = p[0] - q[0])
        hs_pl(sx * nx, 0, nw, nx * p[0] + nw * p[1])],
    [hs_pl(0, 1, 0, v1), hs_pl(0, -1, 0, -v0)]);
function hs_plbox(x0, x1, v0, v1, w0, w1, sx = 1) = hs_plpoly([[x0, w0], [x1, w0], [x1, w1], [x0, w1]], v0, v1, sx);
function hs_xypoly(pts, z0, z1) = concat(
    [for (i = [0 : len(pts) - 1]) let(p = pts[i], q = pts[(i + 1) % len(pts)], nx = q[1] - p[1], ny = p[0] - q[0])
        [nx, ny, 0, nx * p[0] + ny * p[1]]],
    [[0, 0, 1, z1], [0, 0, -1, -z0]]);
function hs_mirror_x(H, sx = -1) = [for (h = H) [sx * h[0], h[1], h[2], h[3]]];
function hs_cyl_y(x0, z0, R, y0, y1, n = 16) = concat([for (k = [0 : n - 1]) let(a = 360 * k / n)
    [cos(a), 0, sin(a), x0 * cos(a) + z0 * sin(a) + R / cos(180 / n)]], [[0, 1, 0, y1], [0, -1, 0, -y0]]);
function hs_cyl_z(x0, y0, R, z0, z1, n = 16) = concat([for (k = [0 : n - 1]) let(a = 360 * k / n)
    [cos(a), sin(a), 0, x0 * cos(a) + y0 * sin(a) + R / cos(180 / n)]], [[0, 0, 1, z1], [0, 0, -1, -z0]]);
function hs_cyl_w(x0, v0, R, w0, w1, n = 16) = concat([for (k = [0 : n - 1]) let(a = 360 * k / n)
    hs_pl(cos(a), sin(a), 0, x0 * cos(a) + v0 * sin(a) + R / cos(180 / n))], [hs_pl(0, 0, 1, w1), hs_pl(0, 0, -1, -w0)]);
function hs_hood() = let(y1 = y_front - hood_len, zr = [Zs - 200, Zs + 200]) [
    for (s = [-1, 1]) concat([[-s, -th_t, 0, -(aperture_margin + th_t * D)], [s, th_t, 0, aperture_margin + hood_wall + th_t * D]],
                              [[0, 1, 0, y_front], [0, -1, 0, -y1], [0, 0, 1, zr[1]], [0, 0, -1, -zr[0]]]),
    for (s = [-1, 1]) concat([[0, -tv_t, -s, -(aperture_margin + tv_t * D) - s * Zs], [0, tv_t, s, aperture_margin + hood_wall + tv_t * D + s * Zs]],
                              [[0, 1, 0, y_front], [0, -1, 0, -y1], [1, 0, 0, 300], [-1, 0, 0, 300]])];
function clip_upper(sx) = [
    hs_plpoly([[x_ul, w_hi], [x_rw, w_hi], [x_rw, w_back], [x_ul + (w_back - w_hi) * bevel_k, w_back]], v_top, v_bot, sx),
    hs_plbox(x_gb, x_rw, v_top, v_bot, w_lo, w_hi, sx),
    hs_plbox(x_ul, x_gb, v_top, v_es, plate_t, w_hi, sx),
    hs_plbox(stop_x0, inner_hw - 0.3, v_top - stop_len, v_top, stop_w[0], stop_w[1], sx),
    hs_plbox(inner_hw, wall_out, v_top, v_bot, diag_w_up[0], diag_w_up[1], sx),
    for (p = preload_v) each [
        hs_plbox(boss_x0, x_rw, p - boss_l / 2, p + boss_l / 2, w_hi, w_hi + boss_h, sx),
        hs_mirror_x(hs_cyl_w(x_pl, p, ph_r, ph_w[0], ph_w[1], 32), sx),
        hs_mirror_x(hs_cyl_w(x_pl, p, ps_d / 2, plate_t, ph_w[0], 32), sx)],
    hs_mirror_x(hs_xypoly([[inner_hw, max(y_flare, y_front)], [x_front_in, y_front], [x_col_out, y_front],
               [x_col_out, y_front + col_d], [inner_hw, y_front + col_d]], 0, frame_top), sx),
    hs_box([min(sx * rp_x0, sx * wall_out), rp_y[0], 0], [max(sx * rp_x0, sx * wall_out), rp_y[1], frame_top]),
    if (hw_p) each [
        hs_mirror_x(concat(hs_box([fp_x0, y_front + col_d, fp_z0], [fp_x1, fp_y1, frame_top]), [[0, 1, -1, y_front + col_d - fp_z0]]), sx),
        hs_mirror_x(hs_box([x_col_out, y_front, fp_top - (fp_x1 - x_col_out)], [fp_x1, y_front + col_d, frame_top]), sx),
        hs_mirror_x(hs_box([stop_x0, stop_clip_y, fp_top], [fp_x0, sear_y1, frame_top]), sx),
        hs_mirror_x(concat(hs_box([rp_x0, rp_y[0], rpz0], [x_col_out, y_zone_end, frame_top]), [[1, 0, -1, wall_out - rpz0]]), sx),
        hs_mirror_x(concat(hs_box([inner_hw, rp_py0, rpz0], [x_col_out, rp_y[0], frame_top]),
                           [[0, -1, -1, -(rpz0 + rp_y[0])], [1, 0, -1, wall_out - rpz0]]), sx)]];
lid_box = hs_box([-lid_hw, lid_y0, frame_top], [lid_hw, lid_y1, frame_top + lid_t + lid_rib_h]);
function clip_obstacles(sr, sb, cam) = concat(
    [for (sx = [-1, 1]) each concat([
        hs_plbox(x_lip, x_lip + lip_flat, v_top, v_bot, w_fl, w_lo, sx),
        hs_plpoly([[x_lip + lip_flat, w_fl], [x_rw, w_front(x_rw)], [x_rw, w_lo], [x_lip + lip_flat, w_lo]], v_top, v_bot, sx),
        hs_plbox(x_lip, x_rw, v_es, v_bot, w_lo, w_hi, sx),
        hs_plbox(inner_hw, wall_out, v_bot, v_bot + 250, w_rib_lo, diag_w_lo[1], sx)],
        clip_upper(sx))],
    [lid_box,
     hs_box([-wall_out, y_front, 0], [wall_out, y_back, base_t]),
     hs_box([-brace_x - 1, brace_y0, 0], [brace_x + 1, brace_y1, brace_top_z]),
     hs_box([-wall_out, y_wf, 0], [wall_out, y_cwb, cw_top]),
     hs_box([-wall_out, deck_y0, deck_top - rail_band_d], [wall_out, y_back, deck_top])],
    cam == "rear" ? [hs_cyl_z(-sb, 0, R1018, z_bot_mount, z_bot_front), hs_cyl_z(-sb, 0, Rfilt, z_bot_front - 1, z_bot_filt)]
                  : [hs_cyl_y(sr, Zs, R15, y_rear_front, y_rear_mount)],
    show_hood ? hs_hood() : []);
function lid_view_parts(sr) = concat(clip_upper(-1), clip_upper(1), [hs_cyl_y(sr, Zs, R15, y_rear_front, y_rear_mount)]);
function seg_t(o, d, t0, t1, H) = let(
    dn = [for (h = H) h[0] * d[0] + h[1] * d[1] + h[2] * d[2]],
    nm = [for (h = H) h[3] - (h[0] * o[0] + h[1] * o[1] + h[2] * o[2])],
    out = [for (i = [0 : len(H) - 1]) if (abs(dn[i]) < 1e-12 && nm[i] < 0) 1],
    ta = max(concat([t0], [for (i = [0 : len(H) - 1]) if (dn[i] < -1e-12) nm[i] / dn[i]])),
    tb = min(concat([t1], [for (i = [0 : len(H) - 1]) if (dn[i] > 1e-12) nm[i] / dn[i]])))
    (len(out) == 0 && ta < tb - 1e-9) ? ta : 1e9;
function seg_hits(o, d, t0, t1, H) = seg_t(o, d, t0, t1, H) < 1e8;
function any_hit(o, d, t0, t1, obs, i = 0) = i >= len(obs) ? false
    : seg_hits(o, d, t0, t1, obs[i]) ? true : any_hit(o, d, t0, t1, obs, i + 1);
y_far = y_front - hood_len - 20;
function ray_clip(cam, u, s, sr, sb, obs, lobs) = let(
    rear = cam == "rear",
    o  = rear ? [sr, D, Zs] : [-sb, 0, Zs - D],
    d  = rear ? [u * th_t, -1, s * tv_t] : [u * th_t, -s * tv_t, 1],
    tp = D / (1 - s * tv_t),
    P  = o + tp * d,
    vP = (P[1] - P[2] + Zs) / s2,
    tb = rear ? (D - plate_t * s2) / (1 - s * tv_t) : tp,
    ep = rear ? ep_15 : ep_1018,
    r  = [u * th_t, -1, s * tv_t],
    scene = abs(P[0]) > h_plate || abs(vP) > h_plate
            || any_hit(o, d, ep, tb - 1e-6, obs) || any_hit(P, r, 1e-6, P[1] - y_far, obs),
    tw = abs(r[0]) < 1e-9 ? 1e9 : (sign(r[0]) * wall_out - P[0]) / r[0],
    wrap = !scene && P[1] - tw > y_front && P[2] + tw * r[2] > 0 && P[2] + tw * r[2] < frame_top,
    l  = [u * th_t, -s * tv_t, 1],
    te = frame_top + lid_t + lid_rib_h + 1 - P[2],
    tl = scene ? 1e9 : seg_t(P, l, 1e-6, te, lid_box),
    lid = scene ? 0 : any_hit(P, l, 1e-6, min(tl, te), lobs) ? 1 : (tl < 1e8 ? 0 : 2))
    [scene ? 1 : 0, wrap ? 1 : 0, lid];
function clip_map(cam, sr, sb) = let(obs = clip_obstacles(sr, sb, cam), lobs = lid_view_parts(sr),
                                     nx = clip_grid[0], ny = clip_grid[1])
    [for (j = [0 : ny - 1], i = [0 : nx - 1]) let(u = -1 + (2 * i + 1) / nx, s = -1 + (2 * j + 1) / ny)
        concat([u, s], ray_clip(cam, u, s, sr, sb, obs, lobs))];
function cheb(bad) = min(concat([1], [for (r = bad) max(abs(r[0]), abs(r[1]))]));
function clip_stats(m) = let(nx = clip_grid[0], ny = clip_grid[1], stop = 1 - 1 / ny,
    wb = [for (r = m) if (r[2] == 1 || r[3] == 1) r],
    ub = [for (r = m) if (r[2] == 1 || r[4] > 0) r])
    [100 * len(wb) / len(m), 100 * len([for (r = wb) if (r[1] >= stop - 1e-9) r]) / nx, cheb(wb),
     100 * len([for (r = m) if (r[2] == 0 && r[4] == 1) 1]) / len(m),
     100 * len([for (r = m) if (r[2] == 0 && r[4] == 2) 1]) / len(m), cheb(ub)];

function seg_dist2d(p, a, b) = let(d = b - a, t = max(0, min(1, ((p - a) * d) / (d * d)))) norm(p - (a + t * d));
function brace_clear(x, z) = min([for (s = [-1, 1]) each [
    seg_dist2d([x, z], [s * brace_x, brace_z0 - 3], [0, brace_z1]),
    seg_dist2d([x, z], [s * brace_x, brace_z1], [0, brace_z0 - 3])]]) - brace_w / 2;
function max_bolt(seat, floor_d) = seat + floor_d - 0.3;
// ... which stereo_bot index steps leave all four bottom clamp heads reachable straight from the front (key line >= 2.5
// from every brace member and from the post inner face); the other steps: from the open sides with an L-key
function key_ok(x, z) = brace_clear(x, z) >= 2.5 && abs(x) <= inner_hw - 2.5;
qtr_under   = t_slide - qtr_cb_top;
qtr_engage  = qtr_screw_len - qtr_under;
f38_pin_hole = f38_pin_d - 0.1;
function box_c(lo, sz) = [lo[0] + sz[0] / 2, lo[1] + sz[1] / 2, lo[2] + sz[2] / 2];
function mix2(a, va, b, vb) = (a * va + b * vb) / (va + vb);
cog_bought = let(cr = cam_r, cb = cam_b) [
    ["rear_body", mix2(box_c([-cr[0] / 2, y_rear_mount, z_rear_tripod], [cr[0], cr[5], cr[1]]), cr[0] * cr[5] * cr[1],
                       box_c([-cr[0] / 2, y_rear_mount - (cr[2] - cr[5]), z_rear_tripod], [28, cr[2] - cr[5], cr[1]]),
                       28 * (cr[2] - cr[5]) * cr[1]) + [stereo_rear, 0, 0]],
    ["rear_lens", [stereo_rear, y_rear_front + L15 / 2, Zs]],
    ["rear_f38",  [stereo_rear, y_rear_sock, z_rear_tripod - f38_stack / 2]],
    ["bot_body",  mix2(box_c([-cb[0] / 2, cb[3] - cb[1], z_bot_mount - cb[5]], [cb[0], cb[1], cb[5]]), cb[0] * cb[1] * cb[5],
                       box_c([cb[0] / 2 - 25, cb[3] - cb[1], z_bot_mount], [25, cb[1], cb[2] - cb[5]]), 25 * cb[1] * (cb[2] - cb[5]))
                  + [-stereo_bot, 0, 0]],
    ["bot_lens",  [-stereo_bot, 0, z_bot_mount + L1018 / 2]],
    ["bot_f38",   [-stereo_bot, bc_y0 - t_slide - f38_stack / 2, z_bot_sock]],
    ["glass",     [0, plate_t / 2 / s2, Zs + plate_t / 2 / s2]],
    ["bot_filter", [-stereo_bot, 0, z_bot_front + filt_len / 2]]];

// Summary first, so the margins are visible even when an assert below stops the run.
echo(str("\n==== BEAM-SPLITTER RIG SUMMARY ====",
    "\n HARDWARE: ", hardware, hw_p ? str(" -- printed M10 x 2 / M8 x 2 thumbscrews, T-nuts, thumb-nuts, bolts, pins O", pin_d,
    " (holes ", pin_hole, "), wrap clips, printed 1/4\"-20 UNC female threads (lid, side points)") : " -- M4 bolts, square nuts, steel dowels, inserts",
    "   tripod_mount: ", tripod_mount, tri_arca ? " (printed Arca plate, 2 x M10)" : tri_pr ? str(" (printed 1/4\"-20, ", tri_ins_dep, " deep)")
    : str(" (heat-set insert ", tri_38 ? "3/8\"-16" : "1/4\"-20", ")"),
    "\n TARGET FRAME: target_f = ", target_f, " mm ", target_aspect, " (default 19 = the smallest 0.5 mm step that passes",
    " with the default IR filter)   drawn frusta: rear ", fov_f_rear, " / bottom ", fov_f_bot, " mm",
    "\n measured inputs: axis a6400 ", cam_a6400[3], " / a5100 ", cam_a5100[3], ", f38_stack ", f38_stack,
    " (entered at the upper end of the reading: each camera errs low / toward its mount; the shim_set takes it up)",
    "   swap_shim ", swap_shim_t,
    "\n IR filter (bottom lens): O", filt_od, " x ", filt_len, " beyond the bare front -> filter front ", g_bot - filt_len,
    " from the plate centre (bare front ", g_bot, "; ep_1018 from the bare front)",
    "\n Zs = ", Zs, "   frame_top = ", frame_top, "   deck_top = ", deck_top, "   D = ", D,
    "\n g_min = ", g_min, " (rear ", g_min_rear, ", bottom ", g_min_bot, ")   g_rear = ", g_rear, "   g_bot = ", g_bot,
    "\n rear pupil match: slide offset ", rear_slot_off, " of +-", rear_travel / 2,
    "   bottom: ", bot_slot_off, " of +-", bot_slot_trav / 2, " (slot = ", bot_travel, " travel + both bodies' socket offsets)",
    "\n lens-plate clearance: rear ", clr_rear_plate, "  bottom ", clr_bot_plate, " (barrel ", (g_bot - R1018) / s2,
    ", IR filter ", (g_bot - filt_len - Rfilt) / s2, ")",
    "\n rim-clear angle (deg): bottom lens ", rim_ang_bot_lens, "  its IR filter ", rim_ang_bot_filt, "  rear lens ", rim_ang_rear_lens,
    "  target half-VFOV ", theta_v_target,
    "\n min full-coverage f (pinhole, h=", h_plate, "): 3:2 ", f_min_cov("3:2", D),
    "  16:9 ", f_min_cov("16:9", D),
    "\n frusta margins (pinhole, ", target_f, " mm ", target_aspect, ", stereo 0): lower lip ", m_lower,
    "  upper flank ", m_upper, "  bosses ", m_boss, "  thumbscrew heads ", m_head, "  screw tips ", m_tip, "  glass_stop ", m_stop,
    "  side plane ", m_side, "  roof felt edge ", m_foam, "  (0.1 mm sampling; upper felt strip ", x_gb - x_ul, " wide)",
    "\n stereo clearances at the rated travel (rear +-", rear_stereo, ", bottom +-", bot_stereo, "): rear lens-post ", clr_rear_stereo,
    "  rear lens (whole barrel) vs rib / bosses / thumbscrew heads ", clr_rear_rib, " (envelope ", clr_rear_env, ")",
    "  bottom lens-side ", clr_bot_stereo, "  bottom lens-rib ", clr_bot_rib,
    "\n STEREO CLIP (rear +", stereo_rear, ", bottom -", stereo_bot, "; split interaxial ", stereo_rear + stereo_bot,
    "; ", clip_grid[0], "x", clip_grid[1], " rays = +-", 200 / clip_grid[0], " % per column, ", target_f, " mm ", target_aspect,
    clip_run ? "" : clip_check ? " -- stereo 0: nothing clipped (asserted margins), rays not traced" : " -- clip_check OFF", "):",
    "\n   WRAPPED rig (scene legs; the side wrap is on): rear ", clip_r[0], " % area, ", clip_r[1], " % of top row   bottom ",
    clip_b[0], " % area, ", clip_b[1], " % of top row   common clean centred crop ", clip_k, " % (w and h)",
    "\n   lid views (50 % reflection / transmission, up to the lid): rear sees a part on ", clip_r[3], " %, the outside on ",
    clip_r[4], " %   bottom: part ", clip_b[3], " %, outside ", clip_b[4], " %   -> UNWRAPPED rig crop ", clip_ku, " %",
    "\n bottom position lowest LCD z: a6400 ", bot_lcd_low(cam_a6400), "  a5100 ", bot_lcd_low(cam_a5100),
    " (recess floor ", lcd_floor, ")",
    "\n front aperture half-width = ", x_front_in, " (flare from y=", y_flare, ")",
    "   z ", z_ap_lo, " .. ", z_ap_hi,
    "\n frame bbox = ", size_frame, "  top rel S = ", top_rel, "  rib front y = ", rib_front_y,
    "\n rear stack printed: carriage ", t_rear_carriage, " + slide ", t_slide, " = ", t_rear_carriage + t_slide,
    "   deck_top ", deck_top, "   rear lens bottom above the F38 plate top ", cam_r[3] - R15,
    " (base reaches ", max(0, f38_base[1] / 2 - cam_r[4]), " in front of the flange)",
    "\n rear clamp ", hw_p ? "M8x" : "M4x", clamp_bolt_len, " tip z = ", clamp_tip_z, " (nut ", nut_top_z, " .. ", nut_top_z - tn_t,
    ", floor ", -tslot_depth, ", max length ", max_bolt(clamp_seat, tslot_depth), ")",
    "\n crosswall: wall_rail face y = ", y_wf, "  mounting face y = ", y_cwm, "  band back y = ", y_cwb, "  rail z ", z_wrl0, " .. ", cw_top,
    " (T-slot at ", wr_z, ")  carriage z ", bc_z0, " .. ", bc_z1, "  frustum margins: rear (15 mm 3:2) ", m_wall_rear, "  bottom ", m_wall_bot,
    "\n wall clamp ", hw_p ? "M8x" : "M4x", wclamp_bolt_len, " tip depth ", wclamp_tip, " (nut ", -nut_top_z, " .. ", -nut_top_z + tn_t,
    ", floor ", tslot_depth, ", max length ", max_bolt(clamp_seat, tslot_depth), ")",
    "\n wall_rail: ", 2 * wrl_half, " x ", cw_top - z_wrl0, " x ", wrl_t, " (printed flat), ", len(wrl_bolt_x), hw_p ? " x M8x" : " x M4x", wrl_bolt_len,
    " through-bolts at x ", wrl_bolt_x, " z ", wr_z + wrl_bolt_h, ": tip ", wrl_tip_u - wrl_nut_u[1], " past the nut (slot from the band top),",
    hw_p ? str(" pins O", pin_d, "x") : " dowels O4x", wrl_dowel_len, " at x ", wrl_dowel_x, " (", wrl_dowel_wall, " in the wall, ", wrl_dowel_len - wrl_dowel_wall, " in the rail)",
    "\n front-brace window clearance of the hex-key lines: carriage clamps ", brace_clear(bc_clamp_x, wr_z),
    "  slide clamps ", brace_clear(slide_bolt_x, bc_bolt_z), "   all 4 bottom clamps reachable from the front at stereo_bot = ",
    key_steps, " (other steps: from the open sides)",
    "\n slides: rear ", 2 * slide_hw, " x ", slide_len(rear_travel), " x ", t_slide, "  bottom ", 2 * slide_hw, " x ",
    slide_len(bot_slot_trav), hw_p ? str("  printed M8 T-bolts (", sb_eng, " in the ", sn_size[1], " mm thumb-nut, pocket roof ",
    min(bc_t, t_rear_carriage) - sb_pd, ") at x = +-", slide_bolt_x) : str("  bolts M4x", slide_bolt_len, " at x = +-", slide_bolt_x,
    " (tip ", slide_tip_d, " below the carriage face, nut ", slide_nut_d, ")"),
    "\n F38 base screw 1/4\"-20 x ", qtr_screw_len, ": ", qtr_under, " of slide under the base, ", qtr_engage,
    " into its thread (depth ", f38_thread_depth, ")", f38_pins ? str("   pins ", f38_pin_d, " in ", f38_pin_hole,
    " press holes, ", f38_pin_depth, " deep") : "   no locating pins",
    "\n preload thread M", ps_d, " x ", ps_pitch, ": depth ", thr_h(ps_pitch), ", radial engagement ", thr_h(ps_pitch) - ps_clear,
    hw_p ? str("\n lid: 4 x M10x", lid_sl, " thumbscrews, engagement front ", lid_eng[0], " (lid + glass_stop ear) / rear ", lid_eng[1],
    " in post-top pads (margin to every frustum / lid view ", m_pads, "), 2 integral pins O", pin_d, " x ", lid_pin_up, " above the posts",
    "   frame height with the pins ", size_frame[2]) : "",
    "\n dowels proud of the carriage: rear ", dowel_len - dowel_depth - t_rear_carriage,
    "  bottom ", dowel_len - dowel_depth - bc_t,
    "\n tripod ", tri_arca ? str("Arca plate ", arca_len, " x ", arca_w, " (2 x M10 at x +-", arca_bx, ") under") : str(tri_38 ? "3/8\"-16" : "1/4\"-20",
    tri_pr ? " printed thread" : " insert"), " at ", tri_xy, " (pad top z ", tri_arca ? arca_boss_top : tri_pad_top, "): stiff plate contact y ",
    tri_xy[1] - tri_solid_d / 2, " .. ", tri_xy[1] + tri_solid_d / 2, " (solid O", tri_solid_d, ", LCD recess ends at y ", lcd_y[1],
    ") + crosswall foot y ", y_wf - web_t, " .. ", y_wf + cw_foot_t + web_t,
    "\n========================================"));
echo("COG_BOUGHT", tri_xy = tri_xy, rear_body = cog_bought[0][1], rear_lens = cog_bought[1][1], rear_f38 = cog_bought[2][1],
     bot_body = cog_bought[3][1], bot_lens = cog_bought[4][1], bot_f38 = cog_bought[5][1], glass = cog_bought[6][1],
     bot_filter = cog_bought[7][1]);

// --- Checks ---
module fits_bed(name, s) {
    assert(s[0] <= bed_limit[0] && s[1] <= bed_limit[1] && s[2] <= bed_limit[2],
           str(name, " exceeds the bed: ", s));
}
fits_bed("frame", size_frame);
fits_bed("top_lid", size_lid);
fits_bed("wall_rail", size_wrl);
fits_bed("hood", size_hood);

assert(clr_rear_plate >= plate_clear_min - 1e-9,
       str("Rear lens too close to the plate: ", clr_rear_plate));
assert(clr_bot_plate >= plate_clear_min - 1e-9,
       str("Bottom lens (barrel rim or IR filter ring) too close to the plate: ", clr_bot_plate));
assert(theta_v_target <= rim_ang_bot_lens + 1e-9,
       str("Bottom lens rim inside the rear camera's target frustum: clear angle ",
           rim_ang_bot_lens, " < ", theta_v_target));
assert(theta_v_target <= rim_ang_bot_filt + 1e-9,
       str("Bottom lens IR filter rim inside the rear camera's target frustum: clear angle ",
           rim_ang_bot_filt, " < ", theta_v_target, " (filt_od / filt_len: measure; or a larger target_f)"));
assert(theta_v_target <= rim_ang_rear_lens + 1e-9,
       str("Rear lens rim inside the bottom camera's target frustum: clear angle ",
           rim_ang_rear_lens, " < ", theta_v_target));
assert(abs(rear_slot_off) <= rear_travel / 2,
       str("Rear pupil match needs ", rear_slot_off, " of slide travel (limit +-", rear_travel / 2, ")"));
assert(abs(bot_slot_off) <= bot_slot_trav / 2 + 0.01,
       str("Bottom pupil match out of Z travel (", bot_slot_off, " of +-", bot_slot_trav / 2, "): raise Zs"));
lcd_floor = lcd_recess ? (lcd_window ? 0 : lcd_floor_t) : base_t;
for (c = [cam_a6400, cam_a5100]) {
    assert(bot_lcd_low(c) >= lcd_floor + lcd_clear_min,
           str("Bottom camera (LCD ", c[5], ") hits the base at full travel: lowest LCD z = ",
               bot_lcd_low(c), " < ", lcd_floor + lcd_clear_min, " -> raise Zs or cut bot_travel"));
    assert(bot_sock_low(c) - slide_len(bot_slot_trav) / 2 >= floor_under(bc_y0 - t_slide, bc_y0) + 1,
           str("Bottom f38_slide hits the base / tripod pad at full travel (body socket offset ", c[4], ")"));
    assert(bot_sock_low(c) >= z_bsock_lo - 0.01 && bot_sock_hi(c) <= z_bsock_hi + 0.01, "Bottom slide slot too short for a body");
    assert(bot_sock_low(c) - f38_base[1] / 2 >= floor_under(bc_y0 - t_slide - f38_stack, bc_y0 - t_slide) + 1,
           "Tripod pad under the bottom F38 base at the lowest slide position");
}
assert(bc_z0 >= floor_under(bc_y0, bc_yb) + 1.5, str("Bottom carriage bottom edge z ", bc_z0, " too close to the base / pad"));
// Rear lens barrel above the F38 base: with a low camera axis the barrel reaches down to about the tripod face, so it is
// checked where the F38 base actually reaches under the lens (f38_base[1] / 2 - flange->socket in front of the flange).
// Only the default rear lens is checked.
assert(f38_base[1] / 2 <= cam_r[4] || cam_r[3] - R15 >= 0.5,
       str("Rear lens barrel (R ", R15, ") only ", cam_r[3] - R15, " above the F38 plate top where the base reaches in front of the flange"));
assert(clr_rear_stereo >= 3, str("Rear stereo travel: lens hits the rear post: ", clr_rear_stereo));
assert(clr_rear_rib >= 2, str("Rear stereo travel: lens barrel hits a rib / preload boss / thumbscrew head: ", clr_rear_rib,
                              " (< 2) -> lower rear_stereo (5 mm steps) or move preload_v[2]"));
assert(clr_rear_env >= 0, str("Rear stereo travel: lens clearance envelope (+3 radius) hits a boss / thumbscrew head: ", clr_rear_env));
// the actual stereo setting must stay inside the rated (checked) travel
assert(abs(stereo_rear) <= rear_stereo + 0.01 && abs(stereo_bot) <= bot_stereo + 0.01,
       str("stereo_rear / stereo_bot (", stereo_rear, " / ", stereo_bot, ") beyond the rated travel +-", rear_stereo, " / +-", bot_stereo));
assert(clr_bot_stereo >= 3, str("Bottom stereo travel: lens hits the side plane: ", clr_bot_stereo));
assert(clr_bot_rib >= 2, str("Bottom stereo travel: lens hits the rib underside: ", clr_bot_rib));
assert(bot_stereo + bc_len / 2 <= wrl_half + 5, "Bottom carriage overhangs the wall_rail end by > 5 mm at full stereo travel");
// clamp nuts stay inside the (open-ended) T-slots at the stereo ends (never slide past the last index with a bolt loose)
assert(rear_stereo + rc_clamp_x + tn_ch_l / 2 <= wall_out && bot_stereo + bc_clamp_x + tn_ch_l / 2 <= wrl_half,
       str("Carriage clamp (T-)nut leaves the open T-slot end at full stereo travel: rear ", rear_stereo + rc_clamp_x + tn_ch_l / 2,
           " > ", wall_out, " or bottom ", bot_stereo + bc_clamp_x + tn_ch_l / 2, " > ", wrl_half));
// ... when it passes the side plane (open lower triangle) it must stay under the diagonal rib
assert(bc_z1 + 2 <= z_rib_lo(y_wf), str("Bottom carriage top z ", bc_z1, " hits the side-plane rib (", z_rib_lo(y_wf), ") in stereo"));
assert(bc_vern[0] - bot_stereo >= -wr_idx_len / 2 || bc_vern[1] - bot_stereo >= -wr_idx_len / 2, "Bottom stereo end not indexable");
assert(rear_stereo + rc_len / 2 <= wall_out + 5, "Rear carriage overhangs the deck by > 5 mm at full stereo travel");
assert(z_ap_lo > base_t && z_ap_hi < frame_top, "Target frustum hits base or lid at the front");
assert(lip_proud <= 1.5, str("Lip rule: lower flank stands ", lip_proud, " > 1.5 proud of the coated face"));
assert(bevel_k >= 1.46, "Lip rule: flank bevel shallower than the grazing rays (bevel_k < 1.46)");
remedy = str(" -> entrance pupil too deep (D = ", D, ") for a ", target_f, " mm ", target_aspect,
             " common frame on the glass plate",
             ": set target_f = ", target_f + 1,
             " (or ", target_f + 2, ") and fov_f_* the same, or re-measure ep_15 / ep_1018 / filt_len / filt_od");
assert(m_lower >= lip_margin_min, str("Lower (coated-side) groove flank inside a frustum: margin ", m_lower,
                                      " < ", lip_margin_min, remedy));
assert(m_upper >= lip_margin_min, str("Upper groove flank inside a frustum: margin ", m_upper,
                                      " < ", lip_margin_min, remedy, " (or a narrower groove_w)"));
assert(m_foam  >= lip_margin_min, str("Groove-roof foam edge inside a frustum: margin ", m_foam, remedy));
assert(m_boss  >= lip_margin_min, str("Preload boss inside a frustum: margin ", m_boss));
assert(m_head  >= lip_margin_min, str("Preload screw head inside a frustum: margin ", m_head, " (smaller ps_head or higher boss_h?)"));
assert(m_tip   >= lip_margin_min, str("Preload screw tip inside a frustum: margin ", m_tip));
assert(m_stop  >= lip_margin_min, str("glass_stop inside a frustum: margin ", m_stop));
assert(m_side  >= lip_margin_min, str("Diagonal rib (side plane) inside a frustum: margin ", m_side));
assert(groove_w >= plate_t + felt_t + 0.3, "Groove too narrow for glass + felt");
assert(!groove_strips || hw_p, "groove_strips needs hardware = \"printed\" (the steel glass_stop bolt crosses the strip channel)");
// worst case: the pane slides sideways by its edge float and the strip moves outboard by its play (ridge or channel
// wall, whichever stops it first); the pane must still overlap the lip by 0.5
strip_out_play = min(key_clr, strip_side_clr);
assert(!groove_strips || strip_glass[0] / 2 - x_lip - edge_float - strip_out_play >= 0.5 - 1e-9,
       str("Glass too narrow for the strips: worst-case lip overlap ", strip_glass[0] / 2 - x_lip - edge_float - strip_out_play,
           " < 0.5 mm (minimum glass width ", 2 * (x_lip + edge_float + strip_out_play + 0.5), " mm)"));
assert(!groove_strips || x_gb_s + 2 <= xo_s,
       str("Glass too wide for the channel: strip spine only ", xo_s - x_gb_s, " mm thick"));
assert(!groove_strips || v_s1 - v_es_s >= 1.2 - 1e-9,
       str("Glass too long for the strips: end cap ", v_s1 - v_es_s, " mm (use 0.5 mm end felt or raise strip_cap)"));
assert(!groove_strips || v_es_s >= max(preload_v) + ps_d / 2 + 1,
       str("Glass too short for the strips: end cap at v ", v_es_s, " would sit under the rear preload screw (v ",
           max(preload_v), ") -- minimum glass length ", max(preload_v) + ps_d / 2 + 1 + plate_size / 2 - end_pad, " mm"));
assert(!groove_strips || x_gb_s <= key_x[0] - key_clr - 0.5,
       str("Glass too wide for the keyed strips: spine starts at ", x_gb_s, " (must be <= ", key_x[0] - key_clr - 0.5,
           " so the spine still rests on the seat beside the key step) -- max glass width ", 2 * (key_x[0] - key_clr - 0.5 - edge_float), " mm"));
assert(gusset_len >= 8, str("Rib gusset only ", gusset_len, " mm long: the crosswall top is too close under the rib"));
assert(!groove_strips || v_bot - v_ch_end >= 2.0, str("Rib end wall behind the strip channel only ", v_bot - v_ch_end, " mm"));
assert(!groove_strips || strip_floor <= plate_t - 0.8,
       str("strip_floor ", strip_floor, " is too close to the glass top (", plate_t, "): the thumbscrew tips would land on the strip"));
for (c = spring_v) {
    assert(!groove_strips || min([for (p = preload_v) abs(c - p)]) >= spring_len / 2 + sn_half + 2,
           str("Strip spring at v ", c, " runs into a thumbscrew notch: move spring_v or shorten spring_len"));
    assert(!groove_strips || (c - spring_len / 2 >= v_s0 + strip_pull_d + 4 && c + spring_len / 2 <= v_es_s - 2),
           str("Strip spring at v ", c, " runs past the strip ends"));
}
// the leaf must still bend freely if the printed roof sits 0.3 mm low
assert(!groove_strips || spring_gap >= spring_bump + 0.3 + 0.2, "spring_gap too small for the leaf to bend");
function spring_mpa(d) = 12 * 3500 * d * spring_t / (spring_len * spring_len);
assert(!groove_strips || spring_mpa(spring_bump + 0.3) <= 35,
       str("Strip springs overstressed: ", spring_mpa(spring_bump + 0.3), " MPa (> 35): longer or thinner leaf, or less bump"));
function spring_n(d) = 192 * 3500 * (xo_s - x_gb_s) * pow(spring_t, 3) / 12 * d / pow(spring_len, 3);
echo(str("GROOVE STRIPS: glass ", strip_glass[0], " x ", strip_glass[1], "  edge engagement ", strip_glass[0] / 2 - x_lip,
         "  spine ", xo_s - x_gb_s, "  end cap ", v_s1 - v_es_s, "  rib end wall ", v_bot - v_ch_end,
         "  under the screws ", plate_t - strip_floor, " below the glass top",
         "  springs ", len(spring_v), " x ", round(10 * spring_n(spring_bump)) / 10, " N (",
         round(spring_mpa(spring_bump)), " MPa; ", round(10 * spring_n(spring_bump + 0.3)) / 10, " N if the roof sits 0.3 low)"));
assert(x_gb - plate_size / 2 >= 0.5, "No edge float at the groove bottom");
assert(x_pl - ps_d / 2 <= plate_size / 2 - 0.5, "Preload screw tip misses the glass");
assert(rib_front_y >= y_front + front_margin, str("Rib top end (y = ", rib_front_y, ") too close to the front face"));
assert(py(v_top, stop_w[1]) >= stop_clip_y + 3, "glass_stop clipped too far by the front face -> move y_front forward");
assert(x_col_out - ins14_depth >= x_front_in + 3, "Front column too narrow for the side accessory inserts");
assert(col_d >= ins14_d + 6, "Front column too shallow (Y) for the side accessory inserts");
assert(clamp_tip_z <= nut_top_z - tn_t - 0.3 && clamp_tip_z >= -tslot_depth + 0.3,
       str("Clamp bolt ", hw_p ? "M8x" : "M4x", clamp_bolt_len, ": tip at ", clamp_tip_z, " must pass the nut (",
           nut_top_z - tn_t, ") and clear the chamber floor (", -tslot_depth, ")"));
assert(slide_bolt_x - sl_flange / 2 >= f38_base[0] / 2 + (hw_p ? 0.5 : 0) - 1e-9,
       str("Slide clamp ", hw_p ? "thumb-nuts" : "fender washers", " (O", sl_flange, ") under the F38 base"));
assert(qtr_engage >= 4.5 && qtr_engage <= f38_thread_depth - 0.5,
       str("1/4\" F38 base screw engages ", qtr_engage, " mm (", qtr_screw_len, " - ", qtr_under, " of slide) in a ",
           f38_thread_depth, " mm thread: need 4.5 .. ", f38_thread_depth - 0.5, " -> choose qtr_screw_len"));
assert(!f38_pins || (f38_pin_d >= 2.5 && f38_pin_d <= 6 && f38_pin_sp / 2 - f38_pin_hole / 2 >= qtr_clear / 2 + 3),
       str("F38 locating pins: diameter ", f38_pin_d, " / spacing ", f38_pin_sp, " do not fit the slide (or set f38_pins = false)"));
assert(f38_lever[0] <= 0 || f38_lever[1] >= sl_stack + 0.5
       || f38_base[0] / 2 + f38_lever[0] <= slide_bolt_x - sl_flange / 2 - 0.5,
       str("F38 release lever (", f38_lever, ") hits the slide clamp washers / bolt heads: turn the base so the lever points along the travel"));
assert(clamp_bolt_len <= max_bolt(clamp_seat, tslot_depth) && wclamp_bolt_len <= max_bolt(clamp_seat, tslot_depth),
       "Clamp bolt longer than its T-slot allows (bottoms out on the chamber floor)");
assert(wclamp_tip >= -nut_top_z + tn_t + 0.3 && wclamp_tip <= tslot_depth - 0.3,
       str("Wall clamp bolt ", hw_p ? "M8x" : "M4x", wclamp_bolt_len, ": tip depth ", wclamp_tip, " must pass the nut (", -nut_top_z + tn_t,
           ") and clear the slot floor (", tslot_depth, ")"));
assert(wr_off - dowel_hole / 2 >= key_w / 2 + 1 && wr_off - dowel_hole / 2 >= tn_ch_w / 2 + 1,
       "Wall dowel rows too close to the T-slot");
assert(tslot_depth + 2 <= wrl_t && dowel_depth + 2 <= wrl_t, "wall_rail too thin for the T-slot / dowel holes (floor >= 2)");
assert(wr_z + key_w / 2 + 2 <= z_rib_lo(y_wf + tslot_depth), "Wall T-slot end runs into the diagonal rib (nuts cannot go in)");
assert(z_rib_lo(y_wf + dowel_depth) - wrl_rib_clr >= wr_z + wr_off + dowel_hole / 2 + 1 && cw_top <= z_rib_lo(y_wf) - wrl_rib_clr,
       "wall_rail end chamfer (under the diagonal rib) cuts into an index hole, or the rail top reaches the rib");
assert(wrl_cb >= wrl_hh + 0.2 && wrl_bolt_h + wrl_hd / 2 <= -(key_w / 2) - 1 && wrl_bolt_h - wrl_hd / 2 >= wrl_lo + 2,
       str("wall_rail through-bolt counterbore (row ", wrl_bolt_h, ") too close to the key groove or the rail bottom (", wrl_lo, ")"));
assert(wrl_tip_u >= wrl_nut_u[1] + 1 && wrl_tip_u <= y_cwb - y_wf + 6,
       str("wall_rail through-bolt ", hw_p ? "M8x" : "M4x", wrl_bolt_len, ": tip at ", wrl_tip_u, " must pass the nut (", wrl_nut_u[1], ") by 1"));
assert(wrl_nut_f >= 2.5 && cw_band_t - wrl_nut_f - (tn_t + 0.4) >= 2 && wr_z + wrl_bolt_h + wrl_clr / 2 + 1 <= cw_top - 3,
       "Crosswall band too thin for the through-bolt nut slots");
for (xb = wrl_bolt_x, xo = concat([for (s = [-1, 1]) s * bc_datum_sep / 2], wrl_dowel_x))
    assert(abs(xb - xo) - wrl_hd / 2 - dowel_hole / 2 >= 3, str("wall_rail through-bolt at x ", xb, " too close to a dowel hole at x ", xo));
assert(abs(abs(wrl_dowel_x[0]) - bc_datum_sep / 2) >= dowel_hole + 2 && abs(abs(wrl_dowel_x[1]) - bc_datum_sep / 2) >= dowel_hole + 2
       && wrl_dowel_wall <= cw_band_t - 2 && wrl_dowel_len - wrl_dowel_wall <= wrl_t && wrl_dowel_len - wrl_dowel_wall >= 4,
       "wall_rail alignment dowels: too close to the datum holes, or pin engagement wall / rail out of range");
assert(z_wrl0 <= wr_z - wr_off - dowel_hole / 2 - 2 && cw_top >= bc_z1 + wr_scale_h && wrl_relief >= 0.3,
       "wall_rail does not cover the carriage datum row / scale strip, or no web relief");
assert(m_wall_rear >= aperture_margin && m_wall_bot >= aperture_margin,
       str("Crosswall / bottom carriage inside a camera frustum: margins rear (15 mm 3:2 full frame) ", m_wall_rear, ", bottom ", m_wall_bot));
assert(cw_top <= Zs - R15 - lens_clear_d / 2 - 3, "Crosswall top too close to the rear lens envelope");
assert(y_wf >= (plate_size / 2 + plate_t) / s2 + 5, "Crosswall inside the glass (seated) zone");
assert(y_cwb + max(0, wrl_tip_u - (y_cwb - y_wf)) <= deck_y0 - 3, "Crosswall (+ through-bolt tips) runs into the rear deck / deck strut");
// slide clamp nut pocket fits both 6 mm carriages: roof >= 1.5, tip past the nut, floor under the tip
assert(hw_p || (slide_nut_d - (sqnut_t + 0.4) / 2 >= 1.5 - 0.01 && slide_tip_d >= slide_nut_d + (sqnut_t + 0.4) / 2 + 0.3
       && slide_tip_d <= min(bc_t, t_rear_carriage) - 0.6),
       str("Slide clamp M4x", slide_bolt_len, ": nut at ", slide_nut_d, ", tip ", slide_tip_d, " does not fit a 6 mm carriage"));
assert(min(bc_t, t_rear_carriage) - guide_d >= 3.5, "Carriage too thin under the slide guide groove");
assert(t_slide - qtr_cb_top >= 3, str("1/4\" screw head counterbore leaves only ", t_slide - qtr_cb_top, " mm under the F38 base"));
assert(guide_w - 2 * tongue_clear - 2 * tongue_h >= qtr_head_d + 1 + 1.5, "Slide tongue too narrow to hide the 1/4\" head");
assert(f38_pin_depth <= t_slide - 1, "F38 pin holes break through the slide");
for (x = concat([rc_clamp_x - ch_r, rc_datum_sep / 2 - dowel_hole / 2],
                [for (v = rc_vern) abs(v) - dowel_hole / 2],
                [bc_clamp_x - ch_r, bc_datum_sep / 2 - dowel_hole / 2], [for (v = bc_vern) abs(v) - dowel_hole / 2]))
    assert(x >= slide_hw + 0.5, str("Carriage clamp/dowel at |x| ", x, " under an f38_slide (", slide_hw, ")"));
for (e = concat([for (v = rc_vern) rc_len / 2 - abs(v) - dowel_hole / 2], [for (v = bc_vern) bc_len / 2 - abs(v) - dowel_hole / 2],
                [rc_len / 2 - rc_clamp_x - ch_r, bc_len / 2 - bc_clamp_x - ch_r]))
    assert(e >= 2.5, str("Carriage hole only ", e, " mm from the carriage end (>= 2.5: a reamed pin hole needs its wall)"));
assert(tslot_depth + 2 <= rail_band_d, "Rail band too shallow for the T-slot");
assert(brace_clear(bc_clamp_x, wr_z) >= 2.5 && brace_clear(slide_bolt_x, bc_bolt_z) >= 2.5,
       str("Bottom clamp bolts not reachable through the front X-brace windows: ", brace_clear(bc_clamp_x, wr_z), " / ",
           brace_clear(slide_bolt_x, bc_bolt_z)));
// Dowel pins must stand proud of the carriage in every datum / vernier hole (else they can't be pulled)
for (t = [t_rear_carriage, bc_t, 6])
    assert(dowel_len - dowel_depth - t >= 3,
           str("Dowel pin ", dowel_len, " mm stands only ", dowel_len - dowel_depth - t,
               " mm proud of a ", t, " mm carriage (need >= 3): longer pins or shallower rail holes"));
assert(dowel_depth + 2 <= rail_band_d, "Rail dowel holes too deep for the rail band");
assert(tri_pad_top - tri_ins_dep >= tri_roof, "Tripod insert roof < tri_roof");
assert(abs(tri_xy[0]) + tri_pad_dd / 2 <= inner_hw - 5 && tri_xy[1] - tri_pad_dd / 2 >= lcd_y[1] + 1
       && tri_xy[1] + tri_pad_dd / 2 <= y_back - 10, "Tripod pad in the LCD recess / outside the base");
assert(tri_arca || (tri_xy[1] - tri_solid_d / 2 >= lcd_y[1] && abs(tri_xy[0]) + tri_solid_d / 2 <= inner_hw),
       str("Tripod contact circle (O", tri_solid_d, ", from y ", tri_xy[1] - tri_solid_d / 2, ") runs into the LCD recess (ends at y ",
           lcd_y[1], ") or out of the base"));
assert(tri_xy[1] - tri_pad_dd / 2 >= y_wf || tri_xy[1] + tri_pad_dd / 2 <= y_wf,
       "Tripod pad straddles the crosswall front face (put it fully in front of or behind y_wf)");
assert(ps_pitch >= 1.5 && ps_pitch <= 2.5, "ps_pitch outside 1.5 .. 2.5 (2.0 recommended)");
assert(thr_h(ps_pitch) - ps_clear >= 0.25,
       str("Printed thread engagement ", thr_h(ps_pitch) - ps_clear, " < 0.25: coarser pitch or less ps_clear"));
assert(hw_p || x_sb + m4_head_d / 2 <= inner_hw - 0.3 - 0.6, "glass_stop counterbore breaks through the outer face");
assert(hw_p || w_sb - sqnut_w / 2 - w_front(x_sb - nut_ch_w / 2) >= 1.0 - 0.01,
       str("glass_stop nut slot leaves only ", w_sb - sqnut_w / 2 - w_front(x_sb - nut_ch_w / 2), " mm to the rib's lower bevel"));
assert(cw_web_t + cw_rib[1] >= wrl_t && cw_web_t + cw_rib[1] <= wrl_t + cw_band_t
       && (tri_arca || cw_rib_x - cw_rib[0] / 2 >= abs(tri_xy[0]) + tri_pad_dd / 2 + 2),
       "Crosswall back ribs: do not reach behind the mounting face into the 45° knee, stand proud of the band, or sit on the tripod pad");
assert(lid_t + lid_rib_h - lid_ins_depth >= 2.5, str("Lid 1/4\" insert hole leaves only ", lid_t + lid_rib_h - lid_ins_depth,
       " mm over the flocked underside"));
assert(hw_p || lid_dowel_depth + 1 <= 12 - (sqnut_t + 0.4) / 2, "Lid dowel hole runs into the lid-bolt nut pocket");
assert((hw_p ? lid_pin_up : lid_dowel_len - lid_dowel_depth) <= lid_dowel_lid - 0.3 && lid_dowel_lid <= lid_t - 1.2,
       "Lid dowel: pin longer than its lid hole, or lid hole roof < 1.2");
// X-braces stay below the front aperture and clear of the bottom camera bodies (y >= -30)
assert(brace_top_z + 3 <= z_ap_lo, str("Front X-brace (top z ", brace_top_z, ") reaches into the aperture (", z_ap_lo, ")"));
assert(brace_y1 <= min(cam_a6400[3] - cam_a6400[1], cam_a5100[3] - cam_a5100[1]) - 10,
       "Front X-brace too close to the bottom camera body");
// ---- printed hardware ----
// post-top pads + glass_stop ear outside both straight frusta (= the lid views at stereo 0; in stereo the clipping readout
// traces them), sampled on a 1 mm grid of their bounding boxes' faces (conservative: the pads' 45° undersides are inside)
function m_w(P) = min(m_rear(P), m_bot(P));
function m_wbox(lo, hi) = min([for (p = box_pts(lo[0], hi[0], lo[1], hi[1], lo[2], hi[2], 1)) m_w(p)]);
m_pads = !hw_p ? 99 : min([m_wbox([fp_x0, y_front + col_d, fp_z0], [fp_x1, fp_y1, fp_top]),
                           m_wbox([fp_x0, y_front, fp_top], [fp_x1, fp_y1, frame_top]),
                           m_wbox([stop_x0, stop_clip_y, fp_top], [fp_x0, sear_y1, frame_top]),
                           m_wbox([rp_x0, rp_y[0], rpz0], [x_col_out, y_zone_end, frame_top]),
                           m_wbox([inner_hw, rp_py0, rpz0], [x_col_out, rp_y[0], frame_top])]);
lid_eng = [lid_sl - lid_t - ear_t, lid_sl - lid_t];
sb_eng  = sb_len - (min(bc_t, t_rear_carriage) - sb_pd) - t_slide;
if (hw_p) {
    assert(m_pads >= lip_margin_min, str("Post-top pad / glass_stop ear inside a camera frustum or lid view: margin ", m_pads));
    assert(lid_eng[0] >= 10 && lid_eng[0] <= lid_thr[0] - 1 && lid_eng[1] >= 10 && lid_eng[1] <= lid_thr[1] - 1,
           str("Lid thumbscrew M10x", lid_sl, ": engagement front ", lid_eng[0], " / rear ", lid_eng[1], " (need >= 10, <= thread depth - 1)"));
    assert(min(lid_bolts[0][0] - thr_r - fp_x0, fp_x1 - lid_bolts[0][0] - thr_r, fp_y1 - lid_bolts[0][1] - thr_r,
               lid_bolts[1][0] - thr_r - rp_x0, x_col_out - lid_bolts[1][0] - thr_r, y_zone_end - lid_bolts[1][1] - thr_r,
               lid_bolts[1][1] - thr_r - rp_py0) >= 2.5 && lid_bolts[1][1] - thr_r >= rp_y[0] && lid_bolts[1][0] - thr_r >= inner_hw + 1,
           "Post-top pad wall around a lid thumbscrew thread < 2.5 (rear: thread inside the post's y range, forward lip at x >= inner_hw)");
    assert(norm(lid_bolts[0] - lid_dowels[0]) - thr_r - pin_hole / 2 >= 4 && lid_dowels[0][0] + pin_d / 2 <= fp_x1 - 1.5
           && abs(lid_dowels[0][1] - col_yc) + pin_d / 2 <= col_d / 2 - 1.5, "Lid pin too close to the thread / the column edge");
    assert(y_front + hood_nut_y + (tn_t + 0.4) / 2 + 2 <= lid_bolts[0][1] - thr_r
           || hood_bolt_z[1] + tn_w / 2 + 0.3 + 2 <= fp_top - lid_thr[0] - 0.5, "Hood T-nut slot runs into the front lid thread");
    assert(hood_nut_y - (tn_t + 0.4) / 2 >= 3 && cs_len - 4 >= hood_nut_y + tn_t / 2 + 0.3 && cs_len - 4 <= col_d - 1,
           "Hood clamp thumbscrew does not reach through its T-nut (or pokes out of the column)");
    assert(min(bc_t, t_rear_carriage) - sb_pd >= 2, str("Slide T-bolt pocket roof ", min(bc_t, t_rear_carriage) - sb_pd, " < 2"));
    assert(!bot_serr || bc_clamp_x - cs_head[0] / 2 >= slide_bolt_x - 5 + serr_wx + 0.3,
           "Bottom clamp thumbscrew head sits on the carriage's serration teeth");
    assert(sb_eng >= sn_size[1] - 1 && sb_eng <= sn_size[1] + 2,
           str("Slide T-bolt M8x", sb_len, ": ", sb_eng, " mm inside the ", sn_size[1], " mm thumb-nut (need ", sn_size[1] - 1, " .. ", sn_size[1] + 2, ")"));
    for (c = [[rc_clamp_x, rc_datum_sep, rc_vern, rc_idx_off], [bc_clamp_x, bc_datum_sep, bc_vern, wr_off]], sx = [-1, 1])
        for (q = concat([[c[1] / 2 * sx, -c[3]]], [for (v = c[2]) [v, c[3]]]))
            assert(norm([sx * c[0], 0] - q) - cs_head[0] / 2 - pin_d / 2 >= 1,
                   str("Clamp thumbscrew head at x ", sx * c[0], " touches the pin at ", q));
    assert(pin_d >= 4 && pin_d <= 8 && pin_clr >= 0 && pin_clr <= 0.5, "Printed pin diameter 4 .. 8, clearance 0 .. 0.5");
    assert(thr_h(unc_P) > 0 && 25.4 / 8 + unc_clr - unc_minor / 2 >= 0.5 && unc_minor <= 5.6,
           "Printed 1/4\"-20 thread: unc_minor too large for the steel screw's flanks");
    assert(!tri_pr || tri_ins_dep >= 10, "Printed tripod thread shallower than 10 mm");
    assert(t8_d < ps_d && thr_h(ps_pitch) - ps_clear >= 0.25, "M8 x 2 printed standard");
}
assert(!tri_arca || (tri_xy[1] - arca_w / 2 >= lcd_y[1] + 1 && arca_bx + arca_boss_d / 2 <= inner_hw - 5 && arca_len / 2 <= inner_hw
                     && lid_sl - (arca_t - arca_cb) >= 12 && arca_boss_top <= z_wseat - 5 && arca_bx - arca_boss_d / 2 >= 8),
       "Arca plate / bosses: into the LCD recess, out of the base, short thread engagement or boss into the crosswall knee");



// --- Helpers ---
// Prisms: extrude a 2D profile along an axis, centred on the origin.
//   xprism: 2D x -> world Y, 2D y -> world Z
//   yprism: 2D x -> world X, 2D y -> world Z
module xprism(len) rotate([90, 0, 90]) translate([0, 0, -len / 2]) linear_extrude(len) children();
module yprism(len) rotate([90, 0, 0])  translate([0, 0, -len / 2]) linear_extrude(len) children();

module cyl_x(d, l, fn = fn_small) rotate([0, 90, 0]) cylinder(d = d, h = l, center = true, $fn = fn);
module cyl_y(d, l, fn = fn_small) rotate([90, 0, 0]) cylinder(d = d, h = l, center = true, $fn = fn);
module cyl_z(d, l, fn = fn_small) cylinder(d = d, h = l, center = true, $fn = fn);

module slot_x(len, w, h) hull() for (s = [-1, 1]) translate([s * len / 2, 0, 0]) cyl_z(w, h);
module slot_y(len, w, h) hull() for (s = [-1, 1]) translate([0, s * len / 2, 0]) cyl_z(w, h);

// Square-nut pocket: nut plane normal to Z at the origin, pocket runs out
// along +X for `run` (so the nut can be pushed in from a face).
module sqnut_pocket_z(run) translate([-nut_ch_w / 2, -nut_ch_w / 2, -(sqnut_t + 0.4) / 2])
    cube([run + nut_ch_w / 2, nut_ch_w, sqnut_t + 0.4]);

module diamond2d(r) polygon([[r, 0], [0, r], [-r, 0], [0, -r]]);

// mirror_x() carries the mirror state in $mx so the printed THREAD CUTTERS (thread_hole / m_hole / unc_hole) can undo
// the reflection locally: a mirrored helix is LEFT-handed and would not take the right-handed printed / steel screws.
function mxv() = is_undef($mx) ? 1 : $mx;
module mirror_x() { let($mx = mxv()) children(); mirror([1, 0, 0]) let($mx = -mxv()) children(); }
module thread_unmirror() mirror([mxv() < 0 ? 1 : 0, 0, 0]) children();

module side_plane(x0 = inner_hw, x1 = wall_out) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();

module place_plate() translate([0, 0, Zs]) rotate([-45, 0, 0]) children();
module vextrude(v0, v1) translate([0, v1, 0]) rotate([90, 0, 0]) linear_extrude(v1 - v0) children();
function yz(v, w) = [(v + w) / s2, Zs + (w - v) / s2];
module band2d(v0, v1, w0, w1) polygon([yz(v0, w0), yz(v1, w0), yz(v1, w1), yz(v0, w1)]);

module clean2d(e = 0.75) offset(delta = e) offset(delta = -2 * e) offset(delta = e) children();

// ------------------------------------------------------------ lightening ----
// Diamond lattice (45° roofs) clipped to zone [u0, u1, v0, v1]; diamonds whose
// top vertex would be clipped by the zone top are dropped (no flat roofs).
module diamond_lattice2d(zone, pitch, web, ua, va) {
    r  = (pitch - web * s2) / 2;
    h  = pitch / 2;
    i0 = floor((zone[0] - ua) / h) - 1;  i1 = ceil((zone[1] - ua) / h) + 1;
    j0 = floor((zone[2] - va) / h) - 1;  j1 = ceil((zone[3] - va) / h) + 1;
    intersection() {
        translate([zone[0], zone[2]]) square([zone[1] - zone[0], zone[3] - zone[2]]);
        union() for (i = [i0 : i1], j = [j0 : j1])
            if ((i + j + 1000) % 2 == 0 && va + j * h + r <= zone[3])
                translate([ua + i * h, va + j * h]) diamond2d(r);
    }
}
module tri_lattice2d(zone, a, web, va) {
    h  = a * sqrt(3) / 2;
    i0 = floor(zone[0] / a) - 2;  i1 = ceil(zone[1] / a) + 1;
    j0 = floor((zone[2] - va) / h) - 1;  j1 = ceil((zone[3] - va) / h) + 1;
    intersection() {
        translate([zone[0], zone[2]]) square([zone[1] - zone[0], zone[3] - zone[2]]);
        union() for (j = [j0 : j1], i = [i0 : i1]) let(x = i * a + ((j + 1000) % 2) * a / 2, y = va + j * h) {
            offset(delta = -web / 2) polygon([[x, y], [x + a, y], [x + a / 2, y + h]]);
            offset(delta = -web / 2) polygon([[x + a / 2, y + h], [x + a, y], [x + 3 * a / 2, y + h]]);
        }
    }
}

// ------------------------------------------------------- printed threads ----
// Single-start thread with 45° flanks (90° included angle: every downward face is
// 45° from vertical -> support-free when printed axis-vertical; a 60° ISO form
// would overhang 60°).  No libraries: the rod is ONE polyhedron on a helical grid
// -- fn_thr steps per turn around, 4 profile rows per pitch (crest start/end,
// root start/end) that run exactly along the helix -- so the flanks are clean
// ruled 45° surfaces (no sawtooth) and the mesh is small (~8 x fn_thr triangles
// per turn -> fast CGAL).  Rows beyond the ends are clamped onto the flat end
// faces.  clr > 0 grows it radially -> cutter for the internal thread.
//   axial profile (one pitch P): crest flat 0.1 P | 45° flank 0.4 P | root flat 0.1 P | 45° flank 0.4 P
function thr_h(P) = 0.4 * P;
function cumsum(v, i) = i <= 0 ? 0 : cumsum(v, i - 1) + v[i - 1];
function dedup_ring(f) = [for (i = [0 : len(f) - 1]) if (f[i] != f[(i + 1) % len(f)]) f[i]];
module thread_rod(d, P, L, clr = 0) {
    h = thr_h(P); a = 0.45 * P; c = a - h;
    R = d / 2 + clr; r = R - h;
    n  = fn_thr;
    zk = [-c, c, a, P - a];  rk = [R, R, r, r];
    ph = 0.37 * P / n;
    m0 = -2;  Q = 4 * (ceil(L / P) + 4);
    function zq(j, q) = zk[q % 4] + (m0 + floor(q / 4)) * P + P * j / n + ph;
    function prof(u) = let(t = abs(u - P * round(u / P))) t <= c ? R : (t >= a ? r : R - (t - c));
    lo  = [for (j = [0 : n - 1]) [for (q = [0 : Q - 1]) if (zq(j, q) > 0) q][0]];
    hi  = [for (j = [0 : n - 1]) let(l = [for (q = [0 : Q - 1]) if (zq(j, q) < L) q]) l[len(l) - 1]];
    cnt = [for (j = [0 : n - 1]) hi[j] - lo[j] + 3];
    base = [for (j = [0 : n - 1]) cumsum(cnt, j)];
    pts = [for (j = [0 : n - 1]) let(t = 360 * j / n, u0 = -P * j / n - ph) each concat(
              [[prof(u0) * cos(t), prof(u0) * sin(t), 0]],
              [for (q = [lo[j] : hi[j]]) [rk[q % 4] * cos(t), rk[q % 4] * sin(t), zq(j, q)]],
              [[prof(u0 + L) * cos(t), prof(u0 + L) * sin(t), L]])];
    function id(j, q) = let(jj = j % n, qq = q + 4 * floor(j / n))
        base[jj] + (qq < lo[jj] ? 0 : qq > hi[jj] ? cnt[jj] - 1 : qq - lo[jj] + 1);
    side = [for (j = [0 : n - 1], q = [0 : Q - 6]) let(f = dedup_ring([id(j, q), id(j, q + 1), id(j + 1, q + 1), id(j + 1, q)]))
            if (len(f) >= 3) each (len(f) == 3 ? [f] : [[f[0], f[1], f[2]], [f[0], f[2], f[3]]])];
    polyhedron(points = pts,
               faces = concat(side, [[for (j = [0 : n - 1]) base[j]]], [[for (j = [n - 1 : -1 : 0]) base[j] + cnt[j] - 1]]),
               convexity = 6);
}
module thread_hole(L, clr = ps_clear) thread_unmirror() {
    translate([0, 0, -0.5]) thread_rod(ps_d, ps_pitch, L + 1, clr);
    translate([0, 0, L - 1]) cylinder(d1 = ps_d - 2 * thr_h(ps_pitch), d2 = ps_d + 2 * clr + 2.5, h = 1.8, $fn = fn_thr);
}
module lobed2d(dia, core = 0.72) {
    circle(d = dia * core, $fn = fn_big);
    for (i = [0 : 5]) rotate(i * 60) translate([dia / 2 - dia * 0.17, 0]) circle(d = dia * 0.34, $fn = fn_small);
}

// ------------------------------------------------------- printed hardware ----
// thread_rod_g(): the same helical-grid polyhedron as thread_rod() for ANY 4-row profile zk = [crest start, crest end,
// root start, root end] within one pitch P (radius R on the crest rows, r on the root rows).  Used for the printed
// 1/4"-20 UNC female threads: the cutter flank that runs crest -> root going UP is 45° (= the nut ridges' DOWNWARD
// faces: printable without support), the flank going down is the UNC 30° (= the nut ridges' upward faces: full flank
// contact for a steel screw that pulls DOWN, e.g. a tripod screw from below).
module thread_rod_g(R, r, P, L, zk) {
    n  = fn_thr;
    rk = [R, R, r, r];
    ph = 0.37 * P / n;
    m0 = -2;  Q = 4 * (ceil(L / P) + 4);
    function zq(j, q) = zk[q % 4] + (m0 + floor(q / 4)) * P + P * j / n + ph;
    function prof(u) = let(t = u - P * floor((u - zk[0]) / P))
        t <= zk[1] ? R : t <= zk[2] ? R - (t - zk[1]) * (R - r) / (zk[2] - zk[1])
                       : t <= zk[3] ? r : r + (t - zk[3]) * (R - r) / (zk[0] + P - zk[3]);
    lo  = [for (j = [0 : n - 1]) [for (q = [0 : Q - 1]) if (zq(j, q) > 0) q][0]];
    hi  = [for (j = [0 : n - 1]) let(l = [for (q = [0 : Q - 1]) if (zq(j, q) < L) q]) l[len(l) - 1]];
    cnt = [for (j = [0 : n - 1]) hi[j] - lo[j] + 3];
    base = [for (j = [0 : n - 1]) cumsum(cnt, j)];
    pts = [for (j = [0 : n - 1]) let(t = 360 * j / n, u0 = -P * j / n - ph) each concat(
              [[prof(u0) * cos(t), prof(u0) * sin(t), 0]],
              [for (q = [lo[j] : hi[j]]) [rk[q % 4] * cos(t), rk[q % 4] * sin(t), zq(j, q)]],
              [[prof(u0 + L) * cos(t), prof(u0 + L) * sin(t), L]])];
    function id(j, q) = let(jj = j % n, qq = q + 4 * floor(j / n))
        base[jj] + (qq < lo[jj] ? 0 : qq > hi[jj] ? cnt[jj] - 1 : qq - lo[jj] + 1);
    side = [for (j = [0 : n - 1], q = [0 : Q - 6]) let(f = dedup_ring([id(j, q), id(j, q + 1), id(j + 1, q + 1), id(j + 1, q)]))
            if (len(f) >= 3) each (len(f) == 3 ? [f] : [[f[0], f[1], f[2]], [f[0], f[2], f[3]]])];
    polyhedron(points = pts,
               faces = concat(side, [[for (j = [0 : n - 1]) base[j]]], [[for (j = [n - 1 : -1 : 0]) base[j] + cnt[j] - 1]]),
               convexity = 6);
}
function unc_zk(R, r) = let(h = R - r, f = unc_P - h * (1 + tan(30))) [-f / 4, f / 4, f / 4 + h, unc_P - f / 4 - h * tan(30)];
module unc_hole(L, clr = unc_clr, td = false, bot = true, top = true) thread_unmirror() {
    R = 25.4 / 8 + clr;  r = unc_minor / 2;
    translate([0, 0, -0.5]) thread_rod_g(R, r, unc_P, L + 1, unc_zk(R, r));
    if (top) translate([0, 0, L - (R + 0.8 - r)]) cylinder(r1 = r, r2 = R + 1.3, h = R + 1.3 - r, $fn = fn_big);
    if (bot) translate([0, 0, R + 0.8 - r]) mirror([0, 0, 1]) cylinder(r1 = r, r2 = R + 1.3, h = R + 1.3 - r, $fn = fn_big);
    if (td) translate([0, 0, -1]) linear_extrude(L + 2) polygon([[0, 0], [R / s2, R / s2], [0, R * s2], [-R / s2, R / s2]]);
}
module m_hole(d, L, clr = ps_clear, bot = true, top = true) thread_unmirror() {
    translate([0, 0, -0.5]) thread_rod(d, ps_pitch, L + 1, clr);
    if (top) translate([0, 0, L - 1]) cylinder(d1 = d - 2 * thr_h(ps_pitch), d2 = d + 2 * clr + 2.5, h = 1.8, $fn = fn_thr);
    if (bot) let(rc = d / 2 + clr + 0.8, ri = d / 2 - thr_h(ps_pitch))
        translate([0, 0, -0.5]) cylinder(r1 = rc + 0.5, r2 = ri, h = rc - ri + 0.5, $fn = fn_thr);
}
// Thumbscrew / bolt, printed STANDING with the head on the bed: head (lobed [dia, h], or round with hr = true) whose top
// face is the bearing flange, thread d x ps_pitch x L above it; hk > 0: hex socket (across flats) in the head from the
// bed side (a small hexagonal bridge) for a hex key where fingers cannot reach.
// hw_fit = true (clearance checks only): threaded shanks drawn as their root cylinder (the thread flanks are checked by
// thread_test; a CGAL fit check cannot align the helix phases), hardware moved 0.01 off its bearing faces
hw_fit = false;
hw_env = false;   // (clearance checks only) threaded shanks as full-diameter cylinders, nuts solid = conservative envelope
fo = hw_fit ? 0.01 : 0;
module shank(d, L) if (hw_fit) cylinder(r = d / 2 - thr_h(ps_pitch), h = L, $fn = fn_big);
                   else if (hw_env) cylinder(d = d, h = L, $fn = fn_big); else thread_rod(d, ps_pitch, L);
module thumbscrew(d, L, head, hk = 0, hr = false) difference() {
    union() {
        if (hr) cylinder(d = head[0], h = head[1], $fn = fn_big); else linear_extrude(head[1]) lobed2d(head[0]);
        translate([0, 0, head[1] - eps]) shank(d, L + eps);
    }
    if (hk > 0) translate([0, 0, -1]) cylinder(d = hk / cos(30), h = head[1] - 1.5, $fn = 6);
}
module lid_screw()   thumbscrew(ps_d, lid_sl, lid_sh);
module clamp_screw() thumbscrew(t8_d, cs_len, cs_head, hex_key);
module wall_bolt()   thumbscrew(t8_d, wrl_bolt_len, wb_head, hex_key, true);
module slide_bolt() { translate([-sb_head[0] / 2, -sb_head[0] / 2, 0]) cube([sb_head[0], sb_head[0], sb_head[1]]);
                      translate([0, 0, sb_head[1] - eps]) shank(t8_d, sb_len + eps); }
// slide thumb-nut: lobed, printed flat, bed face = bearing face (on the slide top)
// (lobed core 0.9 -> >= 1.6 mm wall around the M8 thread)
module slide_nut() difference() { linear_extrude(sn_size[1]) lobed2d(sn_size[0], 0.9); if (!(hw_fit || hw_env)) m_hole(t8_d, sn_size[1]); }
module tnut() difference() {
    b = (tn_w - tn_top_w) / 2;
    translate([0, tn_l / 2, 0]) rotate([90, 0, 0]) linear_extrude(tn_l)
        polygon([[-tn_w / 2, 0], [tn_w / 2, 0], [tn_w / 2, tn_t - b], [tn_top_w / 2, tn_t], [-tn_top_w / 2, tn_t], [-tn_w / 2, tn_t - b]]);
    if (!(hw_fit || hw_env)) m_hole(t8_d, tn_t);
}
module pin(d, L) rotate_extrude($fn = fn_big) polygon([[0, 0], [d / 2 - 0.4, 0], [d / 2, 0.4], [d / 2, L - 0.8], [d / 2 - 0.8, L], [0, L]]);
wc_t = 3;
module wrap_clip(grip) linear_extrude(wc_t) {
    translate([-7, -2.4]) square([14, 2.4]);
    difference() {
        union() {
            translate([-1.2, -eps]) square([2.4, grip + eps]);
            translate([0, grip]) polygon([[-2.6, 0], [2.6, 0], [0.7, 4.5], [-0.7, 4.5]]);
        }
        translate([-0.6, grip - 4]) square([1.2, 10]);
    }
}
arca_len = 90;  arca_w = 38;  arca_t = 12;  arca_fl = 4;  arca_bx = 30;
arca_cb  = lid_sh[1] + 0.5;
arca_thr = lid_sl - (arca_t - arca_cb) + 1.5;
arca_boss_top = arca_thr + tri_roof;  arca_boss_d = 22;
module arca_plate_print() difference() {
    translate([arca_len / 2, 0, 0]) rotate([0, -90, 0]) linear_extrude(arca_len) polygon([[0, -arca_w / 2], [0, arca_w / 2],
        [arca_t - arca_fl, arca_w / 2], [arca_t, arca_w / 2 - arca_fl], [arca_t, -arca_w / 2 + arca_fl], [arca_t - arca_fl, -arca_w / 2]]);
    for (s = [-1, 1]) translate([s * arca_bx, 0, 0]) {
        cyl_z(ps_d + 1, 3 * arca_t);
        translate([0, 0, arca_t - arca_cb]) cylinder(d = lid_sh[0] + 1, h = arca_cb + 1, $fn = fn_big);
    }
}

// ---------------------------------------------------------------- rails -----
// 45° trapezoid (2D): base width w on y = 0, height h (+y), sides at 45°.
// Used for every guide tongue and its groove: no flat ledge in any print orientation.
module trap2d(w, h) polygon([[-w / 2, 0], [w / 2, 0], [w / 2 - h, h], [-(w / 2 - h), h]]);

// T-slot profile in (y, z); rail top at z = 0.  Guide groove (tongue) on top with
// 45° sides, neck narrower than the nut, nut chamber with a 45° roof (printable
// standing), bolt_runout below the nut so the clamp screws never bottom out.
module tslot2d() {
    zn = -key_d - neck_d;
    zc = zn - (tn_ch_w - neck_w) / 2;
    polygon([[-key_w / 2 - 1, 1], [key_w / 2 + 1, 1], [key_w / 2, 0], [key_w / 2 - key_d, -key_d], [neck_w / 2, -key_d],
             [neck_w / 2, zn], [tn_ch_w / 2, zc], [tn_ch_w / 2, -tslot_depth],
             [-tn_ch_w / 2, -tslot_depth], [-tn_ch_w / 2, zc], [-neck_w / 2, zn],
             [-neck_w / 2, -key_d], [-(key_w / 2 - key_d), -key_d], [-key_w / 2, 0]]);
}

// Everything cut into the rear (deck) rail: rail top at z = 0, T-slot centre on y = 0.
// Index holes on +off, datum pair (dsep apart) on -off (all dowel_depth deep).  No engraved scale: the carriage
// covers the whole deck width around the rail, so a scale could never be read; the vernier holes index 5 mm steps
// (for a free position: measure carriage end -> deck end).
module rail_cuts(slot_len, idx_len, off, dsep) {
    xprism(slot_len) tslot2d();
    for (x = [-idx_len / 2 : rail_pitch : idx_len / 2])
        translate([x, off, -dowel_depth]) cylinder(d = dowel_hole, h = dowel_depth + 1, $fn = fn_small);
    for (s = [-1, 1]) translate([s * dsep / 2, -off, -dowel_depth]) cylinder(d = dowel_hole, h = dowel_depth + 1, $fn = fn_small);
}

module carriage_tongue(len)
    translate([0, 0, eps]) xprism(len) mirror([0, 1]) trap2d(key_w - 2 * tongue_clear, key_d - 0.2 + eps);

// Holes: 2 clamp screws (steel: head seat at clamp_seat), vernier pins, datum round +
// slot (along X).  All outside any f38_slide -> reachable with the camera clicked off.
// td = true: teardrop profiles (point toward local +Y) for a carriage printed with these holes
// horizontal (bottom carriage, rail_test carriage).
module hole_z(d, h, td) if (td) translate([0, 0, -h / 2]) linear_extrude(h) teardrop2d(d); else cyl_z(d, h);
module carriage_holes(top, cx, dsep, vern, off, td = false) {
    for (s = [-1, 1]) translate([s * cx, 0, 0]) {
        hole_z(cl_d, 3 * top + 10, td);
        if (!hw_p) translate([0, 0, clamp_seat + 10]) hole_z(m4_head_d, 20, td);
    }
    for (x = vern) translate([x, off, 0]) hole_z(dowel_hole, 3 * top + 10, td);
    translate([-dsep / 2, -off, 0]) hole_z(dowel_hole, 3 * top + 10, td);
    translate([ dsep / 2, -off, 0]) hull() for (dx = [-1.5, 1.5]) translate([dx, 0, 0]) hole_z(dowel_hole, 3 * top + 10, td);
}

// --- Glass rib (integral in the frame; plate-local, +X side) ---
// Rib cross-section in (x, w) WITHOUT the groove (the groove is cut separately so
// the lower-rear end stays closed = end stop):
//  - lower (coated-side) flank: lip face w = -lip_proud for lip_flat, then a
//    1:bevel_k bevel away (steeper than the grazing rays), down to the side plane
//  - upper flank: from x_ul up/out on the same bevel to the back face w_back
function rib_pts(gw) = let(wh = w_hi_of(gw), wb = w_back_of(gw), xu = x_ul_of(gw), xb = xu + (wb - wh) * bevel_k)
    [[x_lip, w_fl], [x_lip + lip_flat, w_fl], [x_rw, w_front(x_rw)], [x_rw, wb], [xb, wb], [xu, wh], [x_lip, wh]];
module rib_profile2d(gw = groove_w) polygon(rib_pts(gw));
module groove2d(gw = groove_w) translate([x_lip - 1, w_lo]) square([x_gb - x_lip + 1, gw]);

// The boss's inner part hangs over the groove: its lowest edge (inner end, rear side) would print as a line in mid-air,
// so that corner rises at 45° (in the print) from 1 mm outboard of the upper-flank edge, where the rib carries it.
module preload_boss(p, gw) difference() {
    translate([boss_x0, p - boss_l / 2, w_hi_of(gw)]) cube([x_rw - boss_x0, boss_l, boss_h]);
    translate([x_ul_of(gw) + 1, p + boss_l / 2, w_hi_of(gw)]) rotate([0, 60, -atan(1 / s2)])
        translate([-500, -500, -1000]) cube([1000, 1000, 1000]);
}
module preload_cuts(p, gw) let(wh = w_hi_of(gw)) {
    if (preload_type == "printed") {
        translate([x_pl, p, wh - 0.01]) thread_hole(boss_h);
        // plain counterbore over the first 2 mm: the boss chamfer would leave thread-ridge slivers there in mid-air
        translate([x_pl, p, wh - 0.01]) cylinder(d = ps_d + 2 * ps_clear + 0.2, h = 2, $fn = fn_thr);
    }
    else {
        translate([x_pl, p, wh - 1]) cylinder(d = m4_clear, h = boss_h + 2, $fn = fn_small);
        translate([x_pl - nut_ch_w / 2, p - boss_l / 2 - 1, wh + 4.5 - (sqnut_t + 0.4) / 2])
            cube([nut_ch_w, boss_l / 2 + 1 + nut_ch_w / 2, sqnut_t + 0.4]);
    }
}
module stop_bolt_cuts() {
    translate([x_sb, v_top - 1, w_sb]) rotate([-90, 0, 0]) cylinder(d = m4_clear, h = v_sbnut - v_top + 5, $fn = fn_small);
    // square nut, dropped in from the rib's back (upper) face; slot floor at w_sb - sqnut_w / 2 so the nut resting on it
    // sits with its hole on the bolt axis and 1.0 mm of skin stays to the rib's lower bevel
    translate([x_sb - nut_ch_w / 2, v_sbnut - (sqnut_t + 0.4) / 2, w_sb - sqnut_w / 2])
        cube([nut_ch_w, sqnut_t + 0.4, 30]);
}
module rib_local(gw = groove_w, v0 = v_top, v1 = v_bot, pv = preload_v, stop_nut = true) difference() {
    union() {
        vextrude(v0, v1) rib_profile2d(gw);
        for (p = pv) preload_boss(p, gw);
    }
    if (groove_strips)
        difference() {
            translate([x_lip - 1, v0 - 1, w_seat]) cube([x_ch - x_lip + 1, v_ch_end - v0 + 1, w_hi_of(gw) - w_seat]);
            translate([key_x[0], v0 - 2, w_seat - 1]) cube([key_x[1] - key_x[0], v_ch_end - v0 + 4, key_h + 1]);
        }
    else
        vextrude(v0 - 1, v_es) groove2d(gw);
    for (p = pv) preload_cuts(p, gw);
    if (stop_nut) stop_bolt_cuts();
}

// Gusset: tapers the thick groove-zone rib into the side-plane band below its closed end, so the section does not step
// down at the rear post (the weakest point of the side truss).  It starts behind the strip channel's end wall and
// stays above the crosswall top (asserted), out of every view.
module rib_gusset() hull() {
    translate([x_gb, v_ch_end + 0.5, w_rib_lo]) cube([x_rw - x_gb, 0.01, w_back - w_rib_lo]);
    translate([x_rw - 2, v_bot + gusset_len, w_rib_lo]) cube([2, 0.01, diag_w_lo[1] - w_rib_lo]);
}

// ---- groove strip (swappable; plate-local, +X side) ----
// lower lip (felt face at w_lo = the reference), spine from the glass-edge face x_gb_s up to the roof clearance, cut
// down to strip_floor under each thumbscrew, leaf springs, a step over the seat's key ridge, end cap at the lower-rear
// end, pull hole at the top-front end.  bumps = false: spring bumps left off (insertion check).
module groove_strip_local(gw = groove_w, v0 = v_s0, v1 = v_s1, bumps = true) {
  wt = w_hi_of(gw) - strip_top_clr;
  sp = [for (c = spring_v) if (c - spring_len / 2 >= v0 + 2 && c + spring_len / 2 <= min(v1, v_es_s) - 2) c];
  difference() {
    union() {
      translate([x_lip, v0, w_seat]) cube([xo_s - x_lip, v1 - v0, w_lo - w_seat]);
      translate([x_gb_s, v0, w_lo - eps]) cube([xo_s - x_gb_s, v1 - v0, wt - w_lo + eps]);
      if (v1 > v_es_s) translate([x_lip, max(v0, v_es_s), w_lo - eps])
          cube([xo_s - x_lip, v1 - max(v0, v_es_s), wt - w_lo + eps]);
    }
    for (p = preload_v) let(a = max(v0 - 1, p - sn_half), b = min(v_es_s, p + sn_half)) if (b > a)
        translate([x_gb_s - 1, a, strip_floor]) cube([xo_s - x_gb_s + 2, b - a, 20]);
    for (c = sp) translate([x_gb_s - 1, c - spring_len / 2, wt - spring_t - spring_gap])
        cube([xo_s - x_gb_s + 2, spring_len, 20]);
    key_step(v0, v1);
    if (v0 == v_s0) translate([x_gb_s - 1, v0 + 1.5 + strip_pull_d / 2, (w_lo + wt) / 2]) rotate([0, 90, 0])
        cylinder(d = strip_pull_d, h = xo_s - x_gb_s + 2, $fn = 16);
  }
  for (c = sp) {
    translate([x_gb_s, c - spring_len / 2 - eps, wt - spring_t]) cube([xo_s - x_gb_s, spring_len + 2 * eps, spring_t]);
    if (bumps) hull() {
      translate([x_gb_s, c - 1.5 - sb_h * sb_run, wt - eps]) cube([xo_s - x_gb_s, 3 + 2 * sb_h * sb_run, eps]);
      translate([x_gb_s, c - 1.5, wt + sb_h - eps]) cube([xo_s - x_gb_s, 3, eps]);
    }
  }
}
// step in the strip underside over the seat's key ridge (open outboard, 45° inner face so it prints without a ledge):
// the ridge stops the strip moving outboard (key_clr play at the ridge's top corner)
module key_step(v0, v1) let(xs = key_x[0] - key_clr - key_h, ws = w_seat + key_h + 0.4)
    vextrude(v0 - 1, v1 + 1) polygon([[xs, w_seat - 1], [xs, w_seat], [xs + ws - w_seat, ws], [xo_s + 1, ws], [xo_s + 1, w_seat - 1]]);
module groove_strips_world() mirror_x() place_plate() groove_strip_local();
module groove_strip_print() for (s = [-1, 1]) translate([0, s * 7, 0]) mirror([0, s < 0 ? 1 : 0, 0])
    translate([-(v_s0 + v_s1) / 2, (w_seat + w_hi + spring_bump) / 2, 0])
    multmatrix([[0, 1, 0, 0], [0, 0, -1, 0], [-1, 0, 0, xo_s], [0, 0, 0, 1]]) groove_strip_local();
// strip insertion: the strip (convex hull of its section, springs pressed flat) slid 260 mm up-front along -v must not
// touch the frame
module strip_insert_check() intersection() {
    frame();
    mirror_x() place_plate() difference() {
        hull() for (dv = [0, -260]) translate([0, dv, 0]) groove_strip_local(bumps = false);
        key_step(v_s0 - 262, v_s1 + 1);
    }
}

// ---- glass_stop, steel version (bolt-on, top-front groove end; plate-local, +X side) ----
module glass_stop_local() difference() {
    intersection() {
        translate([stop_x0, v_top - stop_len, stop_w[0]]) cube([inner_hw - 0.3 - stop_x0, stop_len, stop_w[1] - stop_w[0]]);
        rotate([45, 0, 0]) translate([0, stop_clip_y, -500]) cube([500, 500, 1000]);   // world y >= stop_clip_y
    }
    translate([x_sb, v_top - stop_len - 1, w_sb]) rotate([-90, 0, 0]) cylinder(d = m4_clear, h = stop_len + 2, $fn = fn_small);
    translate([x_sb, v_top - stop_len - 1, w_sb]) rotate([-90, 0, 0]) cylinder(d = m4_head_d, h = m4_head_h + 1, $fn = fn_small);
}
// Printed version: no bolt -- the stop block carries a 4 mm EAR under the lid that lies on the (lowered) front post / pad
// top: the integral lid pin goes through it (locates it) and the front lid thumbscrew clamps it with the lid (tool-free:
// lid off -> lift the stops off the pins).  The block lowers onto the pin vertically without touching the glass (its
// felt face only approaches v_top from up-front).  Inboard part of the ear only at y <= sear_y1 (outside the lid views).
module glass_stop_block_local() intersection() {
    translate([stop_x0, v_top - stop_len, stop_w[0]]) cube([inner_hw - 0.3 - stop_x0, stop_len, stop_w[1] - stop_w[0]]);
    rotate([45, 0, 0]) translate([0, stop_clip_y, -500]) cube([500, 500, 1000]);   // world y >= stop_clip_y
}
module glass_stop_ear_world() difference() {
    union() {
        translate([stop_x0, stop_clip_y, fp_top]) cube([fp_x0 - stop_x0 + eps, sear_y1 - stop_clip_y, ear_t]);
        translate([fp_x0, y_front, fp_top]) cube([fp_x1 - fp_x0, fp_y1 - y_front, ear_t]);
    }
    translate([lid_dowels[0][0], lid_dowels[0][1], fp_top - 1]) cylinder(d = pin_hole, h = ear_t + 2, $fn = fn_small);
    translate([lid_bolts[0][0], lid_bolts[0][1], fp_top - 1]) cylinder(d = ps_d + 1, h = ear_t + 2, $fn = fn_big);
}
module glass_stop_world_p() { place_plate() glass_stop_block_local(); glass_stop_ear_world(); }
module glass_stop_print() {
    if (hw_p)
        for (s = [-1, 1]) translate([s * 22, 0, 0]) mirror([s < 0 ? 1 : 0, 0, 0])
            translate([-(stop_x0 + fp_x1) / 2, -(y_front + fp_y1) / 2, frame_top]) mirror([0, 0, 1]) glass_stop_world_p();
    else
        for (s = [-1, 1]) translate([s * 12, 0, 0]) mirror([s < 0 ? 1 : 0, 0, 0])
            translate([-(stop_x0 + inner_hw) / 2, 0, v_top]) rotate([-90, 0, 0]) glass_stop_local();
}

// ---- printable preload thumbscrew (felt disc on the flat tip) ----
module preload_screw() {
    linear_extrude(ps_head[1]) lobed2d(ps_head[0]);
    translate([0, 0, ps_head[1] - eps]) thread_rod(ps_d, ps_pitch, ps_len);
}
module preload_screw_set() for (i = [0 : 6]) translate([(i % 4) * 22, floor(i / 4) * 22, 0]) preload_screw();

// --- Part: frame (monolith, printed standing on the base) ---
zip_col_x  = x_front_in + 7;
col_z0     = acc_z[0] - ins14_d / 2 - 8;
x_sp       = inner_hw + wall_t / 2;
lcd_rx     = max(cam_a6400[0], cam_a5100[0]) / 2 + 3;
lcd_y      = [cam_a6400[3] - max(cam_a6400[1], cam_a5100[1]) - 3, cam_a6400[3] + 2];
base_zone  = [-(inner_hw - web_t), inner_hw - web_t, y_front + 5 + zip_d / 2 + web_t, y_back - 6];
clip_pos   = [[-60, 135], [60, 135]];

// Front post footprint (+X side): side-plane part full height; its inner face
// follows the target frustum (plus margin) so the open front never enters it.
module front_post2d() polygon([[inner_hw, max(y_flare, y_front)], [x_front_in, y_front], [wall_out, y_front],
                               [wall_out, y_front + col_d], [inner_hw, y_front + col_d]]);
module column_out2d() polygon([[wall_out - eps, y_front], [x_col_out, y_front], [x_col_out, y_front + col_d],
                               [wall_out - eps, y_front + col_d]]);

function zc_lo(y) = Zs - y + s2 * (w_rib_lo + diag_w_lo[1]) / 2;
module diag2d() {
    band2d(v_top, v_bot, diag_w_up[0], diag_w_up[1]);
    intersection() {
        band2d(v_bot - 6, v_bot + 250, w_rib_lo, diag_w_lo[1]);
        translate([-200, base_t / 2]) square([200 + y_back, 400]);
    }
}
module strut2d() polygon([[deck_y0, zc_lo(deck_y0)], [deck_y0 + strut_d, zc_lo(deck_y0 + strut_d)],
                          [deck_y0 + strut_d, deck_top - 1], [deck_y0, deck_top - 1]]);
// Rear-deck rib triangle (thin webs; the side planes are wall_t thick): underside ~53°, with a 3 mm FOOT on the base
// at the rear (a knife-edge corner would be thinner than a line in the first layers and start the rib in mid-air).
deck_rib_foot = 3;
module deck_rib2d() polygon([[deck_y0, deck_top - deck_t + eps], [y_back, deck_top - deck_t + eps], [y_back, base_t - eps],
                             [y_back - deck_rib_foot, base_t - eps]]);
module deck_rib() xprism(deck_rib_t) deck_rib2d();
deck_rib_xs = concat([-rib_pitch_x, 0, rib_pitch_x], [for (x = deck_rib2_x, s = [-1, 1]) s * x]);
module deck_rib_holes2d() clean2d() {
    zt = deck_top - rail_band_d - truss_web;
    zb = base_t + truss_web;
    y0 = deck_y0; y1 = y_back - 8;
    intersection() {
        diamond_lattice2d([y0, y1, zb, zt], truss_pitch, truss_web, y_back, zt - (truss_pitch - truss_web * s2) / 2);
        offset(delta = -truss_web) deck_rib2d();
    }
}
module rear_post() intersection() {
    translate([rp_x0, rp_y[0], 0]) cube([wall_out - rp_x0, rp_y[1] - rp_y[0], frame_top]);
    place_plate() translate([0, -500, w_back - 2]) cube([1000, 1000, 1000]);   // w >= w_back - 2
}

// ---- X-braces between the two side trusses (racking in the X-Z plane) ----
// A member = straight strip of width brace_w in the brace plane, ends cut square.
module strip2d(a, b, w) let(d = b - a, n = [-d[1], d[0]] / norm(d) * w / 2) polygon([a + n, b + n, b - n, a - n]);
brace_x    = inner_hw + 2;
brace_z0   = base_t;
brace_z1   = brace_z0 + brace_x;
brace_top_z = brace_z1 + brace_w / s2;
brace_y1   = y_front + col_d;
brace_y0   = brace_y1 - brace_t;
module front_brace2d() for (s = [-1, 1]) {
    strip2d([s * brace_x, brace_z0 - 3], [0, brace_z1], brace_w);
    strip2d([s * brace_x, brace_z1], [0, brace_z0 - 3], brace_w);
}
module front_brace() translate([0, brace_y1, 0]) rotate([90, 0, 0]) linear_extrude(brace_t) front_brace2d();
rb_z0 = base_t - 3;  rb_z1 = deck_top - deck_t + 3;
rb_x  = wall_out - side_rib_t;
module rear_brace2d() for (s = [-1, 1]) {
    strip2d([s * rb_x, rb_z1], [s * rib_pitch_x, rb_z0], brace_w);
    strip2d([s * rib_pitch_x, rb_z0], [0, rb_z1], brace_w);
}
module rear_brace() translate([0, y_back, 0]) rotate([90, 0, 0]) linear_extrude(brace_t) rear_brace2d();
// ---- CROSSWALL (flat mounting face for the separate wall_rail) ----
// Vertical wall between the side trusses behind the bottom camera: a web (front face wrl_relief behind the rail face
// y_wf, blind 45° pockets from the back) from the base up to the rail seat z_wseat, then a band cw_band_t thick BEHIND
// the wall_rail (flat mounting face y_cwm, up to the wall top) on a 45° knee (support-free) + two back ribs.  At the
// ends the band runs into both diagonal ribs; the wall is a shear panel between the base (bottom chord) and both
// diagonal ribs -> a third X-Z racking brace.  Printed standing with the frame: every roof inside it is 45°
// (knee, pockets, teardrop holes, nut slots open at the top).
module crosswall2d() polygon([[y_wf + wrl_relief, 0], [y_wf + wrl_relief, z_wseat], [y_cwm, z_wseat], [y_cwm, cw_top],
    [y_cwb, cw_top], [y_cwb, z_wseat], [y_wf + cw_web_t, z_wseat - (y_cwb - y_wf - cw_web_t)], [y_wf + cw_web_t, 0]]);
module crosswall() {
    xprism(2 * wall_out) crosswall2d();
    let(y1 = y_wf + cw_web_t, yr = y_wf + cw_web_t + cw_rib[1])
        for (s = [-1, 1]) translate([s * cw_rib_x, 0, 0]) xprism(cw_rib[0])
            polygon([[y1 - eps, 0], [yr, 0], [yr, z_wseat - (y_cwb - yr) + eps], [y1 - eps, z_wseat - (y_cwb - y1) + eps]]);
}
// Teardrop (2D, point up): round hole with a 45° roof -> horizontal holes print without support.
// The pin is located by the round part (steel pins: ream it to 4.0 like the vertical holes).
module teardrop2d(d) hull() { circle(d = d, $fn = fn_small); translate([0, d / 2 * s2 - 0.01]) square(0.02, center = true); }
module hole_y_td(d, dep) translate([0, dep, 0]) rotate([90, 0, 0]) linear_extrude(dep + 1) teardrop2d(d);
module crosswall_band_cuts(bolt_x, dowel_x, zt = cw_top) {
    zb = wr_z + wrl_bolt_h;
    for (x = bolt_x) {
        translate([x, y_cwm, zb]) hole_y_td(wrl_clr, cw_band_t + 1);
        translate([x - tn_ch_l / 2, y_cwm + wrl_nut_f, zb - tn_w / 2]) cube([tn_ch_l, tn_t + 0.4, zt - zb + tn_w / 2 + 1]);
    }
    for (x = dowel_x) translate([x, y_cwm, zb]) hole_y_td(hw_p ? pin_phole : dowel_hole, wrl_dowel_wall);
}
module crosswall_cuts() {
    zone = [-(inner_hw - cw_web), inner_hw - cw_web, base_t + cw_web, z_wseat - (y_cwb - y_wf - cw_web_t) - cw_web];
    translate([0, y_wf + wrl_relief + cw_skin, 0]) rotate([90, 0, 0]) mirror([0, 0, 1])
        linear_extrude(cw_web_t - wrl_relief - cw_skin + 1) difference() {
            diamond_lattice2d(zone, cw_pitch, cw_web, 0, zone[2]);
            if (tri_arca) for (s = [-1, 1]) translate([s * arca_bx - arca_boss_d / 2 - cw_web, 0]) square([arca_boss_d + 2 * cw_web, arca_boss_top + cw_web]);
            else if (pad_under(y_wf, y_wf + cw_web_t)) translate([tri_xy[0] - tri_pad_dd / 2 - cw_web, 0]) square([tri_pad_dd + 2 * cw_web, tri_pad_top + cw_web]);
            for (s = [-1, 1]) translate([s * cw_rib_x - cw_rib[0] / 2 - cw_web / 2, 0]) square([cw_rib[0] + cw_web, 500]);
        }
    crosswall_band_cuts(wrl_bolt_x, wrl_dowel_x);
}

// ---- WALL_RAIL: the bottom camera's X-rail, a separate bar bolted into the crosswall recess ----
// World: x = -len/2 .. len/2, rail face y = y_wf (the carriage rides on it) .. mounting face y_cwm, z = z0 .. z1.
// T-slot = the deck rail profile (tslot2d: 45° key groove, neck, 45° chamber roof over the nut) turned to open toward -Y,
// open at both rail ends (the nuts slide in from the ends).  Index row (+wr_off, 10 mm pitch), datum pair (-wr_off),
// engraved scale above the carriage top (read at the carriage's V notch), through-bolts with counterbored heads (row
// wrl_bolt_h, under the carriage) and two alignment-dowel holes (through; the second one slotted along X).  In the
// side planes the ends are chamfered 45° under the diagonal rib.  Printed lying FLAT on its mounting face: every hole
// is vertical (round; steel: ream the dowel holes to 4.0), the slot opens upward with a 45° chamber roof.
module wall_rail_body(len, idx_len, dsep, bolt_x, dowel_x, z0 = z_wrl0, z1 = cw_top, chamfer = true) difference() {
    translate([-len / 2, y_wf, z0]) cube([len, wrl_t, z1 - z0]);
    translate([0, y_wf, wr_z]) rotate([90, 0, 0]) xprism(len + 2) tslot2d();
    for (x = [-idx_len / 2 : rail_pitch : idx_len / 2])
        translate([x, y_wf - 1, wr_z + wr_off]) rotate([-90, 0, 0]) cylinder(d = dowel_hole, h = dowel_depth + 1, $fn = fn_small);
    for (s = [-1, 1])
        translate([s * dsep / 2, y_wf - 1, wr_z - wr_off]) rotate([-90, 0, 0]) cylinder(d = dowel_hole, h = dowel_depth + 1, $fn = fn_small);
    for (x = [-idx_len / 2 : 5 : idx_len / 2]) translate([x - 0.5, y_wf - 1, bc_z1 + 1]) cube([1.0, 1.6, x % 10 == 0 ? 5 : 3]);
    translate([1.5, y_wf + 0.6, bc_z1 + 1.5]) rotate([90, 0, 0]) linear_extrude(2) text("0", size = 3.5, halign = "left", valign = "bottom", $fn = 8);
    for (x = bolt_x) translate([x, y_wf - 1, wr_z + wrl_bolt_h]) rotate([-90, 0, 0]) {
        cylinder(d = wrl_clr, h = wrl_t + 2, $fn = fn_small);
        cylinder(d = wrl_hd, h = wrl_cb + 1, $fn = hw_p ? fn_big : fn_small);
    }
    for (i = [0 : len(dowel_x) - 1]) translate([dowel_x[i], y_wf - 1, wr_z + wrl_bolt_h]) rotate([-90, 0, 0])
        hull() for (dx = (i == 0 ? [0] : [-0.75, 0.75])) translate([dx, 0, 0]) cylinder(d = dowel_hole, h = wrl_t + 2, $fn = fn_small);
    if (chamfer) mirror_x() side_plane(inner_hw - 1, len / 2 + 1) let(c = Zs + s2 * w_rib_lo - wrl_rib_clr)
        polygon([[y_wf - 1, c - y_wf + 1], [y_cwm + 1, c - y_cwm - 1], [y_cwm + 1, 500], [y_wf - 1, 500]]);
}
module wall_rail_world() wall_rail_body(2 * wrl_half, wr_idx_len, bc_datum_sep, wrl_bolt_x, wrl_dowel_x);
wrl_print_m = [[1, 0, 0, 0], [0, 0, 1, -z_wrl0], [0, -1, 0, y_cwm], [0, 0, 0, 1]];
module wall_rail_print() multmatrix(wrl_print_m) wall_rail_world();
hood_nut_y = hw_p ? 9.5 : 12;
lid_dowels = hw_p ? [[col_x_bolt, col_yc], [-col_x_bolt, col_yc]] : [[x_sp, y_front + 4], [-x_sp, y_front + 4]];

module cable_clip() difference() {
    translate([-6, -5, 0]) cube([12, 10, 11]);
    translate([-3.5, -6, 4]) cube([7, 12, 10]);
}

function zips_diag() = [for (v = [v_top + 12 : zip_pitch : v_bot + 200])
    let(wc = v <= v_bot ? (diag_w_up[0] + diag_w_up[1]) / 2 : (w_rib_lo + diag_w_lo[1]) / 2, p = yz(v, wc))
    if (p[1] > base_t + 8 && p[0] < y_back - 12 && abs(v - v_sbnut) > 8
        && !(p[0] > deck_y0 - 4 && p[0] < deck_y0 + strut_d + 4)
        && !(p[0] > rp_y[0] - 4 && p[0] < rp_y[1] + 4)
        && !(p[0] > y_wf - 6 && p[0] < y_cwb + 6)
        && !(hw_p && p[0] < fp_y1 + 4 && p[1] > fp_z0 - 4)) p];
function zips_front() = [for (z = [20 : zip_pitch : frame_top - 20])
    if (min([for (a = concat(acc_z, hood_bolt_z)) abs(z - a)]) > 10 && z < frame_top - 25
        && abs(z - brace_z1) >= 8 && abs(z - brace_z0) >= 8) [y_front + col_d / 2, z]];
function zips_rear()  = [for (z = [frame_top - 20 : -zip_pitch : Zs - 40]) if (!hw_p || z < rpz0 - 4) [rp_yc, z]];
function zips_base()  = [for (y = [-40 : zip_pitch : 140]) y];

// Printed hardware: post-top pads carrying the VERTICAL printed M10 threads of the lid thumbscrews (printed
// standing with the frame).  Front: behind the column (x inner_hw .. x_col_out), 45° underside rising rearward from the
// column; its top (and the column top) at fp_top = frame_top - ear_t: the glass_stop ear lies there under the lid.
// Rear: the rear post top widened outboard to x_col_out and forward to rp_py0, 45° undersides.  All at |x| >= inner_hw
// - 2 and |y| >= 48: outside every camera frustum and lid view (asserted, m_pads).
module post_pads() mirror_x() {
    // (only BEHIND the post, y >= y_front + col_d: along the post the pad would stand 2 mm into the stereo aperture)
    side_plane(fp_x0, fp_x1) polygon([[y_front + col_d - 1, fp_z0 - 1], [fp_y1, fp_z0 + (fp_y1 - y_front - col_d)],
                                      [fp_y1, fp_top], [y_front + col_d - 1, fp_top]]);
    translate([0, y_front + col_d / 2, 0]) yprism(col_d)
        polygon([[x_col_out - 1, fp_top - (fp_x1 - x_col_out) - 2], [fp_x1, fp_top - 1], [fp_x1, fp_top], [x_col_out - 1, fp_top]]);
    intersection() {
        union() {   // (the forward lip in front of the rear post only at x >= inner_hw: outside the lid views)
            side_plane(rp_x0, x_col_out) polygon([[rp_y[0], rpz0], [y_zone_end, rpz0], [y_zone_end, frame_top], [rp_y[0], frame_top]]);
            side_plane(inner_hw, x_col_out) polygon([[rp_py0, rpz0 + (rp_y[0] - rp_py0)], [rp_y[0] + 1, rpz0 - 1], [rp_y[0] + 1, frame_top],
                                                     [rp_py0, frame_top]]);
        }
        translate([0, (rp_py0 + y_zone_end) / 2, 0]) yprism(y_zone_end - rp_py0 + 2)
            polygon([[rp_x0 - 1, rpz0], [wall_out, rpz0], [x_col_out, rpz0 + x_col_out - wall_out], [x_col_out, frame_top + 1], [rp_x0 - 1, frame_top + 1]]);
    }
}
module lid_pins() for (d = lid_dowels) translate([d[0], d[1], fp_top - 1]) pin(pin_d, frame_top + lid_pin_up - fp_top + 1);
module arca_bosses() for (s = [-1, 1]) translate([s * arca_bx, tri_xy[1], 0]) cylinder(d = arca_boss_d, h = arca_boss_top, $fn = fn_big);

module frame_solid() {
    translate([-wall_out, y_front, 0]) cube([2 * wall_out, y_back - y_front, base_t]);
    mirror_x() {
        linear_extrude(frame_top) front_post2d();
        intersection() {
            linear_extrude(frame_top) column_out2d();
            yprism(1000) polygon([[wall_out - 1, col_z0 - 1], [x_col_out + 1, col_z0 + (x_col_out + 1 - wall_out)],
                                  [x_col_out + 1, frame_top + 1], [wall_out - 1, frame_top + 1]]);
        }
        place_plate() { rib_local(); rib_gusset(); }
        side_plane() { diag2d(); strut2d(); }
        difference() {
            side_plane(wall_out - side_rib_t) deck_rib2d();
            translate([x_sp, 0, 0]) xprism(wall_t + 2) deck_rib_holes2d();
        }
        rear_post();
    }
    translate([-wall_out, deck_y0, deck_top - deck_t]) cube([2 * wall_out, y_back - deck_y0, deck_t]);
    translate([-wall_out, y_rrail - rail_w / 2, deck_top - rail_band_d]) cube([2 * wall_out, rail_w, rail_band_d]);
    for (x = deck_rib_xs) translate([x, 0, 0]) deck_rib();
    crosswall();
    front_brace();
    rear_brace();
    // tripod socket pad in the crosswall foot: round boss, insert / printed thread inside, roof >= tri_roof;
    // tripod_mount = "arca": two M10 bosses for the printed Arca plate instead
    if (tri_arca) arca_bosses();
    else translate([tri_xy[0], tri_xy[1], 0]) cylinder(d = tri_pad_dd, h = tri_pad_top, $fn = fn_big);
    if (hw_p) post_pads();
    for (p = clip_pos) translate([p[0], p[1], base_t - eps]) cable_clip();
}

module base_pockets2d() clean2d() difference() {
    tri_lattice2d(base_zone, base_tri, web_t, y_front + 12);
    translate([-200, y_wf - web_t]) square([400, cw_foot_t + 2 * web_t]);
    for (x = [-brace_x, 0, brace_x]) translate([x - 14, brace_y0 - web_t]) square([28, brace_t + 2 * web_t]);
    for (x = [-rib_pitch_x, rib_pitch_x]) translate([x - 14, y_back - brace_t - web_t]) square([28, brace_t + web_t + 1]);
    if (tri_arca) translate([-arca_len / 2 - web_t, tri_xy[1] - arca_w / 2 - web_t]) square([arca_len + 2 * web_t, arca_w + 2 * web_t]);
    else translate(tri_xy) circle(d = tri_solid_d, $fn = fn_big);
    if (tri_xy[1] + tri_pad_dd / 2 < y_wf - web_t)
        translate([tri_xy[0] - tri_pad_dd / 2 - web_t, tri_xy[1]]) square([tri_pad_dd + 2 * web_t, y_wf - tri_xy[1]]);
    for (s = [-1, 1]) translate([s * cw_rib_x - cw_rib[0] / 2 - web_t, y_wf]) square([cw_rib[0] + 2 * web_t, cw_web_t + cw_rib[1] + web_t]);
    for (p = clip_pos) translate([p[0] - 6 - web_t, p[1] - 5 - web_t]) square([12 + 2 * web_t, 10 + 2 * web_t]);
    if (lcd_recess) let(rim = lcd_window ? 6 : web_t)
        translate([-lcd_rx - rim, lcd_y[0] - rim]) square([2 * (lcd_rx + rim), lcd_y[1] - lcd_y[0] + 2 * rim]);
    for (s = [-1, 1], y = zips_base()) translate([s * x_sp, y]) circle(d = zip_d + 2 * web_t, $fn = fn_small);
}

module frame_cuts() {
    // ---- lightening ----
    // base: triangulated pockets open upward, blind (floor skin_t), support-free
    translate([0, 0, skin_t]) linear_extrude(base_t) base_pockets2d();
    if (lcd_recess) translate([0, 0, lcd_window ? -1 : lcd_floor_t]) linear_extrude(base_t + 1 + (lcd_window ? 1 : 0))
        offset(r = lcd_window ? lcd_window_r : 0) offset(delta = lcd_window ? -lcd_window_r : 0)
        translate([-lcd_rx, lcd_y[0]]) square([2 * lcd_rx, lcd_y[1] - lcd_y[0]]);
    crosswall_cuts();
    for (x = deck_rib_xs) translate([x, 0, 0]) xprism(deck_rib_t + 2) deck_rib_holes2d();

    translate([0, y_rrail, deck_top]) rail_cuts(2 * wall_out + 2, rc_idx_len, rc_idx_off, rc_datum_sep);
    if (hw_p) {
        mirror_x() translate([fp_x0 - 1, y_front - 1, fp_top]) cube([fp_x1 - fp_x0 + 2, fp_y1 - y_front + 2, 20]);
        mirror_x() {
            translate([lid_bolts[0][0], lid_bolts[0][1], fp_top - lid_thr[0]]) thread_hole(lid_thr[0]);
            translate([lid_bolts[1][0], lid_bolts[1][1], frame_top - lid_thr[1]]) thread_hole(lid_thr[1]);
        }
    } else {
        mirror_x() for (i = [0 : len(lid_bolts) - 1]) let(b = lid_bolts[i], xo = (i == 0 ? x_col_out : wall_out)) {
            translate([b[0], b[1], frame_top - 11]) cyl_z(m4_clear, 24);
            translate([b[0], b[1], frame_top - 12]) sqnut_pocket_z(xo - b[0] + 1);
        }
        for (d = lid_dowels) translate([d[0], d[1], frame_top - lid_dowel_depth]) cylinder(d = lid_dowel_hole, h = lid_dowel_depth + 1, $fn = fn_small);
    }
    mirror_x() {
        for (z = acc_z) translate([x_col_out + eps, col_yc, z]) rotate([0, -90, 0])
            if (hw_p) rotate([0, 0, -90]) unc_hole(ins14_depth, td = true, top = false);
            else cylinder(d = ins14_d, h = ins14_depth + eps, $fn = fn_small);
        for (z = hood_bolt_z) {
            if (hw_p) translate([col_x_bolt, y_front - 1, z]) hole_y_td(t8_clear, col_d + 1);
            else translate([col_x_bolt, y_front + 9, z]) cyl_y(m4_clear, 20);
            translate([col_x_bolt, y_front + hood_nut_y, z]) rotate([90, 0, 0])
                translate([-tn_ch_l / 2, -(tn_w + 2 * nut_clear) / 2, -(tn_t + 0.4) / 2])
                    cube([x_col_out - col_x_bolt + tn_ch_l / 2 + 1, tn_w + 2 * nut_clear, tn_t + 0.4]);
        }
        for (z = [col_z0 + 10 : zip_pitch / 2 : frame_top - 30]) if (min([for (c = concat(acc_z, hood_bolt_z)) abs(z - c)]) > 9
                                                                     && (!hw_p || z < fp_z0 - 4))
            translate([zip_col_x, y_front + col_d / 2, z]) cyl_y(zip_d, col_d + 2);
        for (p = concat(zips_diag(), zips_front())) translate([x_sp, p[0], p[1]]) cyl_x(zip_d, wall_t + 2);
        for (p = zips_rear()) translate([(rp_x0 + wall_out) / 2, p[0], p[1]]) cyl_x(zip_d, wall_out - rp_x0 + 2);
        for (y = zips_base()) translate([x_sp, y, base_t / 2]) cyl_z(zip_d, base_t + 2);
        for (z = [20, 45, 70]) translate([x_sp, y_back - 4, z]) cyl_x(zip_d, wall_t + 2);
        translate([x_sp, deck_y0 + strut_d / 2, deck_top - deck_t - 8]) cyl_x(zip_d, wall_t + 2);
    }
    for (z = [20, 45, 70], x = [-rib_pitch_x, 0, rib_pitch_x]) translate([x, y_back - 4, z]) cyl_x(zip_d, deck_rib_t + 2);
    for (x = [-75 : zip_pitch : 75]) translate([x, y_front + 5, base_t / 2]) cyl_z(zip_d, base_t + 2);
    if (tri_arca) for (s = [-1, 1]) translate([s * arca_bx, tri_xy[1], 0]) m_hole(ps_d, arca_thr, top = false);
    else if (tri_pr) translate([tri_xy[0], tri_xy[1], 0]) unc_hole(tri_ins_dep, top = false);
    else translate([tri_xy[0], tri_xy[1], -eps]) cylinder(d = tri_ins_d, h = tri_ins_dep + eps, $fn = fn_small);
}

module frame_full() { difference() { frame_solid(); frame_cuts(); } if (hw_p) lid_pins(); }

split_bolt_len = 20;
split_bolt_y   = deck_y0 + strut_d / 2;
split_lap_z    = deck_top - 14.4;
split_nut_z    = split_lap_z - 8;
module split_front_region() union() {
    translate([-500, -500, -1]) cube([1000, 500 + split_y, 500]);
    mirror_x() translate([inner_hw - 1, -500, -1]) cube([500, 500 + split_y + 20, split_lap_z + 1]);
    translate([-500, -500, -1]) cube([1000, 500 + split_y + 20, base_t + 1]);
}
module split_lap_holes() mirror_x() {
    seat = split_nut_z - 1.5 - 1 + split_bolt_len - (sqnut_t + 0.4) / 2 - 1;
    translate([x_sp, split_bolt_y, split_nut_z - 6]) cylinder(d = m4_clear, h = deck_top - split_nut_z + 7, $fn = fn_small);
    translate([x_sp, split_bolt_y, seat]) cylinder(d = m4_head_d, h = 40, $fn = fn_small);
    translate([x_sp, split_bolt_y, split_nut_z]) sqnut_pocket_z(wall_out - x_sp + 1);
}
module frame_piece(which) difference() {
    if (which == "front") intersection() { frame_full(); split_front_region(); }
    else difference() { frame_full(); split_front_region(); }
    split_lap_holes();
}
module frame() {
    if (!frame_split) frame_full();
    else {
        if (split_piece != "rear") frame_piece("front");
        if (split_piece != "front")
            translate([split_piece == "both" ? 2 * x_col_out + 10 : 0, split_piece == "both" ? -split_y : 0, 0])
                frame_piece("rear");
    }
}

// --- Groove test coupons + thread test ---
// groove_test: 4 short (~45 mm) sections of the REAL rib (lower lip, groove,
// upper flank, one preload boss with its thread / nut trap, closed end stop),
// printed at the frame's 45°, each on a side-band stub + flat foot.  The rear fin of
// each coupon is vertical (normal +Y): zero a digital angle gauge on it (or on
// the bed), then read the lower flank / a glass strip in the groove: 45.0°.
groove_ws = [3.4, 3.6, 4.0, 4.4];
gt_v0 = v_es - 36;
gt_pv = v_es - 18;
gt_band = 4;
module groove_coupon(gw) {
    zb   = Zs + pz(v_bot, diag_w_up[0]);
    zcut = zb + 4;
    pr   = yz(v_bot, w_back_of(gw));
    y0   = yz(v_bot, diag_w_up[0])[0] - 8;
    translate([0, 0, 2.5 - zcut]) difference() {
        union() {
            intersection() {
                union() {
                    place_plate() rib_local(gw, gt_v0, v_bot, [gt_pv], false);
                    side_plane(x_rw - 1, x_rw - 1 + gt_band) band2d(gt_v0, v_bot, diag_w_up[0], w_back_of(gw));
                }
                translate([-500, -500, zcut]) cube(1000);
            }
            translate([boss_x0 - 1, y0, zcut - 2.5]) cube([x_rw + gt_band - boss_x0, pr[0] - y0, 2.5]);
            translate([boss_x0 - 1, pr[0] - 3, zcut - 2.5]) cube([x_rw + gt_band - boss_x0, 3, pr[1] - zcut + 2.5]);
        }
        translate([(boss_x0 + x_rw + gt_band) / 2 - 0.5, pr[0] - 0.6, zcut + 4]) rotate([90, 0, 180]) linear_extrude(2)
            text(str(floor(gw), ".", round(10 * (gw - floor(gw)))), size = 4.5, halign = "center", valign = "bottom", $fn = 8);
    }
}
module groove_test() {
    for (i = [0 : len(groove_ws) - 1]) translate([(i - 1.5) * 30 - (x_rw + boss_x0) / 2, -35, 0]) groove_coupon(groove_ws[i]);
    if (groove_strips) for (i = [0 : len(groove_ws) - 1]) translate([(i - 1.5) * 30, -80, 0])
        translate([-(x_lip + x_ch) / 2, -(gt_v0 + 2 + v_s1) / 2, -w_seat]) groove_strip_local(groove_ws[i], gt_v0 + 2, v_s1);
    if (preload_type == "printed") translate([0, 50, 0]) preload_screw();
}
thr_test_clr = [0.2, 0.3, 0.4];
module thread_test() {
    difference() {
        translate([-33, -10, 0]) cube([66, 20, 8]);
        for (i = [0 : 2]) {
            translate([(i - 1) * 21, 0, 0]) thread_hole(8, thr_test_clr[i]);
            translate([(i - 1) * 21, -8.5, 8 - 0.6]) linear_extrude(1)
                text(str(thr_test_clr[i]), size = 3, halign = "center", valign = "bottom", $fn = 8);
        }
    }
    for (i = [0 : 2]) translate([(i - 1) * 22, 30, 0]) {
        linear_extrude(ps_head[1]) lobed2d(ps_head[0]);
        translate([0, 0, ps_head[1] - eps]) thread_rod(ps_d, ps_pitch, 10);
    }
    if (hw_p) {
        translate([0, 57, 0]) difference() {
            translate([-30, -9, 0]) cube([60, 18, 8]);
            for (i = [0 : 2]) {
                translate([(i - 1) * 20, 0, 0]) m_hole(t8_d, 8, thr_test_clr[i]);
                translate([(i - 1) * 20, -8, 8 - 0.6]) linear_extrude(1)
                    text(str(thr_test_clr[i]), size = 2.6, halign = "center", valign = "bottom", $fn = 8);
            }
        }
        for (i = [0 : 2]) translate([(i - 1) * 20, 80, 0]) thumbscrew(t8_d, 10, cs_head, hex_key);
        translate([0, 102, 0]) difference() {
            translate([-30, -8, 0]) cube([60, 16, 10]);
            for (i = [0 : 2]) {
                translate([(i - 1) * 18, 0, 0]) unc_hole(10, unc_test_clr[i]);
                translate([(i - 1) * 18, -7.5, 10 - 0.6]) linear_extrude(1)
                    text(str(unc_test_clr[i]), size = 2.6, halign = "center", valign = "bottom", $fn = 8);
            }
        }
        translate([0, 124, 0]) difference() {
            translate([-12, -6, 0]) cube([24, 12, 16]);
            translate([0, 6 + 0.01, 8]) rotate([90, 0, 0]) unc_hole(12.02, td = true);
            translate([-7, 0, 16 - 0.6]) linear_extrude(1) text("H", size = 3, halign = "center", valign = "center", $fn = 8);
        }
    }
}
unc_test_clr = [0.1, 0.2, 0.3];

pin_test_clr = [0.1, 0.2, 0.3];
module pin_test() {
    difference() {
        translate([-34, -8, 0]) cube([68, 16, 10]);
        for (i = [0 : 2]) {
            translate([(i - 1) * 16 - 6, 0, -1]) cylinder(d = pin_d + pin_test_clr[i], h = 12, $fn = fn_small);
            translate([(i - 1) * 16 - 6, -7.6, 10 - 0.6]) linear_extrude(1)
                text(str(pin_test_clr[i]), size = 2.6, halign = "center", valign = "bottom", $fn = 8);
        }
        translate([24, 0, 10 - f38_pin_depth]) cylinder(d = f38_pin_hole, h = f38_pin_depth + 1, $fn = fn_small);
        translate([24, -7.6, 10 - 0.6]) linear_extrude(1) text("F38", size = 2.6, halign = "center", valign = "bottom", $fn = 8);
    }
    translate([0, 24, 0]) difference() {
        translate([-34, -5, 0]) cube([68, 10, 16]);
        for (i = [0 : 3]) translate([(i - 1) * 16 - 6, -5.5, 8]) hole_y_td(i < 3 ? pin_d + pin_test_clr[i] : pin_phole, 11);
        for (i = [0 : 3]) translate([(i - 1) * 16 - 6, 0, 16 - 0.6]) linear_extrude(1)
            text(i < 3 ? str(pin_test_clr[i]) : "P", size = 2.4, halign = "center", valign = "center", $fn = 8);
    }
    for (i = [0 : 2]) translate([(i - 1) * 12, 44, 0]) pin(pin_d, 20);
    translate([24, 44, 0]) pin(f38_pin_d, f38_pin_depth + 3);
}

// --- Parts: F38 slides, carriages, rail test ---
// ---- f38_slide (local): underside z = 0 on the carriage, travel along local Y.
// 6 mm thin.  The anti-yaw guide is a 45° trapezoid TONGUE under the slide (guide_w root)
// running in a groove in the carriage; the 1/4"-20 screw that holds the F38 base (permanently,
// from below) sits in a counterbore inside that tongue, so its head is below the slide and the
// slide can still be thin.  Optional F38 locating pins; 2 clamp bolts through slots (printed: M8 T-bolts
// from below + thumb-nuts on top; steel: M4 from the top), clamp heads outside the base footprint.
// serr = true (bottom slide): 45° serrations across the outer contact bands of the
// underside mesh with the carriage plate -> the Z position indexes in serr_pitch
// steps and is held by the teeth, not by clamp friction alone.
module f38_slide_local(travel, serr = false, soff = 0) {
    L = slide_len(travel); W = 2 * slide_hw;
    difference() {
        union() {
            translate([-W / 2, -L / 2, 0]) cube([W, L, t_slide]);
            translate([0, 0, eps]) yprism(L) mirror([0, 1]) trap2d(guide_w - 2 * tongue_clear, tongue_h + eps);
        }
        if (serr) mirror_x() translate([slide_bolt_x - 5, 0, 0]) serr_band(serr_wx, -L / 2 - 1, L / 2 + 1);
        cyl_z(qtr_clear, 3 * t_slide);
        translate([0, 0, -tongue_h - eps]) cylinder(d = qtr_head_d + 1, h = qtr_cb_top + tongue_h + eps, $fn = fn_big);
        for (s = [-1, 1]) translate([s * slide_bolt_x, soff, t_slide / 2]) slot_y(travel, sl_slot_w, t_slide + 2);
        if (f38_pins) for (s = [-1, 1]) translate([s * f38_pin_sp / 2, 0, t_slide - f38_pin_depth])
            cylinder(d = f38_pin_hole, h = f38_pin_depth + 1, $fn = fn_small);
    }
}
module f38_slide_print() {
    translate([-(slide_hw + 4), 0, t_slide]) mirror([0, 0, 1]) f38_slide_local(rear_travel);
    translate([ (slide_hw + 4), 0, t_slide]) mirror([0, 0, 1]) f38_slide_local(bot_slot_trav, bot_serr, bot_slot_shift);
}
// Serration teeth (slide-local frame, contact face z = 0, slide body on z >= 0):
// the solid between z = -1 and a zigzag z = 0 .. serr_depth along y (phase: a
// valley bottom z = 0 at y = 0), for x = 0 .. wx, y = y0 .. y1.  Subtracted from
// the slide it cuts the valleys; added to the carriage plate (same frame) it forms
// the matching teeth -> the mean contact plane stays at z = 0.  45° flanks for
// serr_depth = serr_pitch / 2.
module serr_band(wx, y0, y1) {
    n0 = floor(y0 / serr_pitch) - 1;  n1 = ceil(y1 / serr_pitch) + 1;
    intersection() {
        rotate([90, 0, 90]) linear_extrude(wx)
            polygon(concat([[n0 * serr_pitch, -1]],
                           [for (i = [n0 : n1], k = [0, 1]) [i * serr_pitch + k * serr_pitch / 2, k * serr_depth]],
                           [[n1 * serr_pitch + serr_pitch / 2, -1]]));
        translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0)
            polygon([[-2, -2], [wx / 2, wx / 2], [wx + 2, -2]]);
    }
}
// Carriage side of the slide interface (carriage-local: slide face at z = t, slide travel along
// local Y over len): 45° guide groove + 2 clamp-bolt holes; steel: square-nut pockets (nut roof
// slide_nut_roof, pocket runs out along +Y to the carriage edge `run` away; nuts slide in there).
// Printed hardware: no nut in the 6 mm carriage -- a printed M8 T-bolt stands in a DIAMOND pocket open to the carriage's
// rail face (the rail face under it keeps it captive; diamond = 45° roof when the bottom carriage prints standing), its
// shank goes up through the carriage and the slide slot, a printed thumb-nut on the slide top clamps.
module sb_pocket() translate([0, 0, -guide_d - 1]) rotate([0, 0, 45])
    linear_extrude(sb_pd + guide_d + 1) square(sb_head[0] + 0.4, center = true);
module slide_iface_cuts(t, len, yc, run, td = false) {
    translate([0, 0, t + eps]) yprism(len + 2) mirror([0, 1]) trap2d(guide_w + 2 * eps, guide_d + 2 * eps);
    for (s = [-1, 1]) translate([s * slide_bolt_x, yc, 0]) {
        if (hw_p) {
            translate([0, 0, t / 2]) hole_z(t8_clear, t + 2, td);
            sb_pocket();
        } else {
            translate([0, 0, t - slide_tip_d - 0.4 + (slide_tip_d + 1) / 2]) hole_z(m4_clear, slide_tip_d + 1, td);
            translate([-nut_ch_w / 2, -nut_ch_w / 2, t - slide_nut_d - (sqnut_t + 0.4) / 2])
                cube([nut_ch_w, run + nut_ch_w / 2, sqnut_t + 0.4]);
        }
    }
}

// ---- rear carriage: local frame, bottom (deck top) at z = 0, rail centre y = 0.  6 mm plate:
// rail tongue under it (X), slide groove on top (Y), clamp bolts + dowels outside the slide.
module rear_carriage_local() {
    t = t_rear_carriage; L = rc_len; Wy = rc_width;
    difference() {
        union() {
            translate([-L / 2, -Wy / 2, 0]) cube([L, Wy, t]);
            carriage_tongue(L);
        }
        carriage_holes(t, rc_clamp_x, rc_datum_sep, rc_vern, rc_idx_off);
        slide_iface_cuts(t, Wy, 0, Wy / 2 + 1);
    }
}
module rear_carriage_print() translate([0, 0, t_rear_carriage]) mirror([0, 0, 1]) rear_carriage_local();

// ---- bottom carriage: flat 6 mm plate riding on the WALL_RAIL face.
// Local frame (same as rail_cuts / carriage_holes): z = 0 on the wall_rail face, +z toward the camera
// (world -Y), local y = world z - wr_z (up).  Rail tongue in the rail's key groove, clamp bolts +
// dowels (teardrop: they are horizontal in the world and in the print) outside the slide, slide
// groove along world Z, serrations meshing with the bottom f38_slide (steel: slide nuts dropped in
// from the top edge, gravity keeps them on the bolt).
module bottom_carriage_local() {
    L = bc_len; y0 = bc_z0 - wr_z; y1 = bc_z1 - wr_z;
    difference() {
        union() {
            translate([-L / 2, y0, 0]) cube([L, y1 - y0, bc_t]);
            carriage_tongue(L);
            if (bot_serr) translate([0, z_bot_sock - wr_z, bc_t]) mirror_x() translate([slide_bolt_x - 5, 0, 0])
                serr_band(serr_wx, y0 - (z_bot_sock - wr_z), y1 - (z_bot_sock - wr_z));
        }
        carriage_holes(bc_t, bc_clamp_x, bc_datum_sep, bc_vern, wr_off, td = true);
        translate([0, (y0 + y1) / 2, 0]) slide_iface_cuts(bc_t, y1 - y0, bc_bolt_z - wr_z - (y0 + y1) / 2, y1 - (bc_bolt_z - wr_z) + 1, td = true);
        translate([0, y1, -1]) linear_extrude(bc_t + 2) polygon([[-1.5, 0.01], [1.5, 0.01], [0, -1.5]]);
    }
}
module bottom_carriage_world() translate([0, y_wf, wr_z]) rotate([90, 0, 0]) bottom_carriage_local();
module bottom_carriage_print() translate([0, -y_wf, -bc_z0]) bottom_carriage_world();

// ---- rail test: (1) an 80 mm slice of the wall_rail, printed lying flat like the rail
// (T-slot, index / datum holes, scale, one through-bolt counterbore at x 0, both alignment-dowel holes: round -15, slot +15);
// (2) a 70 mm test carriage (6 mm, printed standing like the bottom carriage: tongue, clamp holes at +-25, teardrop
// pin holes); (3) a 60 mm block of the crosswall mounting band (printed standing like the frame: teardrop bolt + pin
// holes, nut slot from the top) to bolt the rail slice onto.  Uses the real hardware.
rt_dsep = 60;
rt_bolt_x = [0];  rt_dowel_x = [-15, 15];
rt_blk_top = wr_z + wrl_bolt_h + 14;
module rail_test() {
    rt_z = 18;
    multmatrix(wrl_print_m) wall_rail_body(80, 60, rt_dsep, rt_bolt_x, rt_dowel_x, chamfer = false);
    translate([0, -12, rt_z]) rotate([90, 0, 0]) difference() {
        union() {
            translate([-35, -rt_z, 0]) cube([70, 2 * rt_z, bc_t]);
            carriage_tongue(70);
        }
        carriage_holes(bc_t, 25, rt_dsep, [-20, 15], wr_off, td = true);
    }
    translate([0, -30 - y_cwb, -z_wseat]) difference() {
        translate([-30, y_cwm, z_wseat]) cube([60, cw_band_t, rt_blk_top - z_wseat]);
        crosswall_band_cuts(rt_bolt_x, rt_dowel_x, rt_blk_top);
    }
    if (hw_p) translate([58, 0, 0]) {
        for (i = [0 : 1]) translate([0, i * 18 - 20, 0]) clamp_screw();
        translate([0, 18, 0]) wall_bolt();
        for (i = [0 : 2]) translate([19, i * 18 - 20, 0]) tnut();
        for (i = [0 : 3]) translate([34, i * 11 - 20, 0]) pin(pin_d, i < 2 ? wrl_dowel_len : 20);
    }
}

// --- Parts: top lid, hood, shims ---
// ---- ISO 518 female cold shoe: slot floor at z = 0 (1 mm own floor below),
// closed at y = 0, open at +Y.  Lips shoe_lip thick, walls shoe_wall.
module cold_shoe() difference() {
    translate([-shoe_w / 2 - shoe_wall, 0, -1]) cube([shoe_w + 2 * shoe_wall, shoe_len, 1 + shoe_h + shoe_lip]);
    translate([-shoe_w / 2, 3, -eps]) cube([shoe_w, shoe_len, shoe_h + eps]);
    translate([-shoe_throat / 2, 3, 0]) cube([shoe_throat, shoe_len, 10]);
}

// ---- top lid (world position): structural top chord + light trap.
// Flat underside (flocking field), ribs outside with pockets between them
// (lid_skin left), 4 lid screws (front + rear posts), cold shoe + 1/4"-20 socket.
lid_rib_y = [lid_y0 + 2, -40, 20, lid_y1 - 2];
lid_rib_x = [-(lid_hw - 2), -60, 60, lid_hw - 2];
shoe_pos  = [0, -22];
ins_pos   = [35, -10];
function lid_zips() = [for (p = concat([for (x = [-75 : zip_pitch : 75]) each [[x, lid_y0 + 7], [x, lid_y1 - 7]]],
                             [for (s = [-1, 1], y = [lid_y0 + 30 : zip_pitch : lid_y1 - 20]) [s * (lid_hw - 7), y]]))
                      if (!hw_p || min([for (b = lid_bolts, s = [-1, 1]) norm(p - [s * b[0], b[1]])]) > lid_sh[0] / 2 + 3) p];
module lid_pockets2d() clean2d() difference() {
    for (i = [0 : len(lid_rib_y) - 2], j = [0 : len(lid_rib_x) - 2])
        translate([lid_rib_x[j] + rib_t / 2 + 2, lid_rib_y[i] + rib_t / 2 + 2])
            square([lid_rib_x[j + 1] - lid_rib_x[j] - rib_t - 4, lid_rib_y[i + 1] - lid_rib_y[i] - rib_t - 4]);
    for (b = lid_bolts, s = [-1, 1]) translate([s * b[0], b[1]]) circle(d = hw_p ? lid_sh[0] + 4 : 18, $fn = fn_small);
    for (d = lid_dowels) translate(d) circle(d = 11, $fn = fn_small);
    translate([shoe_pos[0] - 16 - 3, shoe_pos[1] - 3]) square([32 + 6, shoe_len + 4 + 6]);
    translate(ins_pos) circle(d = 22, $fn = fn_small);
    for (p = lid_zips()) translate(p) circle(d = zip_d + 4, $fn = fn_small);
}
module top_lid_world() {
    zt = frame_top + lid_t;
    difference() {
        union() {
            translate([-lid_hw, lid_y0, frame_top]) cube([2 * lid_hw, lid_y1 - lid_y0, lid_t]);
            for (y = lid_rib_y) translate([-lid_hw, y - rib_t / 2, zt - eps]) cube([2 * lid_hw, rib_t, lid_rib_h]);
            for (x = lid_rib_x) translate([x - rib_t / 2, lid_y0, zt - eps]) cube([rib_t, lid_y1 - lid_y0, lid_rib_h]);
            translate([shoe_pos[0] - 16, shoe_pos[1], zt - eps]) cube([32, shoe_len + 4, lid_rib_h]);
            translate([shoe_pos[0], shoe_pos[1] + 2, zt + lid_rib_h - eps]) cold_shoe();
            translate([ins_pos[0], ins_pos[1], zt - eps]) cylinder(d = 16, h = lid_rib_h, $fn = fn_big);
        }
        translate([0, 0, frame_top + lid_skin]) linear_extrude(lid_t) lid_pockets2d();
        for (b = lid_bolts, s = [-1, 1]) translate([s * b[0], b[1], frame_top]) {
            cyl_z(hw_p ? ps_d + 1 : m4_clear, 40);
            translate([0, 0, lid_t]) cylinder(d = hw_p ? lid_sh[0] + 1 : 10.5, h = lid_rib_h + 1, $fn = hw_p ? fn_big : fn_small);
        }
        translate([ins_pos[0], ins_pos[1], zt + lid_rib_h - lid_ins_depth])
            if (hw_p) unc_hole(lid_ins_depth, bot = false); else cylinder(d = ins14_d, h = lid_ins_depth + 1, $fn = fn_small);
        for (p = lid_zips()) translate([p[0], p[1], zt]) cyl_z(zip_d, 30);
        for (d = lid_dowels) translate([d[0], d[1], frame_top - 1])
            if (d[0] > 0) cylinder(d = dowel_hole, h = lid_dowel_lid + 1, $fn = fn_small);
            else hull() for (dx = [-0.75, 0.75]) translate([dx, 0, 0]) cylinder(d = dowel_hole, h = lid_dowel_lid + 1, $fn = fn_small);
    }
}
module top_lid_print() translate([0, 0, -frame_top]) top_lid_world();

// ---- hood (world): flared shell that follows the target frustum + margin.
function hood_hx(y) = (D - y) * th_t + aperture_margin;
function hood_hz(y) = (D - y) * tv_t + aperture_margin;
module hood_rect(y, grow) translate([0, y, Zs])
    cube([2 * (hood_hx(y) + grow), eps, 2 * (hood_hz(y) + grow)], center = true);
module hood_world() {
    y1 = y_front - hood_len;
    difference() {
        union() {
            hull() { hood_rect(y_front, hood_wall); hood_rect(y1, hood_wall); }
            // bolt ears: start at the aperture edge x_front_in (never inside the 3 mm margin)
            mirror_x() translate([x_front_in, y_front - 4, Zs - 5]) cube([x_col_out - x_front_in, 4, 60]);
        }
        hull() { hood_rect(y_front + 1, 0); hood_rect(y1 - 1, 0); }
        mirror_x() for (z = hood_bolt_z) translate([col_x_bolt, y_front, z]) cyl_y(hw_p ? t8_clear : m4_clear, 20);
    }
}
module hood_print() translate([0, 0, y_front]) rotate([-90, 0, 0]) translate([0, 0, -Zs]) hood_world();

// ---- shims: camera <-> F38 plate (F38-plate footprint, round 1/4" hole) ----
module shim(t) linear_extrude(t) difference() {
    translate([-shim_fp[0] / 2, -shim_fp[1] / 2]) square(shim_fp);
    circle(d = qtr_clear, $fn = fn_small);
}
module shim_set() for (i = [0 : len(shim_t) - 1]) translate([i * (shim_fp[0] + 6), 0, 0]) shim(shim_t[i]);
module swap_shim() shim(swap_shim_t);

// --- Mock-ups (not printed): plate, cameras, lenses, F38, FOV frusta ---
module glass_local(shift = 0) let(gs = groove_strips ? strip_glass : [plate_size, plate_size])
    translate([-gs[0] / 2, -plate_size / 2 - shift, 0]) cube([gs[0], gs[1], plate_t]);
module splitter_mockup(shift = 0) color([0.55, 0.85, 1.0, 0.35]) place_plate() glass_local(shift);
module f38_base_mock() color([0.55, 0.12, 0.12])
    translate([-f38_base[0] / 2, -f38_base[1] / 2, 0]) cube([f38_base[0], f38_base[1], f38_stack]);

module keep_back()  place_plate() translate([-300, -300, plate_t]) cube(600);
module keep_front() place_plate() translate([-300, -300, -600]) cube(600);

module rear_camera(dx = 0, env = true) translate([dx, 0, 0]) {
    c = cam_r;
    color("black") translate([0, y_rear_front, Zs]) rotate([-90, 0, 0]) cylinder(d = lens_15[0], h = L15, $fn = fn_big);
    if (env) color([0.9, 0.3, 0.3, 0.18]) intersection() {
        translate([0, y_rear_front - lens_clear_l / 2, Zs]) rotate([-90, 0, 0])
            cylinder(d = lens_15[0] + lens_clear_d, h = L15 + lens_clear_l, $fn = fn_big);
        keep_back();
    }
    color([0.25, 0.25, 0.28]) {
        translate([-c[0] / 2, y_rear_mount, z_rear_tripod]) cube([c[0], c[5], c[1]]);
        translate([-c[0] / 2, y_rear_mount - (c[2] - c[5]), z_rear_tripod]) cube([28, c[2] - c[5] + eps, c[1]]);
    }
    translate([0, y_rear_sock, z_rear_tripod - f38_stack]) f38_base_mock();
}
module bottom_camera(dx = 0, env = true) translate([dx, 0, 0]) {
    c = cam_b;
    color("black") translate([0, 0, z_bot_mount]) cylinder(d = lens_1018[0], h = L1018, $fn = fn_big);
    color([0.15, 0.1, 0.2]) translate([0, 0, z_bot_front - eps]) cylinder(d = filt_od, h = filt_len + eps, $fn = fn_big);
    if (env) color([0.5, 0.3, 0.9, 0.18]) intersection() {
        union() {
            translate([0, 0, z_bot_mount - lens_clear_l / 2]) cylinder(d = lens_1018[0] + lens_clear_d, h = L1018 + lens_clear_l, $fn = fn_big);
            translate([0, 0, z_bot_front]) cylinder(d = filt_od + lens_clear_d, h = filt_len + lens_clear_l / 2, $fn = fn_big);
        }
        keep_front();
    }
    color([0.3, 0.3, 0.33]) {
        translate([-c[0] / 2, c[3] - c[1], z_bot_mount - c[5]]) cube([c[0], c[1], c[5]]);
        translate([c[0] / 2 - 25, c[3] - c[1], z_bot_mount - eps]) cube([25, c[1], c[2] - c[5] + eps]);
    }
    color("orange") translate([0, c[3] + swap_shim_t, z_bot_sock]) rotate([90, 0, 0]) shim(swap_shim_t);
    translate([0, bc_y0 - t_slide, z_bot_sock]) rotate([90, 0, 0]) f38_base_mock();
}
module swap_shim_world() translate([-stereo_bot, cam_b[3] + swap_shim_t, z_bot_sock]) rotate([90, 0, 0]) shim(swap_shim_t);
module world_part(w) {
    if      (w == "frame")           frame();
    else if (w == "top_lid")         top_lid_world();
    else if (w == "wall_rail")       wall_rail_world();
    else if (w == "groove_strip")    groove_strips_world();
    else if (w == "glass_stop")      mirror_x() if (hw_p) glass_stop_world_p(); else place_plate() glass_stop_local();
    else if (w == "preload_screw")   preload_screws_world();
    else if (w == "rear_carriage")   translate([stereo_rear, y_rrail, deck_top]) rear_carriage_local();
    else if (w == "bottom_carriage") translate([-stereo_bot, 0, 0]) bottom_carriage_world();
    else if (w == "f38_slide")       slides_world();
    else if (w == "swap_shim")       swap_shim_world();
    else if (w == "hood")            hood_world();
    else if (w == "hardware")        hardware_world(arca = false);
    else if (w == "arca_plate")      arca_world();
    else assert(false, str("Unknown world_piece: ", w));
}
module camera_mockups() { rear_camera(stereo_rear); bottom_camera(-stereo_bot); }
module slides_world() color([0.82, 0.68, 0.45]) {
    translate([stereo_rear, y_rear_sock, deck_top + t_rear_carriage]) f38_slide_local(rear_travel);
    translate([-stereo_bot, bc_y0, z_bot_sock]) rotate([90, 0, 0]) f38_slide_local(bot_slot_trav, bot_serr, bot_slot_shift);
}

module frustum(len, th, tv) hull() {
    cube(0.1, center = true);
    translate([0, 0, len]) cube([2 * len * th, 2 * len * tv, 0.1], center = true);
}
module lid_view_wedge(x0) intersection() {
    translate([x0, 0, Zs - D]) rotate([0, 0, 90]) frustum(frame_top - 0.2 - (Zs - D), tan_v(fov_f_bot, fov_aspect), tan_h(fov_f_bot));
    keep_back();
}
module fov_frusta() {
    color([1.0, 0.6, 0.0, 0.22]) translate([stereo_rear, D, Zs]) rotate([90, 0, 0])
        frustum(fov_len, tan_h(fov_f_rear), tan_v(fov_f_rear, fov_aspect));
    color([0.6, 0.2, 1.0, 0.22]) intersection() {
        translate([-stereo_bot, 0, Zs - D]) rotate([0, 0, 90])
            frustum(D + 80, tan_v(fov_f_bot, fov_aspect), tan_h(fov_f_bot));
        keep_front();
    }
    color([1.0, 0.6, 0.0, 0.12]) lid_view_wedge(stereo_rear);
    color([0.6, 0.2, 1.0, 0.12]) lid_view_wedge(-stereo_bot);
}
module preload_screws_world() if (preload_type == "printed") color([1.0, 0.72, 0.45])
    for (sx = [-1, 1]) mirror([sx < 0 ? 1 : 0, 0, 0]) place_plate() for (p = preload_v)
        translate([x_pl, p, w_hi + boss_h + 2 + ps_head[1]]) rotate([0, 180, 0]) mirror([sx < 0 ? 1 : 0, 0, 0]) preload_screw();
module glass_stops_world() color("goldenrod") mirror_x() if (hw_p) glass_stop_world_p(); else place_plate() glass_stop_local();

// ---- printed hardware in its ASSEMBLED position (assembly colours, clash checks, CoG: world_piece = "hardware") ----
// carriage-local frame (as rear_carriage_local / bottom_carriage_local: rail face z = 0, +z toward the camera):
// 2 clamp thumbscrews + T-nuts, 2 slide T-bolts + thumb-nuts (slide face at t + t_slide), the datum pin pair
// (screws are turned head-up with rotate(), never mirror(): a mirrored right-hand thread would be left-handed)
module carriage_hw(t, cx, dsep, off, yc, pins = true) {
    for (s = [-1, 1]) {
        translate([s * cx, 0, clamp_seat + cs_head[1] + fo]) rotate([180, 0, 0]) clamp_screw();
        translate([s * cx, 0, nut_top_z - tn_t - fo]) rotate([0, 0, 90]) tnut();
        translate([s * slide_bolt_x, yc, sb_pd - sb_head[1] - fo]) rotate([0, 0, 45]) slide_bolt();
        translate([s * slide_bolt_x, yc, t + t_slide + fo]) slide_nut();
        if (pins) translate([s * dsep / 2, -off, -dowel_depth + fo]) pin(pin_d, dowel_len);
    }
}
module lid_screws_world() for (sx = [-1, 1], b = lid_bolts) translate([sx * b[0], b[1], frame_top + lid_t + lid_sh[1] + fo]) rotate([180, 0, 0]) lid_screw();
module hardware_world(lid = true, arca = true) if (hw_p) {
    if (lid) lid_screws_world();
    translate([stereo_rear, y_rrail, deck_top]) carriage_hw(t_rear_carriage, rc_clamp_x, rc_datum_sep, rc_idx_off, 0, stereo_rear == 0);
    translate([-stereo_bot, 0, 0]) translate([0, y_wf, wr_z]) rotate([90, 0, 0])
        carriage_hw(bc_t, bc_clamp_x, bc_datum_sep, wr_off, bc_bolt_z - wr_z, stereo_bot == 0);
    for (x = wrl_bolt_x) {
        translate([x, y_wf + wrl_cb - wb_head[1] - fo, wr_z + wrl_bolt_h]) rotate([-90, 0, 0]) wall_bolt();
        translate([x, y_cwm + wrl_nut_f + fo, wr_z + wrl_bolt_h]) rotate([-90, 0, 0]) rotate([0, 0, 90]) tnut();
    }
    if (!hw_fit) for (x = wrl_dowel_x) translate([x, y_cwm - (wrl_dowel_len - wrl_dowel_wall), wr_z + wrl_bolt_h]) rotate([-90, 0, 0])
        pin(pin_d, wrl_dowel_len);
    if (arca && tri_arca) arca_world();
    if (show_hood) hood_hw_world();
}
module arca_world() {
    translate([0, tri_xy[1], -fo]) mirror([0, 0, 1]) arca_plate_print();
    for (s = [-1, 1]) translate([s * arca_bx, tri_xy[1], -arca_t + arca_cb - lid_sh[1] - fo]) lid_screw();
}
module hood_hw_world() mirror_x() for (z = hood_bolt_z) {
    translate([col_x_bolt, y_front - 4 - cs_head[1] - fo, z]) rotate([-90, 0, 0]) clamp_screw();
    translate([col_x_bolt, y_front + hood_nut_y - (tn_t + 0.4) / 2 + fo, z]) rotate([-90, 0, 0]) rotate([0, 0, 90]) tnut();
}

// ---- printable hardware plates (print orientation; counts include ~20 % spares) ----
function grid_xy(i, ncol, dx, dy) = [(i % ncol) * dx, floor(i / ncol) * dy];
module hardware_screws() {
    for (i = [0 : 4]) translate([i * 25, 0, 0]) lid_screw();
    for (i = [0 : 4]) translate([i * 25, 25, 0]) clamp_screw();
    for (i = [0 : 4]) translate([i * 25, 45, 0]) slide_bolt();
    for (i = [0 : 4]) translate([i * 25, 65, 0]) wall_bolt();
}
module hardware_nuts() {
    for (i = [0 : 9]) translate(grid_xy(i, 5, 19, 18)) tnut();
    for (i = [0 : 4]) translate([i * 19, 40, 0]) slide_nut();
}
module pin_set() {
    for (i = [0 : 7]) translate(grid_xy(i, 4, 11, 11)) pin(pin_d, dowel_len);
    for (i = [0 : 2]) translate([i * 11, 24, 0]) pin(pin_d, wrl_dowel_len);
    if (f38_pins) for (i = [0 : 4]) translate([i * 9, 35, 0]) pin(f38_pin_d, f38_pin_depth + 3);
}
wc_pitch = [for (g = wrap_grip) g + 9.5];
function wc_y0(k) = k <= 0 ? 0 : wc_y0(k - 1) + ceil(wrap_qty[k - 1] / 8) * wc_pitch[k - 1];
module wrap_clips() {
    for (k = [0 : len(wrap_grip) - 1], i = [0 : wrap_qty[k] - 1])
        translate([(i % 8) * 17, wc_y0(k) + floor(i / 8) * wc_pitch[k], 0]) wrap_clip(wrap_grip[k]);
}
module hood_hardware() {
    for (i = [0 : 4]) translate([i * 19, 0, 0]) clamp_screw();
    for (i = [0 : 4]) translate([i * 19, 20, 0]) tnut();
}
module arca_plate() {
    arca_plate_print();
    for (i = [0 : 2]) translate([(i - 1) * 26, arca_w / 2 + 16, 0]) lid_screw();
}

module glass_sweep() let(gs = groove_strips ? strip_glass : [plate_size, plate_size])
    place_plate() translate([-gs[0] / 2 - 0.2, -plate_size / 2 - 400, -0.2]) cube([gs[0] + 0.4, gs[1] + 400, plate_t + 0.4]);
// insert_check: everything the sweep must NOT touch (lid, stops and screws removed).
// Everything at the current stereo_rear / stereo_bot (cameras, carriages, slides).
module insert_check() intersection() {
    glass_sweep();
    union() { frame(); hood_world(); rear_camera(stereo_rear, false); bottom_camera(-stereo_bot, false);
              translate([stereo_rear, y_rrail, deck_top]) rear_carriage_local();
              wall_rail_world(); translate([-stereo_bot, 0, 0]) bottom_carriage_world(); slides_world();
              hardware_world(lid = false); if (groove_strips) groove_strips_world(); }
}

// --- Assembly ---
module cut_half() if (cutaway) intersection() { children(); translate([-500, -500, -10]) cube([500, 1000, 600]); } else children();

module assembly() {
    color([0.32, 0.32, 0.35]) cut_half() frame();
    if (show_lid && glass_insert == 0) color([0.42, 0.42, 0.46, 0.55]) cut_half() top_lid_world();
    if (glass_insert == 0) cut_half() { glass_stops_world(); preload_screws_world(); }
    if (groove_strips) color("tomato") cut_half() groove_strips_world();
    splitter_mockup(glass_insert);
    color([0.2, 0.45, 0.7]) translate([stereo_rear, y_rrail, deck_top]) rear_carriage_local();
    color([0.45, 0.3, 0.55]) wall_rail_world();
    color([0.2, 0.6, 0.45]) translate([-stereo_bot, 0, 0]) bottom_carriage_world();
    slides_world();
    if (show_hood) color([0.15, 0.15, 0.15, 0.8]) cut_half() hood_world();
    color([0.95, 0.55, 0.15]) hardware_world(lid = show_lid && glass_insert == 0);
    if (show_cams) camera_mockups();
    if (show_fov) fov_frusta();
}

// stereo clipping readout values (evaluated here: they need every frame variable above)
// (at stereo 0 nothing is clipped by construction -- the frusta margins above are asserted -- so the ray sampling
//  only runs when a stereo offset is set; it takes ~30 s)
clip_run = clip_check && (stereo_rear != 0 || stereo_bot != 0);
clip_r = clip_run ? clip_stats(clip_map("rear",   stereo_rear, stereo_bot)) : [0, 0, 1, 0, 0, 1];
clip_b = clip_run ? clip_stats(clip_map("bottom", stereo_rear, stereo_bot)) : [0, 0, 1, 0, 0, 1];
key_steps = [for (sb = [0 : 5 : bot_stereo]) if (key_ok(-sb - bc_clamp_x, wr_z) && key_ok(-sb + bc_clamp_x, wr_z)
                 && key_ok(-sb - slide_bolt_x, bc_bolt_z) && key_ok(-sb + slide_bolt_x, bc_bolt_z)) sb];
clip_k  = let(c = min(clip_r[2], clip_b[2])) c >= 1 ? 100 : max(0, 100 * (c - 1 / clip_grid[1]));
clip_ku = let(c = min(clip_r[5], clip_b[5])) c >= 1 ? 100 : max(0, 100 * (c - 1 / clip_grid[1]));

// --- Part selector (printable parts: plain geometry, laid flat in print orientation) ---
parts = ["assembly", "frame", "top_lid", "wall_rail", "glass_stop", "preload_screw", "rear_carriage",
         "bottom_carriage", "f38_slide", "hood", "shim_set", "swap_shim",
         "groove_test", "groove_strip", "thread_test", "rail_test", "pin_test", "hardware_screws", "hardware_nuts", "pin_set", "wrap_clips",
         "hood_hardware", "arca_plate", "splitter_mockup", "camera_mockups", "insert_check", "strip_insert_check", "world", "none"];
assert(len([for (p = parts) if (p == part) p]) == 1, str("Unknown part: ", part));
assert(hw_p || len([for (p = ["pin_test", "hardware_screws", "hardware_nuts", "pin_set", "wrap_clips", "hood_hardware"]) if (p == part) p]) == 0,
       str("part = \"", part, "\" is printed hardware: set hardware = \"printed\""));
assert(tri_arca || part != "arca_plate", "part = \"arca_plate\" needs tripod_mount = \"arca\"");

if      (part == "assembly")        assembly();
else if (part == "frame")           frame();
else if (part == "top_lid")         top_lid_print();
else if (part == "wall_rail")       wall_rail_print();
else if (part == "glass_stop")      glass_stop_print();
else if (part == "preload_screw")   preload_screw_set();
else if (part == "rear_carriage")   rear_carriage_print();
else if (part == "bottom_carriage") bottom_carriage_print();
else if (part == "f38_slide")       f38_slide_print();
else if (part == "hood")            hood_print();
else if (part == "shim_set")        shim_set();
else if (part == "swap_shim")       swap_shim();
else if (part == "groove_test")     groove_test();
else if (part == "groove_strip")    groove_strip_print();
else if (part == "strip_insert_check") strip_insert_check();
else if (part == "thread_test")     thread_test();
else if (part == "rail_test")       rail_test();
else if (part == "pin_test")        pin_test();
else if (part == "hardware_screws") hardware_screws();
else if (part == "hardware_nuts")   hardware_nuts();
else if (part == "pin_set")         pin_set();
else if (part == "wrap_clips")      wrap_clips();
else if (part == "hood_hardware")   hood_hardware();
else if (part == "arca_plate")      arca_plate();
else if (part == "splitter_mockup") splitter_mockup(glass_insert);
else if (part == "camera_mockups")  camera_mockups();
else if (part == "insert_check")    insert_check();
else if (part == "world")           world_part(world_piece);
