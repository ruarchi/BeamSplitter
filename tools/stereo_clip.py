#!/usr/bin/env python3
"""Stereo clipping table for the beam-splitter rig.

Independent re-implementation of the OpenSCAD echo readout (`clip_check` in
beamsplitter_rig.scad): same parameters, geometry rebuilt here from them.
Differences on purpose (so it is a real cross-check): groove / rib / boss solids
are tested in plate-local coordinates (ray transformed, not the solids), and the
lens barrels, thumbscrew heads, shanks and felt discs are exact cylinders (the
.scad uses circumscribed 16-gons).

The bottom lens wears a screw-in IR filter (filt_od x filt_len beyond the bare front; ep_1018 is from the bare
front): it enters the bottom g_min (glass clearance + mutual visibility) and is an obstacle for the rear camera's rays;
D is per camera (max(g, g_min_x) + ep_x).  Keep the parameters below in step with the .scad.

Pinhole rays over a grid of the target frame (target_f, 16:9) from each pupil:
rear = transmitted (looks -Y), bottom = reflected by the coated face (looks +Z).
Every pixel carries two views:
  SCENE legs   pupil -> plate -> out of the front.  Clipped if the ray meets the plate
               outside the clear aperture (+-73) or crosses any modelled obstruction.
               WRAPPED rig: also clipped if the clean scene leg leaves through the side
               plane (it hits the wrap on the outer face x = +-95) before the front face.
  LID-VIEW leg from the coated-face point P straight up, direction (u th, -s tv, 1), for
               both cameras (rear: 50 % reflection, bottom: 50 % transmission).  First hit:
               'lid' (flocked underside, clean), 'part' (flank, boss, thumbscrew head,
               stop, post, rear lens: imaged at 50 %), 'outside' (misses the lid: sees
               the world through the open truss).
Crops (largest centred crop, same aspect, clean in both images):
  wrapped   = scene legs + wrap                  (the side wrap is on)
  unwrapped = scene legs | lid part | lid outside (open sides)

Usage:  python tools/stereo_clip.py [--grid 64x36] [--f 19] [--ep15 25] [--ep1018 25] [--filt 65,6] [--hood] [--hardware printed|steel]
        [--splits 0,20,40,60,80] [--point SR,SB] [--detail] [--head-nominal]
        (split interaxial i: rear +i/2, bottom -i/2; --point = one setting like -D stereo_rear/stereo_bot)
"""
import math, argparse

s2 = math.sqrt(2)
# Parameters (mirror of the .scad defaults)
P = dict(Zs=176.0, g=41.5, ep15=25.0, ep1018=25.0, f=19.0, filt_od=65.0, filt_len=6.0, sensor_w=23.5, sensor_h=13.22,
         R15=66.6 / 2, L15=69.5, R1018=70.0 / 2, L1018=63.5, plate=150.0, plate_t=2.0, engage=2.0,
         rim_margin=3.0, plate_clear_min=3.0,
         groove_w=4.0, felt_t=0.5, edge_float=1.0, lip_proud=1.5, lip_flat=1.5, bevel_k=1.6, ul_off=1.0,
         back_flank=3.5, end_pad=1.0, stop_gap=0.5, end_t=5.0, stop_len=8.0, stop_x0=71.0, stop_w=(-6.0, 2.7),
         preload_v=(-18.0, 20.0, 65.0), x_pl=74.0, ps_d=10.0, ps_clear=0.2, ps_wall=3.0, ps_head=(17.0, 6.0), boss_h=10.0,
         head_tight=0.7,     # head also 0.7 lower (screw turned in until the tip is on the glass)
         wall_t=8.0, inner_hw=87.0, base_t=6.0, y_front=-65.0, y_back=170.0, y_zone_end=65.0, col_w=15.0, col_d=16.0,
         lid_clear=3.0, lid_t=5.0, lid_rib_h=6.0, rp_y=(51.0, 65.0), rp_x0=85.0, diag_w_lo=(-7.0, 5.0),
         aperture_margin=3.0, hood_len=25.0, hood_wall=2.0,
         brace_w=5.0, brace_t=6.0,
         cam_a6400_axis=35.0, f38_stack=17.0, t_slide=6.0, t_rear_carriage=6.0, bc_t=6.0, cam_r_sock=18.0,
         rear_travel=40.0, rc_width=60.0, rail_band_d=13.0, cw_depth=21.0, wr_z=70.0,   # cw_depth = wall_rail 12 + band 9
         wr_off=9.0, dowel_hole=3.8, hardware='printed', ear_t=4.0, lid_sl=20.0, ps_pitch=2.0, front_margin=2.0)
# hardware = "printed" (default): deeper rail band / thicker wall_rail + band, pin holes 5.2 on rows +-11, post-top
# thread pads + the glass_stop ear (lid thumbscrews); hardware = "steel" = the values above
PRINTED = dict(rail_band_d=15.0, cw_depth=27.0, wr_off=11.0, dowel_hole=5.2)


def derive(p):
    d = dict(p)
    th = p['sensor_w'] / 2 / p['f']; tv = p['sensor_h'] / 2 / p['f']
    def gmin(R, ep, extra):
        return max(R + (p['plate_clear_min'] + extra) * s2, (p['rim_margin'] + tv * (ep + R)) / (1 - tv))
    Rf, fl = p['filt_od'] / 2, p['filt_len']
    g_min_rear = gmin(p['R15'], p['ep15'], p['plate_t'])
    g_min_bot = max(gmin(p['R1018'], p['ep1018'], 0),
                    fl + max(Rf + p['plate_clear_min'] * s2, (p['rim_margin'] + tv * (fl + p['ep1018'] + Rf)) / (1 - tv)))
    D = max(max(p['g'], g_min_rear) + p['ep15'], max(p['g'], g_min_bot) + p['ep1018'])
    d.update(th=th, tv=tv, D=D, g_rear=D - p['ep15'], g_bot=D - p['ep1018'], h_plate=p['plate'] / 2 - p['engage'])
    x_lip = p['plate'] / 2 - p['engage']
    x_ul = x_lip + p['ul_off'] + max(0, p['groove_w'] - 3.2) / 2
    w_lo = -p['felt_t']; w_hi = w_lo + p['groove_w']; w_back = w_hi + p['back_flank']; w_fl = -p['lip_proud']
    x_rw = p['inner_hw'] + 1
    w_front = lambda x: w_fl if x <= x_lip + p['lip_flat'] else w_fl - (x - x_lip - p['lip_flat']) / p['bevel_k']
    v_es = p['plate'] / 2 + p['end_pad']; v_bot = v_es + p['end_t']; v_top = -(p['plate'] / 2 + p['end_pad'] + p['stop_gap'])
    boss_r = p['ps_d'] / 2 + p['ps_clear'] + p['ps_wall']
    d.update(x_lip=x_lip, x_ul=x_ul, w_lo=w_lo, w_hi=w_hi, w_back=w_back, w_fl=w_fl, x_rw=x_rw, x_gb=p['plate'] / 2 + p['edge_float'],
             w_front_rw=w_front(x_rw), v_es=v_es, v_bot=v_bot, v_top=v_top, boss_x0=p['x_pl'] - boss_r, boss_l=2 * boss_r,
             diag_w_up=(w_front(x_rw) - 0.6, w_back), wall_out=p['inner_hw'] + p['wall_t'],
             diag_w_lo=(min(p['diag_w_lo'][0], w_front(x_rw) - 0.6), p['diag_w_lo'][1]))   # continuous underside
    pz = lambda v, w: (w - v) / s2
    top_rel = max([pz(-p['plate'] / 2, p['plate_t']), pz(v_top, w_back), pz(v_top - p['stop_len'], p['stop_w'][1])] +
                  [pz(q - boss_r, w_hi + p['boss_h']) for q in p['preload_v']])
    d['frame_top'] = math.ceil(p['Zs'] + top_rel + p['lid_clear'])
    x_front_in = max(p['inner_hw'], (D - p['y_front']) * th + p['aperture_margin'])
    d.update(x_front_in=x_front_in, y_flare=min(-30, D - (p['inner_hw'] - p['aperture_margin']) / th), x_col_out=x_front_in + p['col_w'])
    d['brace_x'] = p['inner_hw'] + 2
    d['brace_y1'] = p['y_front'] + p['col_d']; d['brace_y0'] = d['brace_y1'] - p['brace_t']
    d['brace_top'] = p['base_t'] + d['brace_x'] + p['brace_w'] / s2
    d['y_wf'] = p['cam_a6400_axis'] + p['f38_stack'] + p['t_slide'] + p['bc_t']
    d['cw_top'] = p['wr_z'] + p['wr_off'] + p['dowel_hole'] / 2 + 2 + 7   # = bc_z1 + 7 (scad: wall top)
    d['deck_top'] = p['Zs'] - p['cam_a6400_axis'] - p['f38_stack'] - p['t_slide'] - p['t_rear_carriage']
    y_rrail = p['g'] + p['rear_travel'] / 4 + p['L15'] + p['cam_r_sock']
    d['deck_y0'] = y_rrail - p['rc_width'] / 2
    d['y_rear_front'] = d['g_rear']; d['y_rear_mount'] = d['g_rear'] + p['L15']
    d['z_bot_front'] = p['Zs'] - d['g_bot']; d['z_bot_mount'] = d['z_bot_front'] - p['L1018']
    d['z_bot_filt'] = d['z_bot_front'] + p['filt_len']
    d['y_far'] = p['y_front'] - p['hood_len'] - 20
    d['head_w'] = (w_hi + p['boss_h'] + 2 - p['head_tight'], w_hi + p['boss_h'] + 2 + p['ps_head'][1])
    # printed hardware: post-top pads (front: behind the column, 45° underside; rear: widened rear post top) + glass_stop ear
    if p['hardware'] == 'printed':
        thr_r = p['ps_d'] / 2 + p['ps_clear']
        fp_top = d['frame_top'] - p['ear_t']; fp_x0 = p['inner_hw']; fp_x1 = d['x_col_out'] + 2
        fb = (d['y_front'] if 'y_front' in d else p['y_front']) + p['col_d'] + 7          # front thumbscrew y
        rb = p['y_zone_end'] - 8
        thr_f = p['lid_sl'] - p['lid_t'] - p['ear_t'] + 2; thr_r_ = p['lid_sl'] - p['lid_t'] + 2
        rbx = (p['rp_x0'] + d['x_col_out']) / 2
        d.update(fp_top=fp_top, fp_x0=fp_x0, fp_x1=fp_x1, lid_hw=fp_x1, fp_y1=fb + thr_r + 3,
                 fp_z0=fp_top - thr_f - 0.5 - 2 - (fb + thr_r - (p['y_front'] + p['col_d'])),
                 rp_py0=rb - thr_r - 3,
                 rpz0=d['frame_top'] - thr_r_ - 0.5 - 2 - max(0, rbx + thr_r - d['wall_out'], p['rp_y'][0] - (rb - thr_r)),
                 stop_clip_y=p['y_front'] + p['front_margin'])
        d['sear_y1'] = d['stop_clip_y'] + 11
    return d


