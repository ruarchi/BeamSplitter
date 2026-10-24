#!/usr/bin/env python3
"""Convert an ASCII STL (OpenSCAD's export format) to binary STL.  Standard library only.

Binary STLs are about 5 x smaller and load faster in slicers.  The triangles, their order and
their normals are kept; coordinates are stored as 32-bit floats, as the binary format requires.

Usage:  python3 tools/stl_ascii_to_binary.py part.stl [more.stl ...]   (converts in place)
        python3 tools/stl_ascii_to_binary.py in.stl -o out.stl
Files that are already binary are left alone.
"""
import argparse
import os
import struct
import sys
import tempfile

TRI = struct.Struct('<12fH')


def is_ascii_stl(path):
    size = os.path.getsize(path)
    with open(path, 'rb') as f:
        head = f.read(84)
    if len(head) == 84 and 84 + 50 * struct.unpack('<I', head[80:84])[0] == size:
        return False                      # binary (even if its header starts with "solid")
    return head.lstrip().startswith(b'solid')


def convert(src, dst, name):
    """Write the binary STL of ASCII STL `src` to `dst` (header text `name`); returns the triangle count."""
    header = ('binary STL: ' + name).encode('ascii', 'replace')[:80].ljust(80, b' ')
    count = 0
    normal = (0.0, 0.0, 0.0)
    verts = []
    with open(src, 'r', encoding='ascii', errors='replace') as fin, open(dst, 'wb') as fout:
        fout.write(header)
        fout.write(struct.pack('<I', 0))   # triangle count, filled in at the end
        for line in fin:
            s = line.split()
            if not s:
                continue
            if s[0] == 'facet':
                normal = tuple(float(x) for x in s[2:5])
                verts = []
            elif s[0] == 'vertex':
                verts.extend(float(x) for x in s[1:4])
            elif s[0] == 'endfacet':
                if len(verts) != 9:
                    raise ValueError('%s: facet %d has %d vertices' % (src, count + 1, len(verts) // 3))
                fout.write(TRI.pack(*normal, *verts, 0))
                count += 1
        fout.seek(80)
        fout.write(struct.pack('<I', count))
    return count


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('stl', nargs='+', help='ASCII STL file(s)')
    ap.add_argument('-o', '--output', help='output file (only with a single input; default: convert in place)')
    a = ap.parse_args()
    if a.output and len(a.stl) != 1:
        ap.error('-o needs exactly one input file')
    for src in a.stl:
        if not is_ascii_stl(src):
            print('%s: already binary, skipped' % src)
            continue
        dst = a.output or src
        fd, tmp = tempfile.mkstemp(suffix='.stl', dir=os.path.dirname(os.path.abspath(dst)))
        os.close(fd)
        try:
            umask = os.umask(0)
            os.umask(umask)
            os.chmod(tmp, 0o666 & ~umask)     # normal file permissions, not mkstemp's private ones
            n = convert(src, tmp, os.path.splitext(os.path.basename(dst))[0])
            os.replace(tmp, dst)
        except BaseException:
            os.remove(tmp)
            raise
        print('%s: %d triangles, %.1f MB' % (dst, n, os.path.getsize(dst) / 1e6))


if __name__ == '__main__':
    sys.exit(main())
