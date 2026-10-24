#!/usr/bin/env python3
"""Loaded centre of gravity of the rig.  Pure Python, no packages.

Printed parts: their STLs in the ASSEMBLED position (part="world"), mass = cm3 x density x fill.
The printed hardware (world_piece "hardware": thumbscrews, nuts, pins, printed at 100 % infill, fill 1.0) is
included by default (--hardware steel: steel hardware, not counted); --arca adds the printed Arca plate.
Bought parts (cameras, lenses, F38 kits, glass, IR filter): centroids from the .scad echo line "COG_BOUGHT"
(the mock-up volumes as the .scad places them for your measured values), masses from the flags below.

Recipe (run from the repository root; openscad = your OpenSCAD executable, on Windows openscad.com):

  mkdir -p out/world
  for p in frame top_lid wall_rail groove_strip glass_stop preload_screw rear_carriage bottom_carriage f38_slide swap_shim hood hardware; do
      openscad -D 'part="world"' -D "world_piece=\\"$p\\"" -D clip_check=false -o out/world/w_$p.stl model/beamsplitter_rig.scad
  done
  openscad -D 'part="none"' -D clip_check=false -o out/world/cog.echo model/beamsplitter_rig.scad
  python3 tools/cog.py                      # default masses, STLs from out/world/
  python3 tools/cog.py --rear-body 403 --rear-lens 219 --bot-body 283 --bot-lens 225 --f38 52 --glass 112

(--arca: render world_piece "arca_plate" too.)  The STLs only need re-rendering when geometry parameters
change; for new masses just re-run the Python.
"""
import argparse, os, re, struct, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PRINTED = ['frame', 'top_lid', 'wall_rail', 'groove_strip', 'glass_stop', 'preload_screw', 'rear_carriage', 'bottom_carriage', 'f38_slide', 'swap_shim']
PROFILES = {'pla': (1.24, 0.70, 'PLA prototype'), 'petg': (1.27, 0.85, 'PETG final')}   # density g/cm3, fill fraction
SOLID = {'hardware', 'arca_plate', 'preload_screw'}   # printed hardware (incl. the preload thumbscrews): 100 % infill -> fill 1.0


def triangles(path):
    """ASCII or binary STL -> list of (a, b, c) vertex tuples"""
    with open(path, 'rb') as f:
        data = f.read()
    if data[:5] == b'solid' and b'facet' in data[:512]:
        tris, v = [], []
        for line in data.decode('ascii', 'ignore').splitlines():
            s = line.strip()
            if s.startswith('vertex'):
                q = s.split()
                v.append((float(q[1]), float(q[2]), float(q[3])))
                if len(v) == 3:
                    tris.append(tuple(v)); v = []
        return tris
    n = struct.unpack('<I', data[80:84])[0]
    return [tuple(struct.unpack('<3f', data[84 + 50 * i + 12 + 12 * k: 84 + 50 * i + 24 + 12 * k]) for k in range(3))
            for i in range(n)]


def vol_centroid(path):
    V = 0.0; C = [0.0, 0.0, 0.0]
    for a, b, c in triangles(path):
        v = (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0]) + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6.0
        V += v
        for i in range(3): C[i] += v * (a[i] + b[i] + c[i]) / 4.0
    if abs(V) < 1e-9: raise SystemExit(f"{path}: empty or not closed")
    return V, [x / V for x in C]


def need(path):
    if not os.path.exists(path):
        raise SystemExit(f"{path} not found -- render the world STLs + cog.echo first (recipe: python3 tools/cog.py -h)")
    return path


def read_echo(path):
    txt = open(need(path), encoding='utf-8', errors='ignore').read()
    line = next((l for l in txt.splitlines() if 'COG_BOUGHT' in l), None)
    if line is None: raise SystemExit(f"{path}: no COG_BOUGHT line (render it with -D 'part=\"none\"' -o {path})")
    return {k: [float(x) for x in v.split(',')] for k, v in re.findall(r'(\w+) = \[([^\]]+)\]', line)}


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--world', default=os.path.join(ROOT, 'out', 'world'), help='folder with w_<part>.stl (default out/world)')
    ap.add_argument('--echo', default=None, help='echo file with the COG_BOUGHT line (default <world>/cog.echo)')
    ap.add_argument('--rear-body', type=float, default=403, help='g, rear camera body (a6400 403)')
    ap.add_argument('--rear-lens', type=float, default=219, help='g, rear lens (SEL15F14G 219)')
    ap.add_argument('--bot-body', type=float, default=283, help='g, bottom camera body (a5100 283)')
    ap.add_argument('--bot-lens', type=float, default=225, help='g, bottom lens (SEL1018 225)')
    ap.add_argument('--f38', type=float, default=52, help='g, one F38 kit (base + plate)')
    ap.add_argument('--glass', type=float, default=112, help='g, beam splitter plate')
    ap.add_argument('--filter', type=float, default=25, help='g, screw-in IR filter on the bottom lens')
    ap.add_argument('--profile', choices=['pla', 'petg', 'both'], default='both')
    ap.add_argument('--hood', action='store_true', help='include the optional hood (needs w_hood.stl)')
    ap.add_argument('--hardware', choices=['printed', 'steel'], default='printed', help='count the printed hardware (w_hardware.stl)')
    ap.add_argument('--arca', action='store_true', help='include the printed Arca plate + its 2 thumbscrews (w_arca_plate.stl)')
    a = ap.parse_args()
    echo = read_echo(a.echo or os.path.join(a.world, 'cog.echo'))
    bought = [('rear camera body', a.rear_body, echo['rear_body']), ('rear lens', a.rear_lens, echo['rear_lens']),
              ('rear F38 kit', a.f38, echo['rear_f38']), ('bottom camera body', a.bot_body, echo['bot_body']),
              ('bottom lens', a.bot_lens, echo['bot_lens']), ('bottom F38 kit', a.f38, echo['bot_f38']),
              ('glass plate', a.glass, echo['glass'])] + ([('bottom IR filter', a.filter, echo['bot_filter'])] if 'bot_filter' in echo else [])
    parts = PRINTED + (['hood'] if a.hood else []) + (['hardware'] if a.hardware == 'printed' else []) + (['arca_plate'] if a.arca else [])
    rows = []
    for n in parts:
        V, c = vol_centroid(need(os.path.join(a.world, f'w_{n}.stl'))); rows.append((n, V / 1000, c))
    tri = echo.get('tri_xy', [0, 0])
    for prof in (['pla', 'petg'] if a.profile == 'both' else [a.profile]):
        dens, fill, label = PROFILES[prof]
        M = [(f'{n} ({v:.1f} cm3)', v * dens * (1.0 if n in SOLID else fill), c) for n, v, c in rows] + list(bought)
        m = sum(x[1] for x in M)
        cg = [sum(x[1] * x[2][i] for x in M) / m for i in range(3)]
        print(f"\n{label}: g = cm3 x {dens} x {fill}" + ("  (with hood)" if a.hood else ""))
        print("| item | mass g | centroid x / y / z |\n|---|---|---|")
        for n, mm, c in M:
            print(f"| {n} | {mm:.0f} | {c[0]:.1f} / {c[1]:.1f} / {c[2]:.1f} |")
        print(f"| **loaded rig** | **{m:.0f}** | **{cg[0]:.1f} / {cg[1]:.1f} / {cg[2]:.1f}** |")
        dy = tri[1] - cg[1]
        print(f"tripod insert at ({tri[0]:g}, {tri[1]:g}): {abs(dy):.1f} mm {'behind' if dy > 0 else 'in front of'} the CoG, "
              f"{abs(tri[0] - cg[0]):.1f} mm beside it -> static moment on the head {m / 1000 * 9.81 * abs(dy) / 1000:.2f} N m")