class Planes:
    """Convex solid n.p <= c, in world coords or (local=True) plate-local (x, v, w) coords."""
    def __init__(self, H, local=False, name=''): self.H, self.local, self.name = H, local, name


def box(lo, hi, local=False, name=''):
    return Planes([((1, 0, 0), hi[0]), ((-1, 0, 0), -lo[0]), ((0, 1, 0), hi[1]), ((0, -1, 0), -lo[1]),
                   ((0, 0, 1), hi[2]), ((0, 0, -1), -lo[2])], local, name)


def poly_xw(pts, v0, v1, sx, name=''):
    """convex CCW polygon in plate-local (x, w), over v0..v1; sx=-1 -> mirrored to -X"""
    H = []
    for i in range(len(pts)):
        (px, pw), (qx, qw) = pts[i], pts[(i + 1) % len(pts)]
        nx, nw = qw - pw, px - qx
        H.append(((sx * nx, 0, nw), nx * px + nw * pw))
    H += [((0, 1, 0), v1), ((0, -1, 0), -v0)]
    return Planes(H, True, name)


def poly_xy(pts, z0, z1, sx, name=''):
    H = []
    for i in range(len(pts)):
        (px, py), (qx, qy) = pts[i], pts[(i + 1) % len(pts)]
        nx, ny = qy - py, px - qx
        H.append(((sx * nx, ny, 0), nx * px + ny * py))
    return Planes(H + [((0, 0, 1), z1), ((0, 0, -1), -z0)], False, name)


