// ============================================================
// stairs.scad
// Importable module: staircase block with a flat top landing
// and optional smooth sloped side walls running along the whole
// staircase, from the landing to the last step.
//
// Usage:
//   use <stairs.scad>
//   stairs();                                    // stairs + both side walls
//   stairs(side_walls = false);                  // stairs only
//   stairs(rail_height = 10, rail_thickness = 4);
//   stairs(rail_sides = [1]);                    // wall on the +Y side only
// ============================================================

// ------------------------------------------------------------
// stairs_profile()
// Returns the 2D side profile as a list of points
// (closed polygon, clockwise, starting at the origin).
//
//   total_height : height of the tallest side (left wall)
//   top_len      : length of the flat top landing
//   base_len     : total length of the base (landing + steps)
//   num_steps    : number of steps going down from the landing
// ------------------------------------------------------------
function stairs_profile(total_height, top_len, base_len, num_steps) =
    let (
        step_rise = total_height / num_steps,           // height of each step
        step_run  = (base_len - top_len) / num_steps    // depth of each step
    )
    concat(
        // left wall and flat top landing
        [
            [0,       0],              // bottom-left corner (origin)
            [0,       total_height],   // top-left corner
            [top_len, total_height]    // end of the top landing
        ],
        // for each step: one riser (down) and one tread (forward)
        [
            for (i = [1 : num_steps])
                each [
                    [top_len + (i - 1) * step_run, total_height - i * step_rise],
                    [top_len + i * step_run,       total_height - i * step_rise]
                ]
        ]
    );

// ------------------------------------------------------------
// stairs_wall_profile()
// 2D profile of a side wall with a smooth sloped top. The slope
// runs parallel to the line joining the step edges, raised by
// rail_height, and ends exactly at the end of the staircase.
//
//   total_height, top_len, base_len : same as stairs()
//   rail_height  : height of the wall above the step edges
//   landing_rail : true to continue the wall over the top landing
// ------------------------------------------------------------
module stairs_wall_profile(
    total_height = 30,
    top_len      = 30,
    base_len     = 70,
    rail_height  = 8,
    landing_rail = true
) {
    x_start = landing_rail ? 0 : top_len;    // where the wall begins

    polygon([
        [x_start,  0],                           // bottom-left
        [x_start,  total_height],                // top-left
        [top_len,  total_height],                // end of the flat top (landing)
        [base_len, rail_height],                 // end of the slope, over the last step
        [base_len, 0]                            // bottom-right
    ]);
}

// ------------------------------------------------------------
// stairs()
// The staircase solid, extruded and rotated upright (XZ plane),
// with its width centered on the Y axis. Optionally adds smooth
// side walls flush with the outer edges (the total width stays
// equal to `width`).
//
//   total_height   : height of the tallest side (left wall)
//   top_len        : length of the flat top landing
//   base_len       : total length of the base (landing + steps)
//   width          : width of the staircase (extrusion depth)
//   num_steps      : number of steps
//   side_walls     : true to add the side walls
//   rail_height    : height of the walls above the step edges
//   rail_thickness : thickness of each wall (along Y)
//   rail_sides     : Y sides with a wall: [-1, 1] = both, [1] = +Y, [-1] = -Y
//   landing_rail   : true to continue the walls over the top landing
// ------------------------------------------------------------
module stairs(
    total_height   = 30,
    top_len        = 30,
    base_len       = 70,
    width          = 30,
    num_steps      = 8,
    side_walls     = true,
    rail_height    = 6,
    rail_thickness = 3,
    rail_sides     = [-1, 1],
    landing_rail   = true
) {
    // basic sanity checks
    assert(num_steps >= 1,                  "num_steps must be at least 1");
    assert(base_len > top_len,              "base_len must be greater than top_len");
    assert(rail_thickness * 2 <= width,     "rail_thickness is too large for this width");

    // staircase body
    rotate([90, 0, 0])                          // profile Y axis becomes Z (up)
        linear_extrude(height = width,
                       center = true)           // centered on the final Y axis
            polygon(stairs_profile(total_height, top_len, base_len, num_steps));

    // side walls
    if (side_walls)
        for (s = rail_sides)
            rotate([90, 0, 0])
                // after the rotation, -Z becomes +Y, hence the minus sign
                translate([0, 0, -s * (width / 2 - rail_thickness / 2)])
                    linear_extrude(height = rail_thickness, center = true)
                        stairs_wall_profile(
                            total_height = total_height,
                            top_len      = top_len,
                            base_len     = base_len,
                            rail_height  = rail_height,
                            landing_rail = landing_rail
                        );
}

// Quick preview when opening this file directly (comment out when importing):
stairs();