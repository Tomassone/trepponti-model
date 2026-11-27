// ============================================================
// pedestal.scad
// Importable module: display pedestal (plinth) under the model.
// It follows the footprint of the model: the outline is the convex hull
// of the given points, pushed out by `margin`, with rounded corners and
// a chamfered top edge. The top face sits at z = z_top, the pedestal
// goes down from there.
//
// Usage:
//   use <pedestal.scad>
//   pedestal(points = [[-50, -30], [50, -30], [50, 40], [-50, 40]]);
//
//   points   : list of [x, y] points that must stay inside the pedestal
//   margin   : how far the pedestal sticks out beyond the hull of the points
//   height   : total height of the pedestal
//   chamfer  : size of the chamfer on the top edge
//   step     : height of a thin lower step (a second, wider slab), 0 = none
//   step_out : how far that lower step sticks out
//   z_top    : height of the top face
// ============================================================
module pedestal_outline(points, margin) {
    offset(r = margin, $fn = 48)
        hull()
            for (p = points) translate(p) circle(r = 0.01, $fn = 8);
}

module pedestal(
    points,
    margin   = 8,
    height   = 6,
    chamfer  = 1.5,
    step     = 1.5,
    step_out = 2,
    z_top    = 0
) {
    assert(len(points) >= 3, "pedestal needs at least 3 points");
    assert(height > step + chamfer, "height must be larger than step + chamfer");
    assert(chamfer < margin, "chamfer must be smaller than margin");

    translate([0, 0, z_top - height]) {
        // lower step: a slightly wider thin slab
        if (step > 0)
            linear_extrude(height = step)
                pedestal_outline(points, margin + step_out);

        // main body, up to where the chamfer starts
        linear_extrude(height = height - chamfer)
            pedestal_outline(points, margin);

        // chamfered top edge
        hull() {
            translate([0, 0, height - chamfer - 0.01])
                linear_extrude(height = 0.01)
                    pedestal_outline(points, margin);
            translate([0, 0, height - 0.01])
                linear_extrude(height = 0.01)
                    pedestal_outline(points, margin - chamfer);
        }
    }
}

// Quick preview when opening this file directly (comment out when importing):
// pedestal([[-50, -30], [50, -30], [50, 40], [-50, 40]]);