class Cyl:
    """exact cylinder, axis 'y' through (x0, z0) or 'z' through (x0, y0), extent a0..a1;
    local=True: plate-local, axis along w through (x, v) = (c0, c1) (thumbscrew heads, shanks)"""
    def __init__(self, axis, c0, c1, R, a0, a1, local=False, name=''):
        self.axis, self.c0, self.c1, self.R, self.a0, self.a1, self.local, self.name = axis, c0, c1, R, a0, a1, local, name


def to_local(p, d, Zs):
    return (p[0], (p[1] - p[2] + Zs) / s2, (p[1] + p[2] - Zs) / s2), (d[0], (d[1] - d[2]) / s2, (d[1] + d[2]) / s2)


def entry(o, dvec, t0, t1, S, Zs):
    """entry parameter of the segment o + t dvec (t0..t1) into solid S, or None"""
    if S.local:
        o, dvec = to_local(o, dvec, Zs)
    if isinstance(S, Cyl):
        ia, (ib, ic) = (1, (0, 2)) if S.axis == 'y' else (2, (0, 1))    # local cylinders use axis 'z' = w
        if abs(dvec[ia]) < 1e-12:
            if not (S.a0 <= o[ia] <= S.a1): return None
        else:
            ta, tb = sorted(((S.a0 - o[ia]) / dvec[ia], (S.a1 - o[ia]) / dvec[ia]))
            t0, t1 = max(t0, ta), min(t1, tb)
        ox, oy = o[ib] - S.c0, o[ic] - S.c1
        dx, dy = dvec[ib], dvec[ic]
        A = dx * dx + dy * dy; B = 2 * (ox * dx + oy * dy); C = ox * ox + oy * oy - S.R ** 2
        if A < 1e-12:
            return t0 if (C <= 0 and t0 < t1) else None
        disc = B * B - 4 * A * C
        if disc <= 0: return None
        r = math.sqrt(disc)
        ta, tb = max(t0, (-B - r) / (2 * A)), min(t1, (-B + r) / (2 * A))
        return ta if ta < tb - 1e-9 else None
    ta, tb = t0, t1
    for n, c in S.H:
        dn = n[0] * dvec[0] + n[1] * dvec[1] + n[2] * dvec[2]
        nm = c - (n[0] * o[0] + n[1] * o[1] + n[2] * o[2])
        if abs(dn) < 1e-12:
            if nm < 0: return None
        elif dn > 0: tb = min(tb, nm / dn)
        else: ta = max(ta, nm / dn)
        if ta >= tb - 1e-9: return None
    return ta


def hits(o, dvec, t0, t1, S, Zs):
    return entry(o, dvec, t0, t1, S, Zs) is not None


