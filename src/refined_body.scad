include <body.scad>
$fa = 1;
$fs = 0.4;
difference() {
    difference() {
        difference() {
            body(
                d1 = 24,
                d2 = 4,
                bh1 = 20,
                bh2 = 8,
                h = 16
            );
            translate([0,-10,0])
                sphere(r=11);
        }
        translate([10,2,0])
            sphere(r=11);
    }
    translate([-10,2,0])
            sphere(r=11);
}