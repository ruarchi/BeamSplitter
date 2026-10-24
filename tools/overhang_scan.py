#!/usr/bin/env python3
"""Unsupported-region scan of an STL in its print orientation (bed = lowest z).  Needs numpy.

Slices the mesh every 0.2 mm on a 0.25 mm raster and lists every region of >= 1 mm2 that is not
over material of the layer below (with a one-cell, 45° allowance): overhangs and bridges.  Spans
in the rear deck (y0 > 105, designed bridges) are left out of the list.  Uses islands.py.

Usage:  python tools/overhang_scan.py stl/01_frame.stl
"""
import os, sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from islands import load, section, dilate, components

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    LH, PX = 0.2, 0.25
    m = load(sys.argv[1], PX); mn, mx = m.mn, m.mx
    prev = None; z = LH / 2 + 0.003; regs = []
    while z < mx[2]:
        g = section(m, z)
        if prev is not None and g.any():
            uns = g & ~dilate(prev, 1)
            for cells in components(uns):
                a = np.array(cells); area = len(cells) * PX * PX
                if area < 1.0: continue
                xs = mn[0] + (a[:, 1] + 0.5) * PX; ys_ = mn[1] + (a[:, 0] + 0.5) * PX
                regs.append((round(z, 2), round(area, 1), round(xs.min(), 1), round(xs.max(), 1), round(ys_.min(), 1), round(ys_.max(), 1)))
        prev = g; z += LH
    print('unsupported regions >= 1 mm2 (z, area, x0, x1, y0, y1), excluding rear-deck bridges y0>105:')
    for r in regs:
        if r[4] > 105: continue
        print(r)
