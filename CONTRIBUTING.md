# Contributing

Thanks for your interest! The most useful contributions right now are:

- **Build reports:** printer, material, what fit and what didn't, photos.
- **Measurements:** entrance pupils, axis heights and F38 dimensions for other cameras and lenses.
- **Image results:** compositing registration, stereo crops and infrared behaviour of the glass and wrap materials.
- **Fixes** to the model, the tools or the docs.

## Issues

Please include the version (see [CHANGELOG.md](CHANGELOG.md)), any parameters you changed, and the console summary or
error message if OpenSCAD is involved.

## Pull requests

1. Change `model/beamsplitter_rig.scad` (the single source), not the STLs.
2. Run the checks in [AGENTS.md](AGENTS.md#checks-before-you-submit). Make sure there are no failed assertions, and
   run the printability audits for any part whose geometry you changed.
3. Re-export only the STLs your change affects, using the names in `stl/`.
4. Update the docs if behaviour, parameters or the parts list changed, and add a line to `CHANGELOG.md`.
5. Describe what you tested. "Printed and fitted" and "CAD only" are both fine, as long as you say which.

Keep comments short and about the current design, not its history. Never include personal data or local file paths.

## License

By contributing you agree that your contribution is licensed under the same terms as the files it changes:
CERN-OHL-S-2.0 for the hardware design and docs, MIT for the scripts in `tools/` (see the [README](README.md#license)).
Please open an issue before starting larger work.
