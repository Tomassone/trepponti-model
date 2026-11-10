$fa = 1;
$fs = 0.4;
bh  = 9;

difference() {
    difference() {
        translate([0,0,+bh*0.5])
            cube([5,5,bh],center=true);
        translate([0,0,0])
            cube([2,14,5],center=true);
    }
    translate([0,4,2.2])
        rotate([90, 0, 0])
            cylinder(2 * bh, 1);
}
rotate([0,0,45])
        translate([0,0,+bh])
            cylinder(1.8,4.2,00,$fn=4);

rotate([180,0,45])
        translate([0,0,-bh])
            cylinder(1.8,4.2,00,$fn=4);