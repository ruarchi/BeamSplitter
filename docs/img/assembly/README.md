# Assembly-guide pictures

The pictures `NN_name.png` in this folder illustrate the steps of [docs/ASSEMBLY.md](../../ASSEMBLY.md). Step NN of
the guide uses picture NN. They are generated from the model, so don't edit them by hand: change the scene and
render again.

## How they are made

- Each picture has a scene file of the same name in [`tools/assembly/`](../../../tools/assembly/), for example
  `tools/assembly/16_strips_in.scad` for `16_strips_in.png`.
- Every scene includes `tools/assembly/scene_lib.scad`, which includes `model/beamsplitter_rig.scad` and places the
  model's own parts at their assembled positions. It also holds the shared colours, arrows, labels, cut-aways and
  simple stand-ins for the bought parts (felt, F38 parts, steel screws, foil, paper clip). Nothing in it changes the
  model.
- Some scenes also include `tools/assembly/screen_labels.scad`, which places labels by image pixel so the model can't
  hide them.
- The pictures are OpenSCAD previews (F5 colours), 1400 × 1050 pixels, with the `Tomorrow` colour scheme.

## Regenerating them

From the repository root:

```sh
tools/assembly/render_assembly.sh                                   # all pictures, a few seconds to a minute each
OPENSCAD=/path/to/openscad tools/assembly/render_assembly.sh        # OpenSCAD not on the PATH
```

On WSL, a Windows OpenSCAD works too: point `OPENSCAD` at the `openscad.com` in its install folder, and the script
hands it Windows paths.

To render one picture, copy the options from its line in the script (picture 02 also uses `--projection=ortho`):

```sh
openscad -o docs/img/assembly/16_strips_in.png --preview --imgsize=1400,1050 --colorscheme=Tomorrow \
         --camera=80,-62,230,58,0,292,340 tools/assembly/16_strips_in.scad
```

The `--camera` value must match the camera noted at the top of the scene file, because the scene places its labels
for that view. If you change one, change both.

Re-render after changing the model's geometry or defaults, then look at each picture and check that it still matches
the text of its step.

## Colours

| Colour | Meaning |
|---|---|
| Dark grey | The frame |
| Light grey | Parts fitted in earlier steps |
| Orange | The part fitted in this step |
| Blue | A second new part in the same step |
| Red | Arrows |
| Green | Felt (a stand-in colour; real felt is usually black) |
| Pale blue / yellow | The glass / its coated face |
| Dark red | F38 quick-release base and plate (bought) |
