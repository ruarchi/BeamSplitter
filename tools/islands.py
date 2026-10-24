#!/usr/bin/env python3
"""Floating-island check for an STL in its print orientation (bed = lowest z).  Needs numpy.

Slices the mesh every LH mm on a PX mm raster.  A region of a layer that touches nothing in the
layer below (grown by DIL raster cells, a 45° allowance) would start in mid-air in the slicer:
each such island start is listed.  Reads ASCII or binary STL.

Usage:  python tools/islands.py stl/01_frame.stl 0.2 0.25 1
        (STL file, layer height LH mm, raster PX mm, dilation DIL cells)

overhang_scan.py imports load(), section(), dilate() and components() from here.
"""
import struct
import sys
from collections import deque
import numpy as np


def read_stl(path):
    """triangles of an ASCII or binary STL as an (n, 3, 3) array"""
    with open(path, 'rb') as f:
        data = f.read()
    n = struct.unpack('<I', data[80:84])[0] if len(data) >= 84 else -1
    if len(data) != 84 + 50 * n:                # not binary -> ASCII
        v = [s.split()[1:4] for s in data.decode('ascii', 'ignore').splitlines() if s.lstrip().startswith('vertex')]
        return np.array(v, float).reshape(-1, 3, 3)
    a = np.frombuffer(data, dtype=np.dtype([('n', '<3f4'), ('v', '<9f4'), ('a', '<u2')]), count=n, offset=84)
    return a['v'].astype(float).reshape(-1, 3, 3)


class Mesh:
    """STL triangles and the raster they are sliced on."""
    def __init__(self, path, PX):
        T = read_stl(path)                      # (n,3,3)
        self.T = T; self.PX = PX
        self.mn = T.reshape(-1, 3).min(0); self.mx = T.reshape(-1, 3).max(0)
        self.nx = int((self.mx[0] - self.mn[0]) / PX) + 3; self.ny = int((self.mx[1] - self.mn[1]) / PX) + 3
        self.ys = self.mn[1] + (np.arange(self.ny) + 0.5) * PX
        self.zmin = T[:, :, 2].min(1); self.zmax = T[:, :, 2].max(1)


def load(path, PX):
    return Mesh(path, PX)


def section(m, z):
    """filled cross-section of mesh m at height z, as a boolean (ny, nx) raster"""
    PX, mn = m.PX, m.mn
    sel = (m.zmin < z) & (m.zmax > z); t = m.T[sel]
    segs = []
    for tri in t:
        pts = []
        for a, b in ((0, 1), (1, 2), (2, 0)):
            za, zb = tri[a, 2], tri[b, 2]
            if (za < z) != (zb < z):
                u = (z - za) / (zb - za); pts.append(tri[a, :2] + u * (tri[b, :2] - tri[a, :2]))
        if len(pts) == 2: segs.append(pts)
    grid = np.zeros((m.ny, m.nx), bool)
    if not segs: return grid
    S = np.array(segs)   # (m,2,2)
    x0, y0, x1, y1 = S[:, 0, 0], S[:, 0, 1], S[:, 1, 0], S[:, 1, 1]
    for j, yv in enumerate(m.ys):
        c = (y0 < yv) != (y1 < yv)
        if not c.any(): continue
        xs = np.sort(x0[c] + (yv - y0[c]) * (x1[c] - x0[c]) / (y1[c] - y0[c]))
        for k in range(0, len(xs) - 1, 2):
            i0 = int(np.ceil((xs[k] - mn[0]) / PX - 0.5)); i1 = int(np.floor((xs[k + 1] - mn[0]) / PX - 0.5))
            if i1 >= i0: grid[j, i0:i1 + 1] = True
    return grid


def dilate(g, r):
    out = g.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            out |= np.roll(np.roll(g, dy, 0), dx, 1)
    return out


def components(g):
    """4-connected regions of a boolean raster, as lists of (row, col) cells"""
    lab = np.zeros(g.shape, int); n = 0; comps = []
    for j, i in zip(*np.nonzero(g)):
        if lab[j, i]: continue
        n += 1; q = deque([(j, i)]); lab[j, i] = n; cells = []
        while q:
            a, b = q.popleft(); cells.append((a, b))
            for da, db in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c, d = a + da, b + db
                if 0 <= c < g.shape[0] and 0 <= d < g.shape[1] and g[c, d] and not lab[c, d]:
                    lab[c, d] = n; q.append((c, d))
        comps.append(cells)
    return comps


def islands(m, LH, DIL):
    """[(z, area mm2, x, y)] of every region that starts without support in the layer below"""
    PX, mn = m.PX, m.mn
    prev = None; z = LH / 2; found = []
    r = DIL
    while z < m.mx[2]:
        g = section(m, z)
        if prev is not None and g.any():
            sup = dilate(prev, r) if r > 0 else prev
            for cells in components(g):
                if not any(sup[a, b] for a, b in cells):
                    a = np.array(cells); area = len(cells) * PX * PX
                    cx = mn[0] + (a[:, 1].mean() + 0.5) * PX; cy = mn[1] + (a[:, 0].mean() + 0.5) * PX
                    found.append((round(z, 2), round(area, 1), round(cx, 1), round(cy, 1)))
        prev = g; z += LH
    return found


if __name__ == '__main__':
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    path = sys.argv[1]; LH = float(sys.argv[2]); PX = float(sys.argv[3]); DIL = int(sys.argv[4])
    m = load(path, PX)
    found = islands(m, LH, DIL)
    print('bbox', m.mn.round(1), m.mx.round(1), 'layers', int(m.mx[2] / LH))
    print('floating island starts (z, area mm2, x, y):', len(found))
    for f in found[:60]: print(f)
