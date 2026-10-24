// Step 09: T-bolts into the carriages (docs/ASSEMBLY.md).  Both carriages off the rig, rail face up; the two slide
// T-bolts of each drop into their diamond pockets. 
// Camera (the labels are placed for it): --camera=-5,-10,15,50,0,330,620
include <scene_lib.scad>

R = [50, 330];                       // label rotation = camera rx, rz
RY = 60;  BY = -45;                  // where the two carriages lie on the bench
DZ = 25;                             // bolts held above their pockets
head_top = function(w) car_t(w) + DZ - (sb_pd - sb_head[1]) ;

translate([0, RY, 0]) { done() carriage_flipped("rear");   new1() slide_bolts_flipped("rear", dz = DZ); }
translate([0, BY, 0]) { done() carriage_flipped("bottom"); new1() slide_bolts_flipped("bottom", dz = DZ); }

// a short arrow down onto each bolt head
for (c = [["rear", RY], ["bottom", BY]], s = [-1, 1]) let(w = c[0], y = c[1] + car_yc(w))
    arrow([s * slide_bolt_x, y, head_top(w) + 22], [s * slide_bolt_x, y, head_top(w) + 3], d = 2.2);

tag("04 rear carriage",   [-59, 101, 0], R, size = 7, halign = "right");
tag("05 bottom carriage", [-68, -95, 0], R, size = 7, halign = "right");
tag("square head in the diamond pocket", [80, RY + 25, 22], R,
    to = [slide_bolt_x + 3, RY + car_yc("rear"), car_t("rear")], size = 6);