def upper(d, sx):
    """groove-zone solids on / above the coated face + posts, side sx (what a lid-view leg can meet)"""
    tag = '+X' if sx > 0 else '-X'
    O = [poly_xw([(d['x_ul'], d['w_hi']), (d['x_rw'], d['w_hi']), (d['x_rw'], d['w_back']), (d['x_ul'] + (d['w_back'] - d['w_hi']) * d['bevel_k'], d['w_back'])], d['v_top'], d['v_bot'], sx, 'upper flank ' + tag),
         poly_xw([(d['x_gb'], d['w_lo']), (d['x_rw'], d['w_lo']), (d['x_rw'], d['w_hi']), (d['x_gb'], d['w_hi'])], d['v_top'], d['v_bot'], sx, 'groove bottom ' + tag),
         poly_xw([(d['x_ul'], d['plate_t']), (d['x_gb'], d['plate_t']), (d['x_gb'], d['w_hi']), (d['x_ul'], d['w_hi'])], d['v_top'], d['v_es'], sx, 'roof foam ' + tag),
         poly_xw([(d['stop_x0'], d['stop_w'][0]), (d['inner_hw'] - 0.3, d['stop_w'][0]), (d['inner_hw'] - 0.3, d['stop_w'][1]), (d['stop_x0'], d['stop_w'][1])], d['v_top'] - d['stop_len'], d['v_top'], sx, 'glass_stop ' + tag),
         poly_xw([(d['inner_hw'], d['diag_w_up'][0]), (d['wall_out'], d['diag_w_up'][0]), (d['wall_out'], d['diag_w_up'][1]), (d['inner_hw'], d['diag_w_up'][1])], d['v_top'], d['v_bot'], sx, 'side rib ' + tag)]
    for q in d['preload_v']:
        bl = d['boss_l'] / 2
        O += [poly_xw([(d['boss_x0'], d['w_hi']), (d['x_rw'], d['w_hi']), (d['x_rw'], d['w_hi'] + d['boss_h']), (d['boss_x0'], d['w_hi'] + d['boss_h'])], q - bl, q + bl, sx, f'boss v={q:g} {tag}'),
              Cyl('z', sx * d['x_pl'], q, d['ps_head'][0] / 2, d['head_w'][0], d['head_w'][1], True, f'thumbscrew head v={q:g} {tag}'),
              Cyl('z', sx * d['x_pl'], q, d['ps_d'] / 2, d['plate_t'], d['head_w'][0], True, f'shank/tip/felt v={q:g} {tag}')]
    O.append(poly_xy([(d['inner_hw'], max(d['y_flare'], d['y_front'])), (d['x_front_in'], d['y_front']), (d['x_col_out'], d['y_front']), (d['x_col_out'], d['y_front'] + d['col_d']),
                      (d['inner_hw'], d['y_front'] + d['col_d'])], 0, d['frame_top'], sx, 'front post ' + tag))
    xa, xb = sorted((sx * d['rp_x0'], sx * d['wall_out']))
    O.append(box((xa, d['rp_y'][0], 0), (xb, d['rp_y'][1], d['frame_top']), name='rear post ' + tag))
    if d['hardware'] == 'printed':   # post-top pads (exact convex) + glass_stop ear over the stop block
        def mir(pl, name):
            return Planes([((sx * n[0], n[1], n[2]), c) for n, c in pl.H], False, name)
        fp = box((d['fp_x0'], d['y_front'] + d['col_d'], d['fp_z0']), (d['fp_x1'], d['fp_y1'], d['frame_top']))   # behind the post
        fp.H.append(((0, 1, -1), d['y_front'] + d['col_d'] - d['fp_z0']))
        cw = box((d['x_col_out'], d['y_front'], d['fp_top'] - (d['fp_x1'] - d['x_col_out'])), (d['fp_x1'], d['y_front'] + d['col_d'], d['frame_top']))
        rp = box((d['rp_x0'], d['rp_y'][0], d['rpz0']), (d['x_col_out'], d['y_zone_end'], d['frame_top']))
        rp.H += [((1, 0, -1), d['wall_out'] - d['rpz0'])]
        rl = box((d['inner_hw'], d['rp_py0'], d['rpz0']), (d['x_col_out'], d['rp_y'][0], d['frame_top']))   # rear pad forward lip
        rl.H += [((0, -1, -1), -(d['rpz0'] + d['rp_y'][0])), ((1, 0, -1), d['wall_out'] - d['rpz0'])]
        ear = box((d['stop_x0'], d['stop_clip_y'], d['fp_top']), (d['fp_x0'], d['sear_y1'], d['frame_top']))
        O += [mir(fp, 'front pad ' + tag), mir(cw, 'column top ' + tag), mir(ear, 'glass_stop ear ' + tag),
              mir(rp, 'rear pad ' + tag), mir(rl, 'rear pad lip ' + tag)]
    return O


