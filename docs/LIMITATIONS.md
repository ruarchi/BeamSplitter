# Known limitations and open items

The rig is a **prototype**. Every part has been printed and the groove strips have been test-fitted in the frame,
but the complete rig has not been tested with cameras, and nothing below has been measured on real hardware. The
model's checks (assertions, collision tests, printability audits) show that the CAD geometry is consistent. They cannot show how well the printed parts fit, hold or repeat, or how good the images
are. Please report what you find (see [CONTRIBUTING.md](../CONTRIBUTING.md)).

## Inputs that are estimates

- **Entrance pupils** (`ep_15`, `ep_1018` = 25 mm) are placeholders. They decide the lens positions and how much
  margin the groove lips have. Measure them before printing a final frame (see
  [CUSTOMIZE.md](CUSTOMIZE.md#finding-the-entrance-pupil-10-minute-method)). With the default filter, the model accepts
  up to about 27 mm.
- **IR filter size, F38 pin holes, F38 thread depth, the release-lever envelope and the tripod-socket offsets** are
  catalogue values or rough measurements.
- **Lens axis heights and F38 stack** are ruler readings, rounded up on purpose. Expect to add 0.5–2 mm of shims
  under each camera.

## Glass and groove

- **Narrow glass can float sideways.** The glass has 1 mm of edge float at each side, and each strip can move 0.3 mm
  outboard before the key ridge stops it. Pushed fully to one side, narrow glass could lose its overlap with the
  opposite lower lip. The model requires a width of **at least 149.6 mm**, which keeps 0.5 mm of overlap in that worst
  case. The default 150 mm glass keeps 0.7 mm. Nothing centres the glass actively.
- **Strip springs depend on the print.** The strips' spring bumps stand 0.35 mm proud of the channel roof. If your
  frame's channel printed more than 0.35 mm taller than drawn, the springs no longer touch the roof. The strip is then
  held only by the glass and the thumbscrews. A strip of tape on the spring bumps restores the grip.
- **Matched strips.** The two strips must have the same thickness, because a 0.1 mm difference rolls the glass by
  about 0.04°. Print them together, and check that both seat flat and fully home.
- **No angle adjustment.** Any error in the printed 45° goes straight into the image as a fixed offset, which you
  measure once and correct in post. If `groove_test` shows more than about 0.3° of error, fix the printer.
- **Thumbscrew boss corners** print with a small cantilever and may droop. Clean them after printing (see
  [PRINTING.md](PRINTING.md#slicer-warnings-you-can-ignore)).

## Optics: still to qualify on real images

- **Stereo crop is a sampled estimate.** The table in [DESIGN.md](DESIGN.md#stereo) traces pinhole rays on a grid. It
  can miss thin losses at the image edges and does not model the real lens. Treat it as a guide, not a guarantee.
- **Finite aperture.** The clearances are computed for a pinhole pupil. A wide-open f/1.4 lens uses up about 1.6 mm of
  the margins at the extreme corner. Stop the 15 mm down to f/2.8 or slower, and check the corners.
- **Plate refraction and ghosting.** The 2 mm glass shifts the transmitted image by about 0.67 mm. The shift varies a
  little with the field angle and the subject distance. An uncoated back face adds a faint ghost of 2–4 %. Neither
  effect has been measured.
- **Near-infrared split ratio.** A "50/50" coating is specified for visible light. Its split in the near-infrared is
  unknown and may favour one camera. Test both positions: the 3 mm riser lets the cameras swap.
- **No hardware sync between the cameras.** Stills can be fired together with a dual-release cable. Video needs a clap
  or flash to sync.
- **Image stabilisation.** Turn OSS off for calibration, and preferably for compositing. A moving stabiliser element
  changes the alignment between the two cameras.
- **Black is not black in infrared.** Black PLA and many black fabrics transmit or reflect near-infrared. Wrap the
  sides with Cinefoil or IR-tested blackout fabric, line the lid with flocking film, and test with the full-spectrum
  camera.
- **Base window.** Light coming up through the window under the bottom camera cannot reach either camera directly:
  the glass sends it out of the front or up into the flocked lid. It still adds stray light inside the rig, which
  lowers contrast. Cover the window in bright light (step 27 of the assembly guide).
- **Lens and body swaps.** Swapping the cameras between positions with lenses attached is not validated. With an a6400
  in the bottom position, its body touches the base at the lowest 5 mm of slide travel in stereo.

## Mechanics: still to qualify on printed parts

- **Pin repeatability.** Printed Ø5 pins in 5.2 mm holes return a carriage to about ±0.1 mm (steel dowels: ±0.03 mm).
  Check the registration each time you return from stereo.
- **Printed threads.** They are strong enough for the loads, but a long lever strips them, so tighten by hand only.
  The horizontal 1/4"-20 threads in the front columns engage only about 75 %, so use them for light accessories only.
  The printed tripod thread is the weakest tripod option: snug it gently.
- **PLA creep.** Under constant load and heat (sun, a hot car), PLA parts and threads relax. Re-snug the thumbscrews,
  and use PETG for a final build.
- **Bottom camera mount flex.** The bottom camera hangs on a plastic cantilever. Its pitch may change by roughly
  0.05–0.1° between level and pointing down. Calibrate in the orientation you will shoot in.
- **Lid off = not structural.** Without the lid, the frame is less stiff and the glass stops are loose. Never load,
  carry or tilt the rig that way.
- **Bed size.** The frame is 244 mm tall and needs a 245 mm build height. Keep its brim at about 5 mm on a 250 mm bed.

## Not part of this release

- **Front hood** (`hood`, `hood_hardware`): its fastener heads and key path interfere with its shell.
- **`frame_split`** (two-piece frame for smaller printers): it needs supports at the cut and has not been validated.
- **Steel hardware mode** (`hardware = "steel"`): not built or tested in this release.
