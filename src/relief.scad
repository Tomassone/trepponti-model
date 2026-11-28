// ============================================================
// relief.scad
// Importable module: raised, stepped relief on top of a platform.
// The outline is any convex polygon given as a list of [x, y] points
// (the relief of the Trepponti has 7 sides: 3 on the side of the stairs,
// 2 on the opposite side and 2 lateral ones parallel to the axis).
// Every step is the outline pushed inwards by `tread`.
//
// Usage:
//   use <relief.scad>
//   relief(points = [[10, 0], [20, 10], [20, 30], [0, 40], [-20, 30], [-20, 10], [-10, 0]],
//          steps = 3, riser = 1, tread = 2);
//
//   points : outline of the lowest tier, convex, in the XY plane
//   steps  : number of tiers (steps)
//   riser  : height of each step
//   tread  : depth of each step, measured on the plan
//   Stands on z = 0.
// ============================================================

module relief(points, steps = 3, riser = 1, tread = 2) {
    assert(len(points) >= 3, "relief needs at least 3 points");
    assert(steps >= 1, "steps must be at least 1");

    for (i = [0 : steps - 1])
        linear_extrude(height = (i + 1) * riser)
            offset(delta = -i * tread)
                polygon(points);
}

// Quick preview when opening this file directly (comment out when importing):
// relief(points = [[10, 0], [20, 10], [20, 30], [0, 40], [-20, 30], [-20, 10], [-10, 0]]);
