# Printing

Every STL in `stl/` is exported **in its print orientation at 100 % scale**, and no part needs supports. Most print
problems come from a slicer trying to be helpful, so start with the rules below.

## Golden rules

1. **Supports OFF** for every file.
2. **Do not rotate, scale or auto-orient.** If the slicer asks whether to split a file into separate objects, either
   answer is fine, but leave every piece where and how it lies.
3. Print the **test coupons first** (`stl/tests/`). They take about 170 g and tell you whether the printed threads and
   pins fit on *your* printer before you spend 0.7 kg on the frame.
4. Files ending in `_solid` are **hardware**: print them at 100 % infill with fine layers (see below).

## Printer and material

| | |
|---|---|
| Build volume | at least 250 × 250 × 245 mm. The frame is 208 × 235 × 244 mm, including the two lid pins on top. |
| Nozzle | 0.4 mm. Always print the hardware and the coupons with 0.4 mm. A 0.6 mm nozzle works for the big parts (0.30 mm layers, 4 walls) and cuts the frame print time by roughly a third. If you print the **frame** with 0.6 mm, use `stl/alternatives/frame_for_0.6_nozzle.stl` (exported with `ps_clear = 0.3`). A 0.6 mm nozzle prints holes a little tighter, so its threaded holes still mate with screws printed on 0.4 mm. |
| Material | **PLA** for a fit-check prototype. **PETG** for the final build, because PLA creeps under a constant load and softens in a hot car. Black is best, but see the infrared note in [ASSEMBLY.md](ASSEMBLY.md#13-light-proofing). |
| Reference printer | Creality SPARKX i7, 0.4 mm nozzle, Creality Print 7.3, starting from its "0.20 mm Standard" profile |

## Slicer settings

| Setting | Structural parts (01–10) | Hardware (`_solid` files, wrap clips, Arca plate) | Coupons |
|---|---|---|---|
| Layer height | 0.20 mm (0.24 mm is OK for the frame to save time) | **0.12–0.16 mm** (clean 45° thread flanks) | 0.16 mm |
| Walls | 4 (PETG: 5–6) | 5 | 4 |
| Infill | 20 % gyroid (PETG: 30 %) | **100 %** (the screws and pins *are* the load path) | `thread_test`, `pin_test`: 100 %. `groove_test`, `rail_test`: 20 %. |
| Top / bottom layers | 5 / 4 | (solid anyway) | 5 / 4 |
| Outer wall speed | normal | **slow, 40–60 mm/s, outer wall first** | 60 mm/s |
| Cooling | normal | fan 100 % after layer 3 | normal |
| Brim | frame **5 mm**, bottom carriage 5 mm, none on the rest | 3 mm on the pins (tall and thin), none on the rest | `groove_test` 3 mm, `rail_test` 5 mm |
| Seam | aligned / rear | aligned | aligned |

Notes:

- **Frame strength:** the frame's diagonal members cross the layers at 45°, so the frame is only as strong as its
  layer bonding. For the frame, use the upper end of your filament's temperature range (PLA: about 215–220 °C),
  limit the part-cooling fan to about 50 %, and keep 4 walls (5 with a 0.6 mm nozzle is better still). PETG bonds
  its layers much better than PLA. Don't lever or twist the frame by its diagonal glass ribs.
- **Frame brim:** keep it at about 5 mm. A wider brim (8 mm) makes the frame's footprint 251 mm long, which is more
  than a 250 mm bed.
- **Hardware plate:** print each hardware plate as one job. Moving between parts gives each one time to cool, which
  keeps the threads sharp.
- **PETG hardware:** print it about 5 °C hotter and a little slower than usual for good layer bonding.

## Per-part notes

| File | How it lies on the bed | Watch out for |
|---|---|---|
| `01_frame.stl` | Standing on its base | The longest print by far. Bridges up to about 19 mm under the rear deck print fine with normal bridge settings. See also "Slicer warnings" below. |
| `02_top_lid.stl` | Flat, underside down | The underside is the flat flocking face of the light trap |
| `03_wall_rail.stl` | Flat on its mounting face, T-slot up | — |
| `04_rear_carriage.stl` | Slide face down | Short bridges over the T-bolt pockets |
| `05_bottom_carriage.stl` | Standing on its long bottom edge | Tall and thin: use a 5 mm brim |
| `06_f38_slides_x2.stl` | Top face down, guide tongue up | — |
| `07_glass_stops_x2.stl` | Ear down; the block rises from it with 45° faces | Mirror pair: one for each side |
| `08_groove_strips_x2.stl` | On its side (the strip's outer face down), as laid out | Mirror pair. **Keep both strips in the same print** so their lips come out the same thickness (a 0.1 mm difference tilts the glass sideways by about 0.04°). Print **solid** (100 % infill) with a 3–5 mm brim, and remove the brim cleanly. The two leaf springs in each strip are vertical walls, so there are no bridges. |
| `09_shim_set_print_2x.stl` | Flat | Print the file twice |
| `10_swap_shim_3mm_riser.stl` | Flat | — |
| `11_hardware_screws_solid.stl` | Screws and bolts standing, head down | Never lay a screw on its side: the threads would be weak and rough |
| `12_hardware_nuts_solid.stl` | Flat | — |
| `13_glass_thumbscrews_solid.stl` | Standing, head down | — |
| `14_pins_solid.stl` | Standing on a 45° foot chamfer | 3 mm brim |
| `15_wrap_clips.stl` | Flat | — |
| `alternatives/arca_plate.stl` | Flat, plus 3 M10 thumbscrews standing | Hardware settings |

Print order: coupons → frame → wall rail, lid → carriages, slides → stops, strips, shims → hardware plates.

## Slicer warnings you can ignore

- **"Floating cantilever" on the six glass-thumbscrew bosses.** Some slicers flag the lower inner corner of each
  thumbscrew boss on the frame's glass ribs. It starts as a one-sided line about 8 mm long that is attached to the rib.
  It prints with a slight droop. **Do not enable supports for it:** they would land on the glass seat. After printing,
  clean the corner with a knife so nothing hangs into the groove.
- Small overhangs at the tops of round horizontal holes and teardrop holes.
- The cold-shoe lips on the lid (about 3 mm).
- The M10 threads in the glass-rib bosses are tilted 45°, so one thread flank faces almost straight down. That can't be
  avoided for a tilted thread. `groove_test` prints the same boss, so check it there.

You should **not** see a "floating regions" (mid-air start) warning on any file. If you do, the file was probably
rotated or scaled.

## Test coupons

Print these first. Each one checks one kind of joint and points to one parameter. If a coupon fails, change that
parameter (see [CUSTOMIZE.md](CUSTOMIZE.md)), re-export the parts listed, and only then print the rest.

| Coupon | What is on it | How to test | Parameter (default) | Re-export after a change |
|---|---|---|---|---|
| `thread_test.stl` | M10 × 2 and M8 × 2 nut blocks at clearances 0.2 / 0.3 / 0.4, with 3 short screws each. 1/4"-20 holes at 0.1 / 0.2 / 0.3, plus a standing **H** block with a horizontal 1/4"-20 hole. | Turn each printed screw into its block. Pick the clearance that turns smoothly by hand without wobble. Then try **your steel 1/4" screw** in the 1/4"-20 holes and the H block: it must go in by hand and sit snug. | `ps_clear` (0.2) for M10 / M8. `unc_clr` (0.2) for 1/4"-20. | `ps_clear`: frame, nuts (`12_…`), Arca variants. `unc_clr`: frame, lid. |
| `pin_test.stl` | Ø5 pin holes at 0.1 / 0.2 / 0.3 clearance, both vertical and horizontal (teardrop). A **P** press-fit hole, an **F38** press hole, 3 pins and 1 F38 pin. | Push the pins into the holes. Pick the tightest clearance that still slides by hand in **both** rows. The pin must stay in the P hole by friction, and the F38 hole must hold the F38 pin firmly. | `pin_clr` (0.2). `pin_press` (0.0) for the P hole. `f38_pin_d` for the F38 hole. | `pin_clr`: frame, wall rail, carriages, lid. `pin_press`: frame. `f38_pin_d`: slides, pins. |
| `rail_test.stl` | An 80 mm slice of the wall rail, a test carriage, a block of the frame's crosswall band, 2 clamp thumbscrews, 3 T-nuts, 1 rail bolt and 4 pins | Slide a T-nut into the rail's T-slot from the end, **bevels toward the slot opening**. Put the carriage on (tongue in the groove). It should slide without play. Turn a clamp thumbscrew through the carriage into the T-nut by hand: it must clamp before it bottoms out. Press the two short pins into the block, slip the rail slice over them, drop a T-nut into the block's slot (**flat face toward the rail**) and pull rail and block together with the rail bolt. | `ps_clear`, `pin_clr`, `tongue_clear` (0.2 per side) | as above. `tongue_clear`: carriages, slides. |
| `groove_test.stl` | Four short pieces of the glass rib with the strip channel (roof width 3.4 / 3.6 / 4.0 / 4.4 mm), four strip pieces and one glass thumbscrew | Slide a strip piece into each channel: it must go fully home and lie flat on the seat. With felt applied, a glass offcut (or a 2 mm flat bar) should slide into the **4.0** coupon with a little play. Zero a digital angle gauge on the coupon's vertical rear fin and read the glass: 45.0° ± 0.2°. Turn the thumbscrew into the boss. | `groove_w` (4.0) | frame, strips |

- When in doubt, re-export all parts. It only takes longer.
- If the flank angle in `groove_test` is off by more than about 0.3°, fix the printer (skew, shrinkage) rather than the
  model. The glass angle comes from the frame.
- `groove_test` is optional if you trust your printer. The groove is deliberately generous, and the thumbscrews take
  up the slack.

## Filament estimate

These figures use 4 walls and 20 % infill for structural parts (PETG: 5–6 walls, 30 %) and 100 % for hardware.

| Group | PLA | PETG |
|---|---|---|
| Rig parts (frame ≈ 670 g, lid ≈ 100 g, wall rail ≈ 100 g, the rest ≈ 140 g) | ≈ 1.01 kg | ≈ 1.26 kg |
| Printed hardware | ≈ 0.09 kg | ≈ 0.09 kg |
| Test coupons | ≈ 0.17 kg | ≈ 0.21 kg |
| **Total** | **≈ 1.3 kg → two 1 kg spools** | **≈ 1.6 kg → two spools, three to be safe** |

Add 3–5 % for brim and purge. A failed frame costs about 0.7 kg.
