# AGENTS.md

Guidance for contributors, human or AI-assisted, working on this repository. The user-facing docs are in
[README.md](README.md) and [docs/](docs/).

## The project in brief

This is a 3D-printable rig that holds a 150 × 150 mm plate beam splitter at a fixed 45° between two cameras, for
visible + infrared compositing from one viewpoint and for small-interaxial stereo. The whole design is one parametric
OpenSCAD file. Python scripts audit printability and estimate the stereo crop.

## Repository map

```
model/beamsplitter_rig.scad   the design: parameters (top), derived values, modules, part selector (bottom)
stl/                          generated STLs, default parameters, numbered 01–15
stl/tests/                    test coupons (groove, thread, pin, rail)
stl/alternatives/             tripod variants of the frame + Arca plate
docs/                         user docs: PRINTING, ASSEMBLY, CUSTOMIZE, DESIGN, HARDWARE, LIMITATIONS
docs/img/                     renders of the model (generated)
tools/                        export_all.sh, render_images.sh, stl_ascii_to_binary.py and the Python checks
                              (islands.py, bridges.py, overhang_scan.py, stereo_clip.py, cog.py); see tools/README.md
```

## What is authoritative

- **`model/beamsplitter_rig.scad` is the single source of truth.** Everything in `stl/` and `docs/img/` is generated
  from it. If the docs and the model disagree, the model wins: fix the docs.
- Parameters **above** the `DERIVED VALUES` line are user settings, grouped for the OpenSCAD Customizer. Everything
  below is computed. Never tune the design by editing a derived value.
- `tools/stereo_clip.py` deliberately re-implements the optical obstacle model, with its own copy of the defaults (the
  `P` dict). If you change an optics-related default in the `.scad`, change it there too.

## Regenerating STLs

OpenSCAD 2021.01 (CGAL) is the reference version. The frame and the hardware plates take several minutes each because
of the helical threads. `tools/export_all.sh` exports the whole set and converts it to binary STL; the commands
below do the same by hand. Run from the repository root:

```sh
SCAD=model/beamsplitter_rig.scad
ex() { out=$1; part=$2; shift 2; openscad -o "$out" -D "part=\"$part\"" "$@" "$SCAD"; }
ex stl/01_frame.stl                   frame
ex stl/02_top_lid.stl                 top_lid
ex stl/03_wall_rail.stl               wall_rail
ex stl/04_rear_carriage.stl           rear_carriage
ex stl/05_bottom_carriage.stl         bottom_carriage
ex stl/06_f38_slides_x2.stl           f38_slide
ex stl/07_glass_stops_x2.stl          glass_stop
ex stl/08_groove_strips_x2.stl        groove_strip
ex stl/09_shim_set_print_2x.stl       shim_set
ex stl/10_swap_shim_3mm_riser.stl     swap_shim
ex stl/11_hardware_screws_solid.stl   hardware_screws
ex stl/12_hardware_nuts_solid.stl     hardware_nuts
ex stl/13_glass_thumbscrews_solid.stl preload_screw
ex stl/14_pins_solid.stl              pin_set
ex stl/15_wrap_clips.stl              wrap_clips
for t in groove_test thread_test pin_test rail_test; do ex "stl/tests/$t.stl" "$t"; done
ex stl/alternatives/frame_tripod_printed.stl frame      -D 'tripod_mount="printed"'
ex stl/alternatives/frame_tripod_arca.stl    frame      -D 'tripod_mount="arca"'
ex stl/alternatives/arca_plate.stl           arca_plate -D 'tripod_mount="arca"'
ex stl/alternatives/frame_for_0.6_nozzle.stl frame      -D ps_clear=0.3
```

OpenSCAD writes ASCII STL: convert it with `python3 tools/stl_ascii_to_binary.py` before committing, and update the
checksums in `stl/MANIFEST.md`. Regenerate only the files your change affects, and keep the published file names. A failed assertion stops the
export, which is intended.

## Checks before you submit

| # | When | Command | Pass |
|---|---|---|---|
| 1 | Always | `openscad -o out/summary.echo -D 'part="none"' model/beamsplitter_rig.scad` | No `ERROR: Assertion` line, no `WARNING`. The summary values you meant to change did change. |
| 2 | Geometry changed | Render (F6) or export each affected part | Completes without errors, one closed solid, fits 250 × 250 × 245 |
| 3 | Geometry changed | `python3 tools/islands.py part.stl 0.2 0.25 1` (STL in print orientation, as exported) | `floating island starts` count is 0 (if not, re-run at layer height 0.21 to rule out slice-plane artifacts) |
| 4 | Geometry changed | `python3 tools/bridges.py part.stl` and `python3 tools/overhang_scan.py part.stl` | No new long bridges (frame ≤ about 19 mm) and no new unsupported regions |
| 5 | Glass, groove, strips, cameras or anything near them | Export `part="insert_check"` and `part="strip_insert_check"` | Empty result |
| 6 | Optics or obstacles | `python3 tools/stereo_clip.py --grid 64x36 --point 20,20` against the console estimate with `-D stereo_rear=20 -D stereo_bot=20` | Both agree. Update the table in `docs/DESIGN.md` from a `--grid 256x144` run. |
| 7 | New or changed assertion | Run once with a value that should fail | Trips with a message that names the fix |

## Conventions

- **Units** are mm and degrees.
- **Coordinates:** X is left/right (the rig is symmetric about X = 0), Y is front/back (the scene is at −Y, Y = 0 at the
  glass centre) and Z is up (Z = 0 at the underside of the base). The glass centre is at `(0, 0, Zs)`. Geometry around
  the glass uses the plate-local frame (*x*, *v*, *w*), and `place_plate()` maps it to world coordinates. See
  [docs/DESIGN.md](docs/DESIGN.md#coordinates).
- **Symmetry:** model the +X side and add the −X side with `mirror_x()`.
- **Thread handedness rule:** a mirrored helix is left-handed, and printed or steel right-hand screws will not enter
  it. Female thread cutters must stay right-handed:
  - Cut every printed female thread with `thread_hole()`, `m_hole()` or `unc_hole()`. Each one wraps
    `thread_unmirror()`, which reads the mirror state `$mx` set by `mirror_x()` and re-mirrors the cutter about its own
    axis.
  - Position a cutter with `translate()` / `rotate()` so that its axis passes through the cutter's local origin, and call
    it inside the `mirror_x()` subtree so `$mx` propagates.
  - Use `mirror_x()`, never a bare `mirror([1,0,0])`, around anything that contains a thread. A new thread cutter must
    be wrapped in `thread_unmirror()`.
  - Never mirror a male thread. Assembly and world placements of screws use rotations only.
- **Print orientation:** each printable part's module outputs the part lying on z = 0 in its print orientation. Keep
  every downward-facing surface at 45° or steeper, make horizontal holes teardrops, and avoid mid-air starts. The STLs
  must print with supports off.
- **Assertions:** every geometric constraint gets an `assert()` whose message says what is wrong and which parameter
  to change. Add values a user should see to the console summary. Compare computed boundaries with a small tolerance
  (`1e-9`).
- **Customizer:** user parameters go at the top, in `/* [Group] */` sections, one per line with a short trailing
  comment. Choice lists use the `// [a, b, c]` form. The comment text is shown to users, so keep it plain.
- **Compatibility:** OpenSCAD 2021.01, with no external libraries and no `include` / `use`. Python 3. Only
  `islands.py`, `bridges.py` and `overhang_scan.py` need numpy. Each script documents its usage in its docstring.
- **Comments** describe the current design briefly. History belongs in `CHANGELOG.md`.

## Do not

- Hand-edit, repair or re-orient STLs. Regenerate them from the model.
- Add history comments ("vN: changed …", "was …", review IDs or review notes) to code or docs.
- Commit absolute local paths, usernames, machine names, email addresses or other personal data.
- Commit `out/`, `*.echo`, logs or scratch files (see `.gitignore`).
- Weaken or delete an assertion to make a change pass. Fix the geometry, or document a new limit in
  `docs/LIMITATIONS.md`.
- Rename published STL files or user parameters without updating every doc that mentions them.
- Add geometry that needs supports, or change a part's print orientation without updating `docs/PRINTING.md`.
- Change the frame for a fix that a small part can carry. Printing a frame takes many hours, and existing builds should stay compatible.
  Prefer changes to strips, stops, lid or hardware, and prove the frame is unchanged by comparing a fresh
  `part="frame"` export's triangle set with `stl/01_frame.stl`. The strip channel is frame geometry: `x_ch`, `key_x`,
  `key_h`, `strip_clr`, `strip_cap`, `groove_w`, `lip_proud`, `plate_size`.

## Keep the docs in sync

| If you change | Also update |
|---|---|
| A parameter (name, default, meaning) | `docs/CUSTOMIZE.md` |
| Print orientation, settings or a coupon | `docs/PRINTING.md` |
| An assembly step or fastener | `docs/ASSEMBLY.md`, `docs/HARDWARE.md` |
| A part or file name, or quantities | `README.md`, `docs/HARDWARE.md`, `docs/CUSTOMIZE.md`, this file |
| Optics, clearances or the stereo crop | `docs/DESIGN.md` |
| Anything not yet proven or a known issue | `docs/LIMITATIONS.md` |
| Anything users will notice | `CHANGELOG.md` |
