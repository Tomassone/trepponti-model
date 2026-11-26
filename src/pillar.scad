// ------------------------------------------------------------
// pillar()
// Stone pillar (pilastrino) standing at the head of a front stair:
// square brick shaft, a wider stone capital, a small stone dome and a ball on top.
// Centered on the XY origin, base at Z = 0. All sizes in model units (mm).
//
//   size     : side of the shaft
//   shaft_h  : height of the shaft
//   cap_size : side of the capital (the slab right under the dome)
//   cap_h    : height of the capital
//   dome_h   : height of the dome
//   ball_d   : diameter of the ball on top
// ------------------------------------------------------------
module pillar(
    size     = 3.25,
    shaft_h  = 7.5,
    cap_size = 4.25,
    cap_h    = 1.0,
    dome_h   = 2.5,
    ball_d   = 1.0
) {
    assert(cap_size >= size, "cap_size must be at least as wide as the shaft");

    // shaft
    translate([-size / 2, -size / 2, 0])
        cube([size, size, shaft_h]);

    // capital
    translate([-cap_size / 2, -cap_size / 2, shaft_h])
        cube([cap_size, cap_size, cap_h]);

    // dome (small onion-like profile)
    r = cap_size * 0.42;
    translate([0, 0, shaft_h + cap_h])
        rotate_extrude($fn = 24)
            polygon([[0, 0], [r, 0], [r * 0.95, dome_h * 0.25],
                     [r * 0.65, dome_h * 0.6], [r * 0.25, dome_h * 0.9], [0, dome_h]]);

    // ball
    translate([0, 0, shaft_h + cap_h + dome_h])
        sphere(d = ball_d, $fn = 12);
}

// Quick preview when opening this file directly (comment out when importing):
// pillar();
