// ============================================================
// tower.scad
// Importable module: square tower with a through opening at
// the bottom (straight slot + round hole on top of it) and a
// pyramid cap on top.
//
// Usage:
//   use <tower.scad>
//   tower();                                  // default values
//   tower(height = 12, size = 6);             // custom size
//   tower(underside_cap = false);             // upper pyramid only
// ============================================================

// ------------------------------------------------------------
// cap_pyramid()
// A single pyramid (a cylinder with r2 = 0), apex pointing up,
// base lying on the XY plane. With 4 sides and a 45 deg rotation
// the base edges are parallel to the X and Y axes.
//
//   cap_h     : height of the pyramid
//   cap_r     : circumradius of the base (center-to-corner distance)
//   cap_sides : number of sides of the base
//   cap_rot   : rotation around Z (degrees)
// ------------------------------------------------------------
module cap_pyramid(cap_h, cap_r, cap_sides, cap_rot) {
    rotate([0, 0, cap_rot])
        cylinder(h = cap_h, r1 = cap_r, r2 = 0, $fn = cap_sides);
}

// ------------------------------------------------------------
// tower()
// The tower stands on the XY plane (z = 0 is the bottom), centered
// on the origin. The opening runs along the Y axis.
//
//   height        : height of the tower body (without the cap)
//   size          : side of the square cross-section
//   slot_width    : width (along X) of the straight slot at the bottom
//   slot_height   : height of the slot above the ground
//   hole_d        : diameter of the round hole (same axis as the slot)
//   hole_z        : height of the hole axis above the ground
//   cap_h         : height of each cap pyramid
//   cap_r         : circumradius of the cap base (with 4 sides the side
//                   length is cap_r * sqrt(2), about 5.94 by default)
//   cap_sides     : number of sides of the cap base
//   cap_rot       : rotation of the cap around Z (degrees)
//   underside_cap : true to add the downward pyramid under the cap
//                   (it only adds a small chamfer below the overhang)
//   $fa, $fs      : mesh quality for the round hole
// ------------------------------------------------------------
module tower(
    height        = 9,
    size          = 5,
    slot_width    = 2,
    slot_height   = 2.5,
    hole_d        = 2,
    hole_z        = 2.2,
    cap_h         = 1.8,
    cap_r         = 4.2,
    cap_sides     = 4,
    cap_rot       = 45,
    underside_cap = true,
    $fa           = 1,
    $fs           = 0.4
) {
    // basic sanity checks
    assert(height > slot_height, "height must be greater than slot_height");
    assert(size > slot_width,    "size must be greater than slot_width");
    assert(size > hole_d,        "size must be greater than hole_d");

    eps = 1;    // overshoot so the cuts go cleanly through the body

    // tower body with the opening cut out
    difference() {
        // square body, standing on z = 0
        translate([0, 0, height / 2])
            cube([size, size, height], center = true);

        // straight slot through the tower along Y
        translate([-slot_width / 2, -size / 2 - eps, -eps])
            cube([slot_width, size + 2 * eps, slot_height + eps]);

        // round hole through the tower along Y (rounds the top of the opening)
        translate([0, 0, hole_z])
            rotate([90, 0, 0])
                cylinder(d = hole_d, h = size + 2 * eps, center = true);
    }

    // cap: upward pyramid (and optional downward one) centered on the top face
    translate([0, 0, height]) {
        cap_pyramid(cap_h, cap_r, cap_sides, cap_rot);

        if (underside_cap)
            mirror([0, 0, 1])
                cap_pyramid(cap_h, cap_r, cap_sides, cap_rot);
    }
}

// Quick preview when opening this file directly (comment out when importing):
// tower();