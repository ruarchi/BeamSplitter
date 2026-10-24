// Labels placed by image position, for the assembly-guide scenes (include after scene_lib.scad).
//
// The scene sets its camera once, as the numbers it is rendered with:
//     CAM = [cx, cy, cz, rx, rz, dist];      // = --camera=cx,cy,cz,rx,0,rz,dist   (OpenSCAD 22.5 degree view)
// and the image size if it is not 1400 x 1050:   IMG = [w, h];
// Then
//     lab("02 top lid", [990, 110], to = [60, -65, 416]);
// writes the label with its left end at image pixel (990, 110) (halign = "right": its right end there) and draws a
// leader from the nearer end of the text to the world point `to`.  Labels sit in a plane facing the camera, LAB_F of
// the way from the camera centre toward the camera (so the model does not hide them), so a pixel position is exact
// and the text is LAB_PX pixels high whatever the distance.

IMG    = [1400, 1050];
LAB_PX = 21;                                            // text height in pixels (can be set per scene)
LAB_F  = 0.5;                                           // label plane: this fraction of the way toward the camera
function cam_sr() = [cos(CAM[4]), sin(CAM[4]), 0];                  // image right
function cam_su() = [-cos(CAM[3]) * sin(CAM[4]), cos(CAM[3]) * cos(CAM[4]), sin(CAM[3])];   // image up
function cam_vw() = [sin(CAM[3]) * sin(CAM[4]), -sin(CAM[3]) * cos(CAM[4]), cos(CAM[3])];  // toward the camera
function cam_k()  = (IMG[1] / 2) / ((1 - LAB_F) * CAM[5] * tan(11.25));   // pixels per mm in the label plane
// world point (in the label plane) at image pixel (x, y), y downward from the top edge
function px(x, y) = [CAM[0], CAM[1], CAM[2]] + LAB_F * CAM[5] * cam_vw()
                    + (x - IMG[0] / 2) / cam_k() * cam_sr() + (IMG[1] / 2 - y) / cam_k() * cam_su();
function lab_size() = LAB_PX / cam_k();
// image pixel [x, y] of a world point (perspective, as OpenSCAD draws it)
function scr(p) = let(r = p - [CAM[0], CAM[1], CAM[2]], d = CAM[5] - r * cam_vw(), k = (IMG[1] / 2) / (d * tan(11.25)))
    [IMG[0] / 2 + (r * cam_sr()) * k, IMG[1] / 2 - (r * cam_su()) * k];
// Liberation Sans Bold advance widths (em); the OpenSCAD em is about 1.35 x the text size
function lab_cw(c) = let(g = [["iljI.,:;'!| ", 0.278], ["ftr()-/[]", 0.36], ["mM", 0.88], ["wW%", 0.8],
                              ["ABCDGHKNOQRUx", 0.73], ["EFPSTVXYZL", 0.65], ["\"", 0.47]])
    let(m = [for (e = g) if (len(search(c, e[0])) > 0) e[1]]) len(m) ? m[0] : 0.57;
function lab_w(txt, size) = 1.35 * size * (len(txt) ? [for (c = txt) lab_cw(c)] * [for (c = txt) 1] : 0);
// label + leader (to = undef: no leader); more = extra leader targets from the same end
module lab(txt, p, to = undef, halign = "left", size = undef, more = []) {
    s  = is_undef(size) ? lab_size() : size;
    at = px(p[0], p[1]);
    w  = lab_w(txt, s);
    ux = cam_sr();
    x0 = halign == "left" ? 0 : halign == "right" ? -w : -w / 2;
    ends = [at + (x0 - 0.55 * s) * ux, at + (x0 + w + 0.55 * s) * ux];
    tag(txt, at, [CAM[3], CAM[4]], size = s, halign = halign);
    for (t = is_undef(to) ? more : concat([to], more))
        let(st = scr(t), a = norm(scr(ends[0]) - st) <= norm(scr(ends[1]) - st) ? ends[0] : ends[1]) color(C_INK) {
            hull() { translate(a) sphere(d = 1.8 / cam_k(), $fn = 8); translate(t) sphere(d = 1.8 / cam_k(), $fn = 8); }
            translate(t) sphere(d = 6 / cam_k(), $fn = 16);
        }
}
