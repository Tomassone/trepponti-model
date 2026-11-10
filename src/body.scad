// ============================================================
// body.scad
// Importable module: a faceted body made by extruding a 5-point
// profile, with optional spherical cuts carved into its underside.
//
// Usage:
//   use <body.scad>
//   body();                          // default values (the refined shape)
//   body(refine = false);            // raw extruded body, no cuts
//   body(cut_r = 9, h = 20);         // custom values
// ============================================================

// ------------------------------------------------------------
// body()
// The body is centered on the origin in X and Y, and sits on the
// XY plane (z = 0 is the bottom, z = h is the top).
//
// Profile (in the XY plane, before centering):
//
//                    p2 (d1, bh1+bh2)
//                   /  \
//                  /    \
//      p1 (0, bh1)        p3 (2*d1, bh1)
//         \                    /
//          \                  /
//       p0 (d2, 0) ------ p4 (2*d1-d2, 0)
//
//   d1         : half of the overall width; the apex p2 sits at x = d1
//   d2         : inset of the bottom corners from the side corners
//   bh1        : height of the side corners (p1, p3) above the bottom edge
//   bh2        : extra height of the apex (p2) above the side corners
//   h          : height of the extrusion (Z)
//   refine     : true to subtract the spherical cuts, false for the raw body
//   cut_r      : radius of each spherical cut
//   cut_centers: centers of the spherical cuts, in the final centered
//                coordinates (the body is centered on the X and Y axes)
//   $fa, $fs   : mesh quality for the spheres
// ------------------------------------------------------------
module body(
    d1          = 24,
    d2          = 4,
    bh1         = 20,
    bh2         = 8,
    h           = 16,
    refine      = true,
    cut_r       = 11,
    cut_centers = [[0, -10, 0], [10, 2, 0], [-10, 2, 0]],
    $fa         = 1,
    $fs         = 0.4
) {
    // basic sanity checks
    assert(d2 < d1, "d2 must be smaller than d1");
    assert(h > 0,   "h must be positive");

    // --- Profile points (closed polygon, clockwise) ---
    p0 = [d2,           0];          // bottom-left corner
    p1 = [0,            bh1];        // left side corner
    p2 = [d1,           bh1 + bh2];  // apex
    p3 = [2 * d1,       bh1];        // right side corner
    p4 = [2 * d1 - d2,  0];          // bottom-right corner
    points = [p0, p1, p2, p3, p4];

    // Offset that centers the profile on the origin in X and Y
    center_offset = [-d1, -(bh1 + bh2) / 2, 0];

    difference() {
        // Base extrusion, centered in X and Y, standing on z = 0
        translate(center_offset)
            linear_extrude(height = h)
                polygon(points);

        // Spherical cuts (skipped when refine = false)
        if (refine)
            for (c = cut_centers)
                translate(c)
                    sphere(r = cut_r);
    }
}

// Quick preview when opening this file directly (comment out when importing):
// body();