#!/usr/bin/env python3
"""Bridge / overhang-span audit of an STL in its PRINT orientation (bed = z min).  Needs numpy.

Slices the mesh every LH mm on a 0.4 mm raster.  Per layer, material that is not over material of the
layer below (with a 45° allowance: one raster cell per layer) is UNSUPPORTED.  Each unsupported region is classified:
  island      not connected in the layer to supported material -> starts in mid-air (islands.py reports these too)
  bridge      a cell is BRIDGED if, along X or along Y, its run of unsupported cells ends on supported material at
              BOTH ends; its span = that run length (the shorter of the X / Y runs if both are bounded).  The region's
              span = the largest cell span = the longest straight gap between supports the slicer has to bridge.
  cantilever  cells with no two-sided support in X or Y (e.g. a lip hanging over a slot): reported with the largest
              distance from a supported end (a 90° overhang of that width).
Slivers from rasterising 45° faces (spans / cantilevers < --min mm) are ignored.

Usage:  python tools/bridges.py stl/01_frame.stl [more.stl ...] [--lh 0.3] [--min 1.2] [--list 12]
Output per part: max bridge span, max cantilever, island count, and the largest regions (z, span, x / y extent).
"""
import sys, struct, argparse
import numpy as np

PX = 0.4


def load(path):
    with open(path, 'rb') as f:
        data = f.read()
    if data[:5] == b'solid' and b'facet' in data[:1024]:
        v = [list(map(float, l.split()[1:4])) for l in data.decode('ascii', 'ignore').splitlines() if l.strip().startswith('vertex')]
        return np.array(v, float).reshape(-1, 3, 3)
    n = struct.unpack('<I', data[80:84])[0]
    a = np.frombuffer(data[84:84 + 50 * n], dtype=np.dtype([('n', '<3f4'), ('v', '<9f4'), ('a', '<u2')]))
    return a['v'].astype(float).reshape(-1, 3, 3)


class Slicer:
    def __init__(self, T):
        self.T = T
        self.mn = T.reshape(-1, 3).min(0); self.mx = T.reshape(-1, 3).max(0)
        self.nx = int((self.mx[0] - self.mn[0]) / PX) + 3; self.ny = int((self.mx[1] - self.mn[1]) / PX) + 3
        self.ys = self.mn[1] + (np.arange(self.ny) + 0.5) * PX
        self.zmin = T[:, :, 2].min(1); self.zmax = T[:, :, 2].max(1)

    def section(self, z):
        t = self.T[(self.zmin < z) & (self.zmax > z)]
        grid = np.zeros((self.ny, self.nx), bool)
        if len(t) == 0: return grid
        segs = []
        for a, b in ((0, 1), (1, 2), (2, 0)):
            za, zb = t[:, a, 2], t[:, b, 2]
            m = (za < z) != (zb < z)
            u = np.where(m, (z - za) / np.where(m, zb - za, 1), 0)
            p = t[:, a, :2] + u[:, None] * (t[:, b, :2] - t[:, a, :2])
            segs.append((m, p))
        # each crossing triangle has exactly two crossing edges -> one segment
        P = np.stack([s[1] for s in segs], 1); M = np.stack([s[0] for s in segs], 1)
        ok = M.sum(1) == 2
        P, M = P[ok], M[ok]
        idx = np.argsort(~M, axis=1, kind='stable')[:, :2]
        S = np.take_along_axis(P, idx[:, :, None], 1)          # (m, 2, 2)
        x0, y0, x1, y1 = S[:, 0, 0], S[:, 0, 1], S[:, 1, 0], S[:, 1, 1]
        for j, yv in enumerate(self.ys):
            c = (y0 < yv) != (y1 < yv)
            if not c.any(): continue
            xs = np.sort(x0[c] + (yv - y0[c]) * (x1[c] - x0[c]) / (y1[c] - y0[c]))
            for k in range(0, len(xs) - 1, 2):
                i0 = int(np.ceil((xs[k] - self.mn[0]) / PX - 0.5)); i1 = int(np.floor((xs[k + 1] - self.mn[0]) / PX - 0.5))
                if i1 >= i0: grid[j, i0:i1 + 1] = True
        return grid


def dilate(g, r):
    out = g.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx or dy: out |= np.roll(np.roll(g, dy, 0), dx, 1)
    return out


def runs_1d(U, S):
    """along axis 1: for every U cell, (run length in cells, bounded-by-S-at-both-ends, dist to an S end or inf)"""
    ny, nx = U.shape
    L = np.zeros(U.shape); B = np.zeros(U.shape, bool); C = np.full(U.shape, np.inf)
    pad = np.zeros((ny, 1), bool)
    Up = np.concatenate([pad, U, pad], 1).astype(np.int8)
    d = np.diff(Up, axis=1)
    for j in np.nonzero(U.any(1))[0]:
        st = np.nonzero(d[j] == 1)[0]; en = np.nonzero(d[j] == -1)[0]      # run = [st, en)
        for a, b in zip(st, en):
            ls = a - 1 >= 0 and S[j, a - 1]; rs = b < nx and S[j, b]
            L[j, a:b] = b - a; B[j, a:b] = ls and rs
            k = np.arange(a, b)
            if ls: C[j, a:b] = np.minimum(C[j, a:b], k - a + 1)
            if rs: C[j, a:b] = np.minimum(C[j, a:b], b - k)
    return L, B, C


def components(mask):
    lab = np.zeros(mask.shape, int); n = 0
    for j, i in zip(*np.nonzero(mask)):
        if lab[j, i]: continue
        n += 1; st = [(j, i)]; lab[j, i] = n
        while st:
            a, b = st.pop()
            for c, d in ((a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1)):
                if 0 <= c < mask.shape[0] and 0 <= d < mask.shape[1] and mask[c, d] and not lab[c, d]:
                    lab[c, d] = n; st.append((c, d))
    return lab, n


def audit(path, lh=0.3, mn_span=1.2, nlist=12):
    sl = Slicer(load(path))
    regions = []   # (kind, z, span_mm, cant_mm, area_mm2, x0, x1, y0, y1)
    prev = None; z = lh / 2
    while z < sl.mx[2]:
        g = sl.section(z)
        if prev is not None and g.any():
            sup = dilate(prev, 1)
            U = g & ~sup; S = g & sup
            if U.any():
                Lx, Bx, Cx = runs_1d(U, S)
                Ly, By, Cy = runs_1d(U.T, S.T); Ly, By, Cy = Ly.T, By.T, Cy.T
                span = np.minimum(np.where(Bx, Lx, np.inf), np.where(By, Ly, np.inf))   # cells
                cant = np.minimum(Cx, Cy)
                lab, n = components(U)
                touch = dilate(S, 1)
                for k in range(1, n + 1):
                    m = lab == k
                    jj, ii = np.nonzero(m)
                    ext = (sl.mn[0] + ii.min() * PX, sl.mn[0] + (ii.max() + 1) * PX, sl.mn[1] + jj.min() * PX, sl.mn[1] + (jj.max() + 1) * PX)
                    if not (touch & m).any():
                        regions.append(('island', z, 0, 0, m.sum() * PX * PX) + ext); continue
                    sp = span[m]; bs = sp[np.isfinite(sp)]
                    s_mm = (bs.max() + 1) * PX if len(bs) else 0.0          # +1: gap between the two support cells' centres
                    cc = cant[m & ~np.isfinite(span)]
                    c_mm = (cc[np.isfinite(cc)].max() if np.isfinite(cc).any() else 0.0) * PX
                    if s_mm >= mn_span or c_mm >= mn_span:
                        regions.append(('bridge' if s_mm >= c_mm else 'cantilever', z, s_mm, c_mm, m.sum() * PX * PX) + ext)
        prev = g; z += lh
    br = [r for r in regions if r[0] != 'island']
    isl = [r for r in regions if r[0] == 'island']
    mb = max([r[2] for r in br] + [0]); mc = max([r[3] for r in br] + [0])
    print(f"== {path.replace(chr(92), '/').split('/')[-1]}: bbox {np.round(sl.mx - sl.mn, 1)}  layers {int(sl.mx[2] / lh)}")
    print(f"   MAX BRIDGE SPAN {mb:.1f} mm   max cantilever {mc:.1f} mm   islands {len(isl)}   regions >= {mn_span} mm: {len(br)}")
    # merge consecutive layers of the same feature for the listing: group by rounded extents
    seen = {}
    for r in sorted(br, key=lambda r: -max(r[2], r[3])):
        key = (r[0], round(r[5] / 4), round(r[6] / 4), round(r[7] / 4), round(r[8] / 4))
        if key in seen: continue
        seen[key] = r
    for r in list(seen.values())[:nlist]:
        print(f"   {r[0]:10s} z {r[1]:7.2f}  span {r[2]:5.1f}  cantilever {r[3]:4.1f}  area {r[4]:7.1f} mm2  x {r[5]:7.1f}..{r[6]:7.1f}  y {r[7]:7.1f}..{r[8]:7.1f}")
    for r in isl[:10]:
        print(f"   ISLAND     z {r[1]:7.2f}  area {r[4]:.1f} mm2  x {r[5]:.1f}..{r[6]:.1f}  y {r[7]:.1f}..{r[8]:.1f}")
    return mb, mc, len(isl)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('stl', nargs='+'); ap.add_argument('--lh', type=float, default=0.3)
    ap.add_argument('--min', type=float, default=1.2); ap.add_argument('--list', type=int, default=12)
    a = ap.parse_args()
    for p in a.stl:
        audit(p, a.lh, a.min, a.list)