def lid_box(d):
    hw = d.get('lid_hw', d['x_col_out'])   # (printed hardware: the lid is 2 mm wider per side, over the front pads)
    return box((-hw, d['y_front'], d['frame_top']), (hw, d['y_zone_end'], d['frame_top'] + d['lid_t'] + d['lid_rib_h']), name='lid')


def rear_lens(d, sr):
    return Cyl('y', sr, d['Zs'], d['R15'], d['y_rear_front'], d['y_rear_mount'], name='rear lens')


def obstacles(d, sr, sb, cam, hood=False):
    """every obstruction of the scene legs"""
    O = []
    for sx in (-1, 1):
        O += [poly_xw([(d['x_lip'], d['w_fl']), (d['x_lip'] + d['lip_flat'], d['w_fl']), (d['x_lip'] + d['lip_flat'], d['w_lo']), (d['x_lip'], d['w_lo'])], d['v_top'], d['v_bot'], sx),
              poly_xw([(d['x_lip'] + d['lip_flat'], d['w_fl']), (d['x_rw'], d['w_front_rw']), (d['x_rw'], d['w_lo']), (d['x_lip'] + d['lip_flat'], d['w_lo'])], d['v_top'], d['v_bot'], sx),
              poly_xw([(d['x_lip'], d['w_lo']), (d['x_rw'], d['w_lo']), (d['x_rw'], d['w_hi']), (d['x_lip'], d['w_hi'])], d['v_es'], d['v_bot'], sx),
              poly_xw([(d['inner_hw'], d['diag_w_lo'][0]), (d['wall_out'], d['diag_w_lo'][0]), (d['wall_out'], d['diag_w_lo'][1]), (d['inner_hw'], d['diag_w_lo'][1])], d['v_bot'], d['v_bot'] + 250, sx)]
        O += upper(d, sx)
    O += [lid_box(d),
          box((-d['wall_out'], d['y_front'], 0), (d['wall_out'], d['y_back'], d['base_t'])),
          box((-d['brace_x'] - 1, d['brace_y0'], 0), (d['brace_x'] + 1, d['brace_y1'], d['brace_top'])),
          box((-d['wall_out'], d['y_wf'], 0), (d['wall_out'], d['y_wf'] + d['cw_depth'], d['cw_top'])),
          box((-d['wall_out'], d['deck_y0'], d['deck_top'] - d['rail_band_d']), (d['wall_out'], d['y_back'], d['deck_top']))]
    if cam == 'rear':   # the other camera's lens + its IR filter ring
        O += [Cyl('z', -sb, 0.0, d['R1018'], d['z_bot_mount'], d['z_bot_front']),
              Cyl('z', -sb, 0.0, d['filt_od'] / 2, d['z_bot_front'] - 1, d['z_bot_filt'])]
    else:
        O.append(rear_lens(d, sr))
    if hood:   # optional hood: 4 flared wall slabs
        th, tv, D, m, wl, y1 = d['th'], d['tv'], d['D'], d['aperture_margin'], d['hood_wall'], d['y_front'] - d['hood_len']
        for s in (-1, 1):
            O.append(Planes([((-s, -th, 0), -(m + th * D)), ((s, th, 0), m + wl + th * D), ((0, 1, 0), d['y_front']), ((0, -1, 0), -y1),
                             ((0, 0, 1), d['Zs'] + 200), ((0, 0, -1), -(d['Zs'] - 200))]))
            O.append(Planes([((0, -tv, -s), -(m + tv * D) - s * d['Zs']), ((0, tv, s), m + wl + tv * D + s * d['Zs']), ((0, 1, 0), d['y_front']),
                             ((0, -1, 0), -y1), ((1, 0, 0), 300), ((-1, 0, 0), 300)]))
    return O


