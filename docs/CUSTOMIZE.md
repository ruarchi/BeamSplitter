# Customizing the model

Everything is generated from one file, `model/beamsplitter_rig.scad`. You change numbers in OpenSCAD's Customizer, check
the console, and export new STLs. You don't need to write any code.

## OpenSCAD in five minutes

1. Install [OpenSCAD](https://openscad.org/). The model was developed with version 2021.01 and needs no libraries.
2. Open `model/beamsplitter_rig.scad` and press **F5** (preview). You see the whole rig with mock-up cameras, the glass
   (pale blue) and the two camera fields of view (orange = rear camera, purple = bottom camera). Printed hardware is
   bright orange.
3. Open **Window → Customizer**. The parameters are in groups. **What to draw** chooses the part and the view
   options, **Hardware and tripod mount** and **Stereo** set the modes, and **Measure first** holds the values to
   measure on your own gear. Everything below the `DERIVED VALUES` line in the file is computed, so don't edit it.
4. After every change, press **F5** and read the **Console**. A summary is printed first. If something does not fit, a
   red `ERROR: Assertion ... failed` message names the problem and usually the fix.
5. To export a part, set `part` to its name, press **F6** (full render), then use **File → Export → Export as STL**. The
   frame takes several minutes to render because of its threads.

Useful switches for `part = "assembly"` (groups **What to draw** and **Stereo**):

| Parameter | Effect |
|---|---|
| `show_lid`, `show_fov`, `show_cams` | Show or hide the lid, the camera view wedges and the camera mock-ups |
| `cutaway` | Removes one half of the frame and lid so you can see inside |
| `glass_insert` | Slides the glass this many mm out along its grooves (insertion path) |
| `stereo_rear`, `stereo_bot` | Stereo offsets in mm (rear up to 40, bottom up to 45). The console then prints the estimated clipping and clean crop. |
| `clip_check` | Turns the stereo crop estimate on or off (it adds about 30 s to F5) |

## Part selector

`part` takes one of these names. Each printable part is drawn alone, laid in its print orientation.

| `part` | STL in this repo | Extra settings |
|---|---|---|
| `frame` | `stl/01_frame.stl` | `tripod_mount = "insert"` (default) |
| `top_lid` | `stl/02_top_lid.stl` | |
| `wall_rail` | `stl/03_wall_rail.stl` | |
| `rear_carriage` | `stl/04_rear_carriage.stl` | |
| `bottom_carriage` | `stl/05_bottom_carriage.stl` | |
| `f38_slide` | `stl/06_f38_slides_x2.stl` | |
| `glass_stop` | `stl/07_glass_stops_x2.stl` | |
| `groove_strip` | `stl/08_groove_strips_x2.stl` | |
| `shim_set` | `stl/09_shim_set_print_2x.stl` | |
| `swap_shim` | `stl/10_swap_shim_3mm_riser.stl` | Thickness = difference of the two axis heights (3 mm by default) |
| `hardware_screws` | `stl/11_hardware_screws_solid.stl` | |
| `hardware_nuts` | `stl/12_hardware_nuts_solid.stl` | |
| `preload_screw` | `stl/13_glass_thumbscrews_solid.stl` | |
| `pin_set` | `stl/14_pins_solid.stl` | |
| `wrap_clips` | `stl/15_wrap_clips.stl` | |
| `groove_test`, `thread_test`, `pin_test`, `rail_test` | `stl/tests/<name>.stl` | |
| `frame` | `stl/alternatives/frame_tripod_printed.stl` | `tripod_mount = "printed"` |
| `frame` | `stl/alternatives/frame_tripod_arca.stl` | `tripod_mount = "arca"` |
| `arca_plate` | `stl/alternatives/arca_plate.stl` | `tripod_mount = "arca"` |

Helpers that are not printed:

| `part` | Use |
|---|---|
| `assembly` | The whole rig (default) |
| `splitter_mockup`, `camera_mockups` | Glass and camera stand-ins |
| `insert_check`, `strip_insert_check` | Collision tests: the glass (or a strip) swept along its insertion path. An empty F6 result means it slides in freely. |
| `world` + `world_piece` | One part in its assembled position, for mass and centre-of-gravity scripts |
| `none` | Nothing. Use it to get the console summary quickly. |

`hood` and `hood_hardware` (an optional front light shield) are still in the selector, but they are **not part of this
release**: their fasteners interfere with the shell.

## Measuring your gear

Which cameras and lenses fit, and the key distances, are listed in [CAMERAS.md](CAMERAS.md).

Fill in the **Measure first** group. None of these measurements needs the rig. A few names refer to the default
cameras: `a6400_*` and `ep_15` describe the **rear** camera and lens, and `a5100_*` and `ep_1018` describe the
**bottom** ones.

| Parameter | Default | What to measure | Affects |
|---|---|---|---|
| `ep_15` | 25 | Entrance pupil of the rear lens: distance behind the front rim of the lens (method below) | frame, lid, bottom carriage |
| `ep_1018` | 25 | Entrance pupil of the bottom lens at its working focal length, from the **bare** lens front (not the filter ring) | frame, lid, bottom carriage |
| `filt_od`, `filt_len` | 65, 6 | IR filter ring outer diameter, and how far the filter sticks out beyond the bare lens front (calipers' depth rod). Set both to 0 if you use no filter. | frame, lid, bottom carriage |
| `a6400_meas`, `a5100_meas` | [35, 18, 45], [32, 15, 33] | Per body: [lens axis height above the tripod face, mount flange → tripod socket centre, flange → rear screen (folded flat)] | frame, wall rail, carriages, slides, swap shim |
| `a6400_size`, `a5100_size` | | Body envelope [width, height, depth incl. grip] | clearance checks |
| `lens_15`, `lens_1018` | [66.6, 69.5], [70, 63.5] | Lens [diameter, length from mount to front] | frame, clearance checks |
| `f38_stack` | 17 | F38 plate clicked into the base: base bottom → plate top | frame, wall rail |
| `f38_base` | [54.3, 41.3] | Base footprint [across the camera, along the slide] | carriages, slides |
| `f38_pins`, `f38_pin_d`, `f38_pin_sp`, `f38_pin_depth` | true, 4, 30, 5 | Locating holes under the base: present?, diameter, spacing, depth | slides, pins |
| `f38_thread_depth`, `qtr_screw_len` | 8, 9.5 | Usable 1/4"-20 thread depth in the base; length of your base screw | check only |
| `f38_lever` | [0, 99] | Release lever: [how far it sticks out beyond the base footprint, its lowest point above the base underside] | check only |
| `shim_fp` | [36, 44] | Camera-side footprint of the F38 plate | shims |
| `strip_glass` | [150, 150] | Your glass: [width, length] (see [Glass size](#glass-size)) | groove strips |

**Enter body and stack heights on the high side.** Shims can only move a camera *away* from its mount. If you round up
(calipers: add 0.5 mm to axis heights and 0.3 mm to the F38 stack), any error leaves the camera slightly too close,
and the 0.5 / 1 / 2 mm shims fix it during alignment. The defaults are ruler readings rounded up this way.

**Body roles.** Every mount is sized for the camera with the *higher* lens axis (the `a6400_*` slot, rear by default).
The other body (`a5100_*`, bottom) gets the swap shim, whose thickness is the difference of the two axis heights. Keep
`a6400_meas[0] ≥ a5100_meas[0]`. Swapping the cameras between positions with lenses attached is not validated.

**Why the riser exists.** The reference bodies have different lens-axis heights (a6400 35 mm, a5100 32 mm), so the
lower one needs a 3 mm riser to put both lenses on the same height. With your own cameras:

- **Two identical bodies:** enter the same values in both slots. The swap shim thickness becomes 0: don't print it.
- **Two different bodies:** put the body with the higher lens axis in the `a6400_*` slot. The console summary prints
  the `swap_shim` thickness; export `part = "swap_shim"` and fit it under the other body.
- **Small corrections after printing:** use the 0.5 / 1 / 2 mm shims. Larger height changes, such as a longer bottom
  lens, need new values and a reprint (see `Zs` in [CAMERAS.md](CAMERAS.md#scaling)).

### Finding the entrance pupil (10-minute method)

The entrance pupil is the point a lens "sees" from, also called the no-parallax point. The rig places both cameras'
pupils at the same optical distance from the glass, so this is the most important measurement.

1. Mount the camera on a sliding rail (or a ruler clamped to a tripod pan head) so it can slide along the lens axis
   above the pan axis.
2. Set the working focal length: 15 mm, or the 10–18 mm taped at its 18 mm stop.
3. Line up two thin vertical targets, for example a pole about 0.5 m away in front of a door edge at least 3 m away,
   so the near one hides the far one.
4. Pan so the pair moves from the frame centre to the edge. If they separate, slide the camera along the rail and try
   again. At the no-parallax point they stay together while you pan.
5. Now the pan axis passes through the entrance pupil. Measure from the pan axis to the front rim of the lens (for the
   bottom lens, to the bare lens rim, not the filter). Enter that value. Repeat once: the two readings should agree
   within 2 mm.

Typical values are 20–30 mm. With the default IR filter, the model accepts pupils up to about 27 mm before the groove
lips enter the image. If an assertion trips, see `target_f` below.

## Common changes

### Glass size

Measure your glass and set `strip_glass = [width, length]` (in **Measure first**). Width runs across the rig, and length runs along the
slope. The frame stays the same: re-export and print **only** `08_groove_strips_x2.stl`.

| | Allowed | Why |
|---|---|---|
| Width | 149.6 – 154 mm | Narrower glass could slide sideways off a supporting lip. Wider glass would leave no room for the strip's key step. |
| Length | 145 – 150.8 mm | Shorter glass would put the end stop under a thumbscrew. Longer glass would leave the end cap too thin. |

The glass thickness is assumed to be 2.0 mm (`plate_t`). Small differences are taken up by the felt and the
thumbscrews.

### Common field of view: `target_f`

`target_f = 19` means the clean common frame equals a 19 mm lens on APS-C, in 16:9 (`target_aspect`). The design
places the lenses so that neither one appears in the other's view at this angle. If your pupils are deeper or your
filter is thicker, an assertion trips. In that case, set `target_f = 20` (and `fov_f_rear`, `fov_f_bot` the same) and
re-export the frame, lid and bottom carriage. Without an IR filter (`filt_od = filt_len = 0`), 18 mm works. See
[DESIGN.md](DESIGN.md#why-the-common-frame-is-19-mm) for the reasoning.

### Fits from the test coupons

| Parameter | Default | Coupon |
|---|---|---|
| `ps_clear` | 0.2 | `thread_test`: radial clearance of all printed M10 × 2 and M8 × 2 female threads |
| `unc_clr` | 0.2 | `thread_test`: printed 1/4"-20 threads for steel screws |
| `pin_clr` | 0.2 | `pin_test`: slip-fit pin holes |
| `pin_press` | 0.0 | `pin_test`: press-fit holes for the wall-rail alignment pins |
| `tongue_clear` | 0.2 | `rail_test`: sliding tongues of carriages and slides (per side) |
| `groove_w` | 4.0 | `groove_test`: groove width (deliberately generous) |

[PRINTING.md](PRINTING.md#test-coupons) lists which parts to re-export after each change.

### Modes

| Parameter | Options |
|---|---|
| `tripod_mount` | `"insert"` (default): socket for a 1/4"-20 heat-set insert. `"printed"`: printed 1/4"-20 thread. `"arca"`: printed Arca-Swiss plate on two M10 thumbscrews. `tri_38 = true` makes the insert socket 3/8"-16. |
| `hardware` | `"printed"` (default): printed thumbscrews, nuts and pins. `"steel"`: an alternative build with M4 socket screws, square nuts, Ø4 steel dowels and heat-set inserts (see [HARDWARE.md](HARDWARE.md#steel-hardware-mode)). It uses a fixed groove in the frame instead of the swappable strips. **Steel mode has not been built or tested in this release.** |
| `preload_type` | `"printed"` (default): M10 glass thumbscrews. `"m4"`: M4 nylon screws in captured square nuts. |
| `lcd_window` | `true` (default): a window through the base under the bottom camera, for its screen and buttons. `false`: a closed recess with a 2 mm floor. |
| `bot_serr` | `true` (default): the bottom slide is serrated (2 mm steps, holds the camera weight by its teeth). `false`: smooth, friction only. |
| `frame_split` | A fallback that cuts the rear deck off for smaller printers. It needs two M4 bolts and supports in places. It is not validated. |

## Exporting STLs

From the GUI: set `part`, press **F6**, then **File → Export → Export as STL**.

From a terminal (Linux, macOS or WSL; on Windows, use `openscad.com` from the OpenSCAD folder to see the console):

```sh
openscad -o stl/02_top_lid.stl -D 'part="top_lid"' model/beamsplitter_rig.scad
openscad -o stl/alternatives/frame_tripod_arca.stl -D 'part="frame"' -D 'tripod_mount="arca"' model/beamsplitter_rig.scad
```

Any parameter can be overridden the same way, for example `-D 'strip_glass=[151,149]'`. Each OpenSCAD export prints
the same console summary and runs the same assertions. If an assertion fails, the export stops.
