// ============================================================
// fan_stairs.scad
// Importable module: staircase that widens going down (fan / trapezoid
// in plan), with a flat top pad, an optional "extended" step in the
// middle (a long tread that works as a landing between two flights) and
// smooth sloped side walls that follow the widening edges. Same local
// frame as stairs(): the top is at x = 0, the stair goes down along +X,
// centered on the Y axis.
//
// Usage:
//   use <fan_stairs.scad>
//   fan_stairs(total_height = 30, top_len = 8, run = 70,
//              width_top = 14, width_bot = 30, num_steps = 20,
//              landing_step = 10, landing_len = 10);
// ============================================================

// Half width of the stair at distance d (along the steps) from the first step
function fan_half_width(width_top, width_bot, run, d) =
    (width_top + (width_bot - width_top) * d / run) / 2;

//   total_height   : height of the flat top pad above the ground
//   top_len        : length of the flat top pad (width = width_top)
//   run            : length of the steps, the extended step included
//   width_top      : width at the first step
//   width_bot      : width at the foot of the stair
//   num_steps      : number of steps, the extended one included
//   landing_step   : number of the step that is extended (0 = none, otherwise 2 .. num_steps - 1)
//   landing_len    : length of that step
//   rail_height    : height of the side walls above the step edges
//   rail_thickness : thickness of each wall (along Y)
module fan_stairs(
    total_height   = 30,
    top_len        = 8,
    run            = 70,
    width_top      = 14,
    width_bot      = 30,
    num_steps      = 20,
    landing_step   = 0,
    landing_len    = 0,
    rail_height    = 6,
    rail_thickness = 3
) {
    assert(num_steps >= 3, "num_steps must be at least 3");
    assert(width_bot >= width_top, "width_bot must be at least width_top");
    assert(rail_thickness * 2 <= width_top, "rail_thickness is too large for this width");
    assert(landing_step == 0 || (landing_step >= 2 && landing_step <= num_steps - 1),
           "landing_step must be 0 or between 2 and num_steps - 1");
    assert(landing_step == 0 || landing_len < run, "landing_len must be shorter than run");

    n    = num_steps;
    k    = landing_step;
    rise = total_height / n;
    // all the steps have the same tread, except the extended one
    tread    = k > 0 ? (run - landing_len) / (n - 1) : run / n;
    // distance of the front edge of step i from the first step; z of its top
    function d(i) = i * tread + (k > 0 && i >= k ? landing_len - tread : 0);
    function z(i) = total_height - i * rise;

    base_len = top_len + run;
    big      = total_height + rail_height + 1;

    // flat top pad
    translate([0, -width_top / 2, 0])
        cube([top_len, width_top, total_height]);

    // steps: each one is a trapezoid prism from the ground to its tread (the last one has zero height)
    for (i = [1 : n - 1]) {
        w0 = fan_half_width(width_top, width_bot, run, d(i - 1));
        w1 = fan_half_width(width_top, width_bot, run, d(i));
        translate([top_len, 0, 0])
            linear_extrude(height = z(i))
                polygon([[d(i - 1), -w0], [d(i), -w1], [d(i), w1], [d(i - 1), w0]]);
    }

    // wall profile: coping parallel to the step edges; where there is an extended step it
    // drops one riser, runs flat along it, and goes on down parallel to the second flight
    wall = k == 0
        ? [[top_len, 0], [top_len, total_height + rail_height],
           [base_len, rail_height], [base_len, 0]]
        : [[top_len, 0], [top_len, total_height + rail_height],
           [top_len + d(k - 1), z(k - 1) + rail_height],
           [top_len + d(k - 1), z(k) + rail_height],
           [top_len + d(k),     z(k) + rail_height],
           [base_len, rail_height], [base_len, 0]];

    // side walls: a strip along each widening edge, cut by the wall profile
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
                    polygon(wall);
        }
}

// Quick preview when opening this file directly (comment out when importing):
// fan_stairs(landing_step = 10, landing_len = 10);