def lid_parts(d, sr):
    return upper(d, -1) + upper(d, 1) + [rear_lens(d, sr)]


def pixel(d, cam, u, s, sr, sb, O, L, lid):
    """-> (scene clipped, clean scene leg through the side plane (wrap), lid-view class, name of the part seen)"""
    th, tv, D, Zs = d['th'], d['tv'], d['D'], d['Zs']
    rear = cam == 'rear'
    o = (sr, D, Zs) if rear else (-sb, 0.0, Zs - D)
    dv = (u * th, -1.0, s * tv) if rear else (u * th, -s * tv, 1.0)
    tp = D / (1 - s * tv)
    Pp = tuple(o[i] + tp * dv[i] for i in range(3))
    vP = (Pp[1] - Pp[2] + Zs) / s2
    if abs(Pp[0]) > d['h_plate'] or abs(vP) > d['h_plate']: return True, False, None, None
    tb = (D - d['plate_t'] * s2) / (1 - s * tv) if rear else tp     # rear: leg 1 ends at the uncoated back face
    ep = d['ep15'] if rear else d['ep1018']
    r = (u * th, -1.0, s * tv)
    if any(hits(o, dv, ep, tb - 1e-6, S, Zs) for S in O) or any(hits(Pp, r, 1e-6, Pp[1] - d['y_far'], S, Zs) for S in O):
        return True, False, None, None
    wrap = False
    if abs(r[0]) > 1e-9:
        tw = (math.copysign(d['wall_out'], r[0]) - Pp[0]) / r[0]
        zw = Pp[2] + tw * r[2]
        wrap = Pp[1] - tw > d['y_front'] and 0 < zw < d['frame_top']
    ld = (u * th, -s * tv, 1.0)
    te = d['frame_top'] + d['lid_t'] + d['lid_rib_h'] + 1 - Pp[2]
    tl = entry(Pp, ld, 1e-6, te, lid, Zs)
    tmax = te if tl is None else tl
    first, who = None, None
    for S in L:
        t = entry(Pp, ld, 1e-6, tmax, S, Zs)
        if t is not None and (first is None or t < first): first, who = t, S.name
    kind = 'part' if first is not None else ('lid' if tl is not None else 'outside')
    return False, wrap, kind, who


def cheb(bad):
    return min([1.0] + [max(abs(u), abs(s)) for u, s in bad])


