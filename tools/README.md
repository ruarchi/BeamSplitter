# Tools

Helper scripts for exporting the print files and checking the model. You only need them if you change the model.
For a default build, just print the files in [`../stl/`](../stl/).

Run everything from the repository root. The Python checks need Python 3 and numpy (`pip install numpy`), except
`stl_ascii_to_binary.py` and `cog.py`, which need only the standard library. The shell scripts need bash (Linux,
macOS, or WSL / Git Bash on Windows) and [OpenSCAD](https://openscad.org/) 2021.01 or newer.

## Export and pictures

| Script | What it does |
|---|---|
| `export_all.sh` | Exports the complete print set (`stl/`, `stl/tests/`, `stl/alternatives/`) from `model/beamsplitter_rig.scad`, four parts at a time, and converts each file to binary STL. Takes about 10–20 minutes; the three frames are the slow ones. Logs go to `out/logs/`. |
| `stl_ascii_to_binary.py` | Converts ASCII STL (what OpenSCAD writes) to binary STL, which is about 5× smaller. Converts in place; files that are already binary are skipped. |
| `render_images.sh` | Renders the pictures in `docs/img/` (OpenSCAD preview, 1600 × 1200). |
| `groove_section.scad` | The exact cross-section of the glass groove used for `docs/img/groove_section.png`. Open it in OpenSCAD and press F5 to see the section for your own parameters. |
| `print_set.scad` | Lays out the exported STLs for `docs/img/print_set.png`. |
| `assembly/render_assembly.sh` | Renders the assembly-guide pictures in `docs/img/assembly/` from the scenes in `assembly/` (see [`docs/img/assembly/README.md`](../docs/img/assembly/README.md)). |

```sh
tools/export_all.sh                              # default parameters
tools/export_all.sh -D 'ps_clear=0.3'            # any extra OpenSCAD arguments apply to every part
OPENSCAD=/path/to/openscad tools/export_all.sh   # OpenSCAD not on the PATH (on WSL: openscad.com)
JOBS=2 tools/export_all.sh                       # fewer parallel renders on a small machine
python3 tools/stl_ascii_to_binary.py my_part.stl
tools/render_images.sh
```

Both shell scripts read the OpenSCAD path from the `OPENSCAD` variable (default `openscad`). It is also set at the
top of each script. A Windows OpenSCAD (`.exe` / `.com`) called from WSL is handed Windows paths automatically.

## Printability checks

All three read ASCII or binary STL in print orientation, exactly as exported.

| Script | What it checks | Usage | Pass |
|---|---|---|---|
| `islands.py` | Regions that would start in mid-air (nothing below them in the previous layer, with a 45° allowance) | `python3 tools/islands.py stl/01_frame.stl 0.2 0.25 1` (layer height, raster, allowance in cells) | `floating island starts: 0`. Also try layer height 0.21 to rule out slicing-plane coincidences. |
| `bridges.py` | Bridge spans and cantilevers per layer | `python3 tools/bridges.py stl/01_frame.stl [more.stl ...]` | Frame bridges up to about 19 mm, no islands |
| `overhang_scan.py` | Every unsupported region of 1 mm² or more (uses `islands.py`) | `python3 tools/overhang_scan.py stl/01_frame.stl` | Only the known spots listed in [PRINTING.md](../docs/PRINTING.md#slicer-warnings-you-can-ignore) |

## Design checks

| Script | What it does | Usage |
|---|---|---|
| `stereo_clip.py` | Independent cross-check of the model's stereo clipping readout: how much of each camera's image is clipped at each stereo split, and the largest clean crop. Its parameters are a copy of the model defaults, so keep them in step if you change the optics. | `python3 tools/stereo_clip.py --grid 256x144` (about 2 minutes), or `--point 20,20` for one setting |
| `cog.py` | Centre of gravity of the loaded rig (printed parts from `part="world"` exports plus the cameras, lenses and glass), to check that the tripod socket sits close to it | The recipe is at the top of the file; `python3 tools/cog.py -h` lists the mass options |
