// ============================================================
// relief.scad
// Importable module: raised, stepped relief with a 7-sided plan
// (a regular heptagon stretched to width x depth, flat side towards -Y),
// like the stone relief in the middle of the platform.
//
// Usage:
//   use <relief.scad>
//   relief(width = 40, depth = 28, steps = 3, riser = 1, tread = 2);
//
//   width, depth : size of the lowest tier (bounding box in plan)
//   steps        : number of tiers (steps)
//   riser        : height of each step
//   tread        : depth of each step, measured on the plan
//   Centered on the XY origin, standing on z = 0.
// ============================================================

// Unit heptagon (circumradius 1): flat side at the bottom, one vertex at the top
function heptagon_points() = [for (k = [0 : 6]) let (a = -90 + 180 / 7 + k * 360 / 7) [cos(a), sin(a)]];

module heptagon_plan(width, depth) {
    // bounding box of the unit heptagon: x = +-0.9749, y from -0.9010 to 1
    sx = width / (2 * 0.9749);
    sy = depth / (1 + 0.9010);
    translate([0, -(1 - 0.9010) / 2 * sy])
        scale([sx, sy])
            polygon(heptagon_points());
}

module relief(width = 40, depth = 28, steps = 3, riser = 1, tread = 2) {
    assert(steps >= 1, "steps must be at least 1");
    assert(2 * steps * tread < min(width, depth), "the steps are too deep for this size");

    for (i = [0 : steps - 1])
        linear_extrude(height = (i + 1) * riser)
            offset(delta = -i * tread)
                heptagon_plan(width, depth);
}

// Quick preview when opening this file directly (comment out when importing):
// relief();
