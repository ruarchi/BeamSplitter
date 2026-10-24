# Parts list

Counts are for the default build: printed hardware, heat-set tripod insert, a6400 at the rear, a5100 at the bottom.

## Bought parts

| Item | Qty | Where it goes |
|---|---|---|
| Plate beam splitter, 150 × 150 × 2 mm, 50 % reflection / 50 % transmission | 1 | In the groove strips. Any size from 149.6–154 × 145–150.8 mm works with reprinted strips. An anti-reflection coated back face reduces ghosting. |
| F38 quick-release kit (base + plate), e.g. Ulanzi UKA01 or compatible | 2 | One base per slide, one plate per camera |
| 1/4"-20 × 3/8" (9.5 mm) steel screw, low head (≤ Ø13 × 4 mm) | 2 | Fixes each F38 base to its slide. It goes into the base's metal thread and carries the camera, so it must be steel. |
| 1/4"-20 screw, 3 mm longer than your F38 plate's own screw | 1 | a5100 → 3 mm riser → its F38 plate |
| Self-adhesive felt, 0.5 mm | ≈ 0.1 m² | Everything that touches the glass (see below) |
| 1/4"-20 × 8 mm heat-set insert | 1 | Tripod socket. Only for `01_frame.stl`; not needed with the printed-thread or Arca frame. |

**Felt cutting list**

| Piece | Qty |
|---|---|
| Lower lip of each groove strip, ≈ 3 × 152 mm, one layer | 2 |
| Upper groove flank, as wide as the groove roof (≈ 1.6 mm by default) × ≈ 150 mm, cut into 4 pieces that leave the 3 thumbscrew holes free | 2 |
| Thumbscrew tip discs, Ø8 mm (they pass through the Ø8.8 mm boss thread with the screw, so not Ø10) | 6 |
| End-cap and glass-stop pads, 2 layers (1 mm) | 4 |

**For clean images** (not hardware, but needed):

| Item | Amount | Use |
|---|---|---|
| Black aluminium foil (e.g. Cinefoil) or blackout-coated fabric, tested for infrared | ≈ 1 m² | Side wrap, rear skirt |
| Flocking film | ≈ 0.03 m² | Lid underside (light trap) |
| Matt black paint | a little | Thumbscrew bosses and heads, upper groove flanks, glass-stop ears |
| Black tape | a little | Covers unused lid holes from below |

**Optional:** a dual-release (Y-split) cable for the cameras' Multi terminals (simultaneous stills), and an Arca-type
tripod clamp if you print the Arca frame.

**Tools:** soldering iron, calipers, a 5 mm hex key (a long one, ≥ 140 mm, reaches the bottom clamps from the front),
knife, scissors, an 8 mm hole punch (felt discs), small pliers, gloves and a paper clip bent into a hook (to pull the
groove strips out). You don't need a reamer, glue or a wrench.

## Printed parts

| Part | Qty | File |
|---|---|---|
| Frame | 1 | `01_frame.stl` (or a file from `stl/alternatives/`) |
| Top lid | 1 | `02_top_lid.stl` |
| Wall rail | 1 | `03_wall_rail.stl` |
| Rear carriage | 1 | `04_rear_carriage.stl` |
| Bottom carriage | 1 | `05_bottom_carriage.stl` |
| F38 slides: rear (40 mm travel) and bottom (20 mm, serrated) | 2 | `06_f38_slides_x2.stl` |
| Glass stops (mirror pair) | 2 | `07_glass_stops_x2.stl` |
| Groove strips (mirror pair) | 2 | `08_groove_strips_x2.stl` |
| Shim sets, 0.5 / 1 / 2 mm | 2 sets | `09_shim_set_print_2x.stl`, printed twice |
| Swap shim (3 mm riser for the a5100) | 1 | `10_swap_shim_3mm_riser.stl` |
| Arca plate + 3 M10 thumbscrews (Arca option only) | 1 | `stl/alternatives/arca_plate.stl` |

## Printed hardware

The plates include about 20 % spares.

| Item | On the plate | Used | File | Where |
|---|---|---|---|---|
| Lid thumbscrew M10 × 20, lobed head Ø20 | 5 | 4 | `11_hardware_screws_solid` | Lid → threaded pads on the post tops |
| Clamp thumbscrew M8 × 17, head Ø13, 5 mm hex socket | 5 | 4 | `11_hardware_screws_solid` | Carriages → rails (2 rear, 2 bottom) |
| Slide T-bolt M8, square head | 5 | 4 | `11_hardware_screws_solid` | Diamond pockets under the carriages → up through the slides |
| Wall-rail bolt M8 × 21, round head, 5 mm hex socket | 5 | 4 | `11_hardware_screws_solid` | Wall rail → crosswall |
| T-nut M8 with 45° bevels | 10 | 8 | `12_hardware_nuts_solid` | 2 in the rear rail, 2 in the wall rail, 4 in the crosswall band |
| Slide thumb-nut M8, lobed | 5 | 4 | `12_hardware_nuts_solid` | On the slide T-bolts |
| Glass thumbscrew M10 × 12, lobed head Ø17 | 7 | 6 | `13_glass_thumbscrews_solid` | Three per glass rib, felt on the tip |
| Pin Ø5 × 25 | 8 | 6 | `14_pins_solid` | Datum pair + 1 vernier pin per carriage |
| Pin Ø5 × 12 | 3 | 2 | `14_pins_solid` | Wall-rail alignment (pressed into the crosswall) |
| F38 locating pin Ø4 × 8 | 5 | 4 | `14_pins_solid` | Pressed into the slides (2 per slide) |
| Wrap clip, grip 8.5 / 6.5 / 4.5 mm | 48 / 16 / 8 | ≈ 60 | `15_wrap_clips` | Side wrap and rear skirt |

Also built into the printed parts: two lid locating pins (on the front posts), a printed 1/4"-20 thread in the lid
(cold-shoe side, for light accessories), four horizontal printed 1/4"-20 threads in the front columns (light
accessories only), and the tripod thread on the printed-thread frame.

## Steel hardware mode

Setting `hardware = "steel"` builds an alternative version for metal fasteners. It uses a fixed groove in the frame
instead of the swappable strips. **This mode has not been built or tested in this release**, and its STLs are not in
`stl/`. Shopping list:

| Item | Qty |
|---|---|
| M4 × 12 socket head screw | 8 |
| M4 × 16 socket head screw | 6 |
| M4 × 20 socket head screw | 4 |
| M4 square nut (7 × 7 × 2.5) | 18 |
| M4 washer | 4 |
| M4 fender washer DIN 9021, 1.0 mm thick | 4 |
| Ø4 × 25 steel dowel pin | 6 (+2 spare) |
| Ø4 × 12 steel dowel pin | 4 |
| Ø4 × 8 steel pin (F38) | 4 |
| 1/4"-20 heat-set insert × 8 mm / × 10 mm | 2 / 4 |
| 4 mm H7 reamer, CA glue | — |

The common items (F38 kits, the 1/4"-20 base screws, felt, glass) are needed as above.