def run(d, sr, sb, nx, ny, hood=False):
    res = {}
    for cam in ('rear', 'bottom'):
        O = obstacles(d, sr, sb, cam, hood); L = lid_parts(d, sr); lid = lid_box(d)
        res[cam] = {(u, s): pixel(d, cam, u, s, sr, sb, O, L, lid)
                    for j in range(ny) for i in range(nx) for u, s in [(-1 + (2 * i + 1) / nx, -1 + (2 * j + 1) / ny)]}
    stop = 1 - 1 / ny
    out = {}
    wb_all, ub_all = [], []
    for cam, m in res.items():
        wb = [k for k, v in m.items() if v[0] or v[1]]
        ub = [k for k, v in m.items() if v[0] or v[2] in ('part', 'outside')]
        n = nx * ny
        out[cam] = dict(area=100 * len(wb) / n, top=100 * sum(1 for u, s in wb if s >= stop - 1e-9) / nx,
                        scene_open=100 * sum(1 for v in m.values() if v[0]) / n,
                        part=100 * sum(1 for v in m.values() if not v[0] and v[2] == 'part') / n,
                        outside=100 * sum(1 for v in m.values() if not v[0] and v[2] == 'outside') / n)
        wb_all += wb; ub_all += ub
    crop = lambda c: 100.0 if c >= 1 else max(0.0, 100 * (c - 1 / ny))
    out['crop_w'] = crop(cheb(wb_all)); out['crop_u'] = crop(cheb(ub_all))
    return out, res


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--grid', default='64x36'); ap.add_argument('--f', type=float, default=19.0)
    ap.add_argument('--filt', default='65,6', help='IR filter on the bottom lens: OD,protrusion (0,0 = none)')
    ap.add_argument('--ep15', type=float, default=25.0); ap.add_argument('--ep1018', type=float, default=25.0)
    ap.add_argument('--hood', action='store_true'); ap.add_argument('--splits', default='0,20,30,40,50,60,70,80')
    ap.add_argument('--point', default=None, help='SR,SB: one setting (like -D stereo_rear/stereo_bot); several: SR,SB;SR,SB')
    ap.add_argument('--detail', action='store_true', help='list what the lid views see')
    ap.add_argument('--head-nominal', action='store_true', help='thumbscrew heads at their nominal height only (no 0.7 tightening)')
    ap.add_argument('--hardware', default='printed', choices=['printed', 'steel'], help='hardware mode (as the .scad)')
    a = ap.parse_args()
    nx, ny = map(int, a.grid.split('x'))
    p = dict(P); p.update(f=a.f, ep15=a.ep15, ep1018=a.ep1018, hardware=a.hardware)
    if a.hardware == 'printed': p.update(PRINTED)
    p['filt_od'], p['filt_len'] = map(float, a.filt.split(','))
    if a.head_nominal: p['head_tight'] = 0.0
    d = derive(p)
    pts = ([tuple(map(float, q.split(','))) for q in a.point.split(';')] if a.point
           else [(i / 2, i / 2) for i in map(float, a.splits.split(','))])
    print(f"target {a.f:g} mm 16:9, IR filter O{p['filt_od']:g} x {p['filt_len']:g}, grid {nx}x{ny} (one column = {200 / nx:.2f} % of the width), D = {d['D']:.2f}, "
          f"hood {'on' if a.hood else 'off'}, preload_v {d['preload_v']}, hardware {a.hardware}")
    print("| split interaxial (rear +, bottom -) | rear clipped % (wrapped) | rear top row % | bottom clipped % (wrapped) | bottom top row % "
          "| crop WRAPPED % | lid view sees a part: rear / bottom % | lid view sees the outside: rear / bottom % | crop UNWRAPPED % |")
    print("|---|---|---|---|---|---|---|---|---|")
    for sr, sb in pts:
        o, res = run(d, sr, sb, nx, ny, a.hood)
        R, B = o['rear'], o['bottom']
        print(f"| {sr + sb:g} (+{sr:g} / -{sb:g}) | {R['area']:.1f} | {R['top']:.1f} | {B['area']:.1f} | {B['top']:.1f} | {o['crop_w']:.1f} "
              f"| {R['part']:.1f} / {B['part']:.1f} | {R['outside']:.1f} / {B['outside']:.1f} | {o['crop_u']:.1f} |")
        if a.detail:
            from collections import Counter
            for cam in ('rear', 'bottom'):
                m = res[cam]
                c = Counter(v[3] for v in m.values() if not v[0] and v[2] == 'part')
                wr = sum(1 for v in m.values() if v[1])
                out = [k for k, v in m.items() if not v[0] and v[2] == 'outside']
                print(f"    {cam}: lid view parts " + (", ".join(f"{w} x{n}" for w, n in c.most_common()) or "none")
                      + f"; outside {len(out)}" + (f" (u {min(u for u, s in out):.3f}..{max(u for u, s in out):.3f})" if out else "")
                      + f"; clean scene legs through the side plane (wrap) {wr}")
