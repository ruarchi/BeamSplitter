# Cameras, lenses and scaling

This page lists the cameras, lenses and distances the rig was designed for, the range of other gear the model accepts
with a fresh export, and what changes if you want a bigger or smaller rig.

How the ranges were found: each value was entered into the model on its own, from the defaults, and the model's
assertions checked the result. The assertions cover fields of view, lens clearances, stereo travel, printability and
the bed size. **Only the default configuration has been printed.** Everything else is a model check, not a build.

## The reference build

| Position | Camera | Lens | Notes |
|---|---|---|---|
| Rear (transmitted view, looks forward) | Sony a6400 | Sony E 15 mm F1.4 G | Shoot at f/2.8 or slower (see [LIMITATIONS.md](LIMITATIONS.md#optics-still-to-qualify-on-real-images)) |
| Bottom (reflected view, looks up) | Sony a5100, full-spectrum conversion | Sony E 10–18 mm F4 OSS at 18 mm | 62 mm screw-in IR filter (ring Ø65 × 6 mm) |

- **Glass:** 150 × 150 × 2 mm plate beam splitter, 50/50. With reprinted strips, 149.6–154 × 145–150.8 mm also fits.
- **Sensor:** APS-C.
- **Common frame:** 19 mm on APS-C, which is 28.5 mm in full-frame terms, in 16:9 or 3:2.

## Key distances

| What | Value |
|---|---|
| Glass centre above the base underside (`Zs`) | 176 mm |
| Entrance pupil to glass centre (`D`, the same for both cameras) | 69.5 mm |
| Lens front to glass centre | 44.5 mm. The bottom lens's filter front sits 38.5 mm from the glass centre. |
| Closest lens part to the glass | rear 5.9 mm, bottom 4.2 mm (3 mm minimum) |
| Viewpoint-matching travel | rear slide ±20 mm (fore-aft), bottom slide ±11.5 mm (up-down) |
| Stereo travel | rear ±40 mm, bottom ±45 mm: up to 85 mm interaxial |
| Lens axis above the camera's tripod face | rear 35 mm, bottom 32 mm. The 3 mm riser makes up the difference when you swap the bodies. |
| F38 quick-release stack (plate in base) | 17 mm |
| Frame | 208 × 235 × 244 mm, 174 mm wide inside |

The model prints all of these, and many more, in its console summary when you press F5.

## What else fits (with a fresh export)

Measure your gear as described in [CUSTOMIZE.md](CUSTOMIZE.md#measuring-your-gear), enter the values and export. If
something doesn't fit, an assertion says so in plain language. The ranges below change one value at a time, so check
your own combination in the model.

| Item | Accepted range | What stops it beyond that |
|---|---|---|
| Rear lens diameter | up to about 69 mm | The barrel reaches the F38 plate under the camera |
| Rear lens length (mount to front) | 55–120 mm | Shorter: the camera's mount runs into the crosswall area |
| Bottom lens diameter, or its filter ring | up to about 74 mm | The lens must sit further from the glass, and the 19 mm frame no longer fits on the glass |
| Bottom lens length (mount to filter-free front) | 60–65 mm | Shorter: the bottom clamps can't be reached through the front brace. Longer: the camera hits the base. Raise `Zs` for longer lenses (see below). |
| Entrance pupil depth behind the front element | 10–26 mm | Deeper: the pupils end up too far from the glass for a 19 mm frame |
| Camera body height | up to 72 mm | The front X-brace is in the way of the bottom camera |
| Camera body width | at least 125–130 mm | not reached in the tests |
| Common focal length, APS-C | 19 mm and longer | 18 mm and wider no longer fit on 150 mm glass |
| Common focal length, full-frame sensor | 30 mm and longer | 28 mm and wider no longer fit |
| Common focal length, Micro Four Thirds | 14 mm and longer | 12.5 mm and wider no longer fit |

Notes:

- **Both positions take either body.** Because the bodies can swap, the body limits apply to both positions.
- **Full-frame bodies** such as the Sony a7 series are about 96 mm tall, well over the 72 mm limit. They need a scaled
  rig (see below), even though the field of view alone works from 30 mm.
- **Longer focal lengths are always fine.** They simply see less of the glass.
- **Zoom lenses change their entrance pupil with focal length.** Enter the pupil depth at the focal length you will
  use. The viewpoint match holds only at that setting.

## Scaling

**Small changes: same frame size, different gear.** Lenses and bodies within the ranges above only need a fresh
export. Change `target_f` (and `fov_f_rear`, `fov_f_bot`) for a narrower common frame.

**Longer bottom lens.** Raise `Zs`, the glass height. For example, `Zs = 188` takes a 75 mm bottom lens, but the frame
grows to 256 mm tall, which needs a printer with more than 245 mm of height.

**Wider view, bigger glass or full-frame bodies.** A wider common frame needs bigger glass. The widest usable focal
length scales roughly inversely with the glass size. The frame was laid out around 150 mm glass, and several of its
dimensions are absolute values, not derived from the glass size. For a bigger rig, scale these together:

- the glass, strips and channel: `plate_size`, `strip_glass`, `x_ch`, `key_x`
- the frame's width and length: `inner_hw`, `y_front`, `y_back`
- the glass height: `Zs`
- your camera measurements

Then work through the assertions one by one. Expect the frame to outgrow a 250 × 250 × 245 mm bed. `frame_split` cuts
the rear deck off as a separate part, but it is not validated. A scaled rig has not been built.

**Smaller sensors** (Micro Four Thirds, 1-inch) work in the current frame down to the focal lengths in the table, as
long as the bodies fit.
