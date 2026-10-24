// Lays out the exported print files for docs/img/print_set.png and docs/img/frame_print.png.
// Run tools/export_all.sh first.  The positions suit the default parameters.
show = "all";   // "all", or one file name without .stl, e.g. "01_frame"

// [file, position, label position, printed hardware (100 % infill)]
files = [
    ["05_bottom_carriage",         [-308, -115], [-308, -131], false],
    ["01_frame",                   [-124, -170], [-124, -244], false],
    ["02_top_lid",                 [ 106,  -65], [ 106, -139], false],
    ["15_wrap_clips",              [ 240, -149], [ 299, -160], true],
    ["03_wall_rail",               [-169, -311], [-169, -320], false],
    ["06_f38_slides_x2",           [  40, -285], [  40, -323], false],
    ["11_hardware_screws_solid",   [ 159, -329], [ 209, -347], true],
    ["04_rear_carriage",           [-258, -390], [-258, -429], false],
    ["12_hardware_nuts_solid",     [-171, -406], [-133, -421], true],
    ["09_shim_set_print_2x",       [ -48, -382], [  -6, -413], false],
    ["10_swap_shim_3mm_riser",     [  94, -382], [  94, -413], false],
    ["07_glass_stops_x2",          [ 172, -376], [ 172, -400], false],
    ["13_glass_thumbscrews_solid", [ 242, -390], [ 274, -407], true],
    ["08_groove_strips_x2",        [ -31, -454], [ -31, -475], false],
    ["14_pins_solid",              [  70, -479], [  88, -491], true]
];
part_grey = [0.5, 0.52, 0.57];
hw_orange = [0.95, 0.55, 0.15];   // as in the assembly view

if (show == "all")
    for (e = files) {
        color(e[3] ? hw_orange : part_grey) translate(e[1]) import(str("../stl/", e[0], ".stl"));
        color([0.2, 0.2, 0.2]) translate(e[2]) linear_extrude(0.4)
            text(str(e[0][0], e[0][1]), size = 9, halign = "center", valign = "top", font = "Liberation Sans:style=Bold");
    }
else
    color(part_grey) import(str("../stl/", show, ".stl"));
