# Changelog

## v1.0

First release.

- Fixed 45° glass seat in a one-piece open-truss frame, with a bolted lid that acts as the top chord, a light trap and
  a cold-shoe mount.
- Swappable, keyed, spring-loaded groove strips hold the glass. A different glass size (149.6–154 × 145–150.8 mm)
  only needs new strips.
- Visible + infrared compositing from one viewpoint, with a 19 mm (APS-C equivalent) common frame for the default
  cameras.
- Stereo mode: both cameras slide sideways in opposite directions, up to an 85 mm interaxial, and datum pins return
  them to the compositing position.
- F38 quick release on both cameras, with fore-aft slides for matching the viewpoints.
- Printed hardware throughout (M10 × 2 and M8 × 2 threads, T-nuts, thumb-nuts, pins, wrap clips). All printed threads
  are right-handed. Only three 1/4"-20 screws, felt and an optional heat-set insert are bought.
- Support-free print set: STLs 01–15, four test coupons, and three tripod options (heat-set insert, printed thread,
  Arca-Swiss plate). A variant frame for 0.6 mm nozzles is included.
- Window in the base under the bottom camera's screen and buttons.
- Camera and lens guide ([docs/CAMERAS.md](docs/CAMERAS.md)) and an illustrated 29-step assembly guide
  ([docs/ASSEMBLY.md](docs/ASSEMBLY.md)).
- Built-in checks: OpenSCAD assertions with plain-language messages, a console summary, glass and strip insertion
  collision tests, and Python audits for printability and the stereo crop.

For the reasoning behind these choices, see [docs/DESIGN.md](docs/DESIGN.md).
