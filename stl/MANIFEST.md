# Print files

Binary STLs exported from [`model/beamsplitter_rig.scad`](../model/beamsplitter_rig.scad) with its **default values**
(printed hardware, heat-set tripod insert, 0.2 mm thread and pin clearances). Every file is already in its print
orientation at 100 % scale: do not rotate or scale it, and leave supports off. Settings and per-part notes are in
[docs/PRINTING.md](../docs/PRINTING.md). To re-export after changing a parameter, run `tools/export_all.sh`
(see [tools/README.md](../tools/README.md)).

**Infill:** "structural" means 4 walls and 20 % gyroid infill at 0.2 mm layers (PETG: 5–6 walls, 30 %). Hardware is
printed solid (100 %) because the threads and pins carry the load.

Size is the bounding box on the bed (X × Y × Z, mm). The SHA-256 column is the first 12 characters of the file's
checksum, so you can tell whether a download matches this list.

## The rig

| File | What it is | Print | Infill | Size (mm) | SHA-256 |
|---|---|---|---|---|---|
| `01_frame.stl` | One-piece frame, with a hole for a 1/4"-20 heat-set insert (tripod socket) | 1 | structural; 5 mm brim | 208 × 235 × 244 | `32a81084626d` |
| `02_top_lid.stl` | Lid: top chord, light trap, cold shoe | 1 | structural | 208 × 130 × 16 | `5959c6580fd2` |
| `03_wall_rail.stl` | Sideways rail for the bottom camera | 1 | structural | 200 × 54 × 15 | `5e2781c4b439` |
| `04_rear_carriage.stl` | Rear camera carriage | 1 | structural | 116 × 60 × 8 | `e3d0a91d1496` |
| `05_bottom_carriage.stl` | Bottom camera carriage | 1 | structural; 5 mm brim | 116 × 9 × 76 | `59492c97698c` |
| `06_f38_slides_x2.stl` | Two fore-aft slides that carry the F38 bases | 1 (gives 2) | structural | 174 × 57 × 8 | `68d75f55cea1` |
| `07_glass_stops_x2.stl` | Two glass stops (mirror pair) | 1 (gives 2) | structural | 77 × 31 × 15 | `9846011b8faf` |
| `08_groove_strips_x2.stl` | Two glass groove strips (mirror pair), on their side; keep them in one print | 1 (gives 2) | solid (100 %); 3–5 mm brim | 154 × 19 × 8 | `507806b95aa7` |
| `09_shim_set_print_2x.stl` | 0.5 / 1 / 2 mm camera shims | **2** | structural | 120 × 44 × 2 | `b3467a97e8eb` |
| `10_swap_shim_3mm_riser.stl` | 3 mm riser between the bottom camera and its F38 plate (needed for the default a5100) | 1 | structural | 36 × 44 × 3 | `27afb5a3277f` |
| `11_hardware_screws_solid.stl` | Lid and clamp thumbscrews, T-bolts, rail bolts (with spares) | 1 | **100 %**, 0.12–0.16 mm layers | 120 × 81 × 27 | `1c727b546a94` |
| `12_hardware_nuts_solid.stl` | T-nuts and thumb-nuts (with spares) | 1 | **100 %**, 0.12–0.16 mm layers | 90 × 52 × 7 | `18258fb2e623` |
| `13_glass_thumbscrews_solid.stl` | Seven M10 glass thumbscrews (6 + 1 spare) | 1 | **100 %**, 0.12–0.16 mm layers | 83 × 37 × 18 | `438fc2033b7e` |
| `14_pins_solid.stl` | Datum, alignment and F38 locating pins (with spares) | 1 | **100 %**, 0.12–0.16 mm layers; 3 mm brim | 40 × 40 × 25 | `952c4e80c824` |
| `15_wrap_clips.stl` | 72 push-through clips for the black side wrap | optional | **100 %** | 133 × 151 × 3 | `8ab919467ae3` |

Everything else is bought: the glass, two F38 quick-release kits, a few 1/4"-20 screws, self-adhesive felt and (for
`01_frame.stl`) one 1/4"-20 heat-set insert. See [docs/HARDWARE.md](../docs/HARDWARE.md).

## Test coupons (`tests/`, print these first)

| File | What it is | Print | Infill | Size (mm) | SHA-256 |
|---|---|---|---|---|---|
| `tests/groove_test.stl` | Glass groove coupon: 4 rib pieces, 4 strip pieces, 1 thumbscrew | 1 | 20 %; 3 mm brim | 116 × 156 × 40 | `0457968fa109` |
| `tests/thread_test.stl` | Thread fit coupon: M10, M8 and 1/4"-20 at three clearances | 1 | **100 %** | 66 × 140 × 17 | `ef7dddaa15b8` |
| `tests/pin_test.stl` | Pin fit coupon: 5 mm pin holes at three clearances, F38 pin | 1 | **100 %** | 68 × 54 × 20 | `a42428faf540` |
| `tests/rail_test.stl` | Rail coupon: rail slice, carriage, crosswall block, screws, T-nuts, pins | 1 | 20 %; 5 mm brim | 134 × 96 × 36 | `1f03aedfa798` |

How to read each coupon: [docs/PRINTING.md](../docs/PRINTING.md#test-coupons).

## Alternatives (`alternatives/`)

Pick **one** frame: `01_frame.stl` (heat-set insert, recommended), or one of these.

| File | What it is | Print | Infill | Size (mm) | SHA-256 |
|---|---|---|---|---|---|
| `alternatives/frame_tripod_printed.stl` | Frame with a printed 1/4"-20 tripod thread (instead of 01) | instead of 01 | structural; 5 mm brim | 208 × 235 × 244 | `73d21d79a699` |
| `alternatives/frame_for_0.6_nozzle.stl` | `01_frame.stl` for a 0.6 mm nozzle (0.3 mm layers, about a third faster): threads 0.1 mm looser, so they still mate with hardware printed on 0.4 mm | instead of 01 | structural; 5 mm brim | 208 × 235 × 244 | `d18d9f952436` |
| `alternatives/frame_tripod_arca.stl` | Frame for the Arca-Swiss plate (instead of 01) | instead of 01 | structural; 5 mm brim | 208 × 235 × 244 | `266a644afba1` |
| `alternatives/arca_plate.stl` | Arca-Swiss plate plus its M10 thumbscrews (with `frame_tripod_arca`) | 1 with the Arca frame | **100 %**, 0.12–0.16 mm layers | 90 × 63 × 27 | `ae01b50bc4d3` |

The checksums belong to the files as committed. Re-exporting, even with unchanged parameters, can change them
(OpenSCAD may order the triangles differently).
