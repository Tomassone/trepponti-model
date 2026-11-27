// ============================================================
// fan_stairs.scad
// Importable module: staircase that widens going down (fan / trapezoid
// in plan), with a flat top landing and smooth sloped side walls that
// follow the widening edges. Same local frame as stairs(): the top is
// at x = 0, the stair goes down along +X, centered on the Y axis.
//
// Usage:
//   use <fan_stairs.scad>
//   fan_stairs(total_height = 30, top_len = 8, run = 70,
//              width_top = 14, width_bot = 30, num_steps = 20);
// ============================================================
use <stairs.scad>     // stairs_wall_profile()

// Half width of the stair at distance d (along the steps) from the top step
function fan_half_width(width_top, width_bot, run, d) =
    (width_top + (width_bot - width_top) * d / run) / 2;

//   total_height   : height of the flat top landing above the ground
//   top_len        : length of the flat top landing (width = width_top)
//   run            : length of the steps
//   width_top      : width at the head of the stair
//   width_bot      : width at the foot of the stair
//   num_steps      : number of steps
//   rail_height    : height of the side walls above the step edges
//   rail_thickness : thickness of each wall (along Y)
module fan_stairs(
    total_height   = 30,
    top_len        = 8,
    run            = 70,
    width_top      = 14,
    width_bot      = 30,
    num_steps      = 20,
    rail_height    = 6,
    rail_thickness = 3
) {
    assert(num_steps >= 2, "num_steps must be at least 2");
    assert(width_bot >= width_top, "width_bot must be at least width_top");
    assert(rail_thickness * 2 <= width_top, "rail_thickness is too large for this width");

    rise     = total_height / num_steps;
    step_run = run / num_steps;
    base_len = top_len + run;
    big      = total_height + rail_height + 1;

    // flat landing
    translate([0, -width_top / 2, 0])
        cube([top_len, width_top, total_height]);

    // steps: each one is a trapezoid prism from the ground to its tread (the last one has zero height)
    for (i = [1 : num_steps - 1]) {
        x0 = top_len + (i - 1) * step_run;
        x1 = top_len + i * step_run;
        w0 = fan_half_width(width_top, width_bot, run, (i - 1) * step_run);
        w1 = fan_half_width(width_top, width_bot, run, i * step_run);
        linear_extrude(height = total_height - i * rise)
            polygon([[x0, -w0], [x1, -w1], [x1, w1], [x0, w0]]);
    }

    // side walls: a strip along each widening edge, cut by the sloped wall profile
    for (s = [-1, 1])
        intersection() {
            linear_extrude(height = big)
                polygon([
                    [top_len, s * width_top / 2],
                    [base_len, s * width_bot / 2],
                    [base_len, s * (width_bot / 2 - rail_thickness)],
                    [top_len, s * (width_top / 2 - rail_thickness)]
                ]);
            rotate([90, 0, 0])
                linear_extrude(height = width_bot + 2, center = true)
                    stairs_wall_profile(total_height, top_len, base_len, rail_height, false);
        }
}

// Quick preview when opening this file directly (comment out when importing):
// fan_stairs();
