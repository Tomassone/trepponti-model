use <body.scad>
use <tower.scad>
use <stairs.scad>
use <pillar.scad>
use <fan_stairs.scad>
use <relief.scad>
use <pedestal.scad>

// --- Print scale ---
model_scale = 200;                          // 1:200
function mm(m) = m * 1000 / model_scale;    // real metres -> model millimetres

// --- Mesh quality (lower these two if CGAL export is too slow) ---
fa = 2;
fs = 0.5;

// --- Measured on Google Earth (real metres) ---
long_side   = 17.53;                        // A-B
short_side  = 8.13;                         // B-C, mirrored to E-A
upper_side  = 9.81;                         // C-D, mirrored to D-E
back_run    = 10.0;                         // back stair, length
back_width  = 4.0;
front_run   = 14.0;                         // front stair, length
front_width = 2.9;

// --- Not measured: read off the reference photos (real metres / degrees) ---
corner_width   = 18.62;                     // E-C, sets the pentagon shape (below 2 * upper_side)
back_splay     = 20;                        // back stair: outward angle from the main axis (survey plan: 20)
front_fan      = 15;                        // front stairs C and E: outward angle from the main axis (survey plan: 13-15)
deck_height    = 4.0;                       // top of the back stairs = tower door sill
floor_raise    = 0.6;                       // platform floor above the tower door sill: the interior is dug down to here, so
                                            //   the tower doors show from inside too (0 = floor exactly at the sill)
wall_top_ab    = 6.35;                      // top of the tall wall along A-B (front photo), above the water
wall_t_ab      = 1.0;                       // its thickness
wall_h_side    = 1.0;                       // the other sides have a low wall / parapet, above the floor
wall_t_side    = 0.5;
stair_riser    = 0.15;                      // step height, sets the number of steps
parapet_h      = 0.45;                      // border of the stairs AND of the platform
parapet_t      = 0.30;
tower_side     = 4.0;                       // = back_width, the tower is as wide as its stair
tower_total    = 8.3;                       // above the door sill, roof included
tower_roof     = 0.85;
// All the arches are semicircular (opening width, crown height = width / 2, vault radius):
main_arch      = [7.6, 3.8, 3.9];           // A-B, over the main canal
side_arch      = [4.8, 2.4, 3.2];           // C-D and D-E, on both sides of the central stair
end_arch       = [4.8, 2.7, 2.9];           // B-C and E-A, the lateral sides: bigger, a bit taller than a semicircle (lateral photo)

// Central stair (at the apex D) and the six stone pillars at the heads of the three front stairs
apex_width     = front_width;               // head of the central stair = same as the other front stairs (pillar pairs evenly spaced)
apex_flare     = 12;                        // the two edges of the central stair each open by this angle (survey plan: 10-15)
apex_pad       = 1.8;                       // flat pad at its head, between the pillars, before the first step
apex_run       = 13.8;                      // steps of the two flights + the extended step
apex_land_len  = 2.0;                       // the extended step (a long tread / landing) in the middle of the stair
apex_width_bot = apex_width + 2 * apex_run * tan(apex_flare);
pillar_w       = 0.65;                      // shaft
pillar_shaft   = 2.75;                      // shaft height above the floor: tops out at ~8.25 m above the water, as in the front photo
pillar_cap_w   = 0.85;
pillar_cap_h   = 0.2;
pillar_dome_h  = 0.5;
pillar_ball_d  = 0.2;                       // total ~2.4 m: tops out ~2 m above the wall, as in the photos

// Stone relief in the middle of the platform: 7 sides, stepped (aerial and drone photos)
// Lowest tier, measured from the apex D along the axis: 3 sides towards the stairs (flat side + 2 diagonals),
// 2 lateral sides parallel to the axis, 2 sides towards the towers meeting at a vertex.
relief_gap     = 1.9;                       // D to the flat side
relief_flat    = 5.2;                       // length of the flat side
relief_w       = 9.2;                       // full width (survey plan: ~9)
relief_diag    = 2.7;                       // depth of the two diagonals
relief_lat     = 3.0;                       // length of the lateral sides
relief_tip     = 2.5;                       // depth of the two sides towards the towers
relief_steps   = 3;
relief_riser   = 0.25;
relief_tread   = 0.5;

// Passage inside each tower: from the door (deck_height) it climbs to the platform
exit_riser     = 0.15;                      // target step height (adjusted to fit floor_raise exactly)
exit_tread     = 0.30;
exit_width     = 1.1;                       // = the tower slot

// Pedestal (separate file, pedestal.scad). These are model millimetres, not real metres.
with_pedestal    = true;
pedestal_margin  = 8;
pedestal_height  = 6;
pedestal_chamfer = 1.5;
part             = "all";                   // "all", "model" or "pedestal": export the pedestal as its own print

// Central chamber under the platform, where the five vaults meet (height of its crown = vault_peak)
vault_y        = 5.2;                       // its center, measured from the A-B side
vault_r        = 4.0;
vault_peak     = 3.8;

platform_top = deck_height + floor_raise;      // = the floor of the platform, the heads of the front stairs and the base of the pillars

// --- Pentagon, solved from the side lengths (parameters of body()) ---
assert(corner_width < 2 * upper_side, "corner_width must be smaller than 2 * upper_side");
d1  = corner_width / 2;
d2  = d1 - long_side / 2;
bh1 = sqrt(pow(short_side, 2) - pow(d2, 2));
bh2 = sqrt(pow(upper_side, 2) - pow(d1, 2));

// Corners in body() coordinates (centered), real metres
y0 = -(bh1 + bh2) / 2;
B  = [long_side / 2, y0];
C  = [d1, y0 + bh1];
D  = [0, y0 + bh1 + bh2];

function relief_outline() =
    let (yD = D[1], u1 = relief_gap, u2 = u1 + relief_diag, u3 = u2 + relief_lat, u4 = u3 + relief_tip,
         f = relief_flat / 2, w = relief_w / 2)
    [[f, yD - u1], [w, yD - u2], [w, yD - u3], [0, yD - u4], [-w, yD - u3], [-w, yD - u2], [-f, yD - u1]];

// --- Stair directions ---
function dir(a) = [cos(a), sin(a)];
cd_angle      = atan2(D[1] - C[1], D[0] - C[0]);
bc_angle      = atan2(C[1] - B[1], C[0] - B[0]);
back_heading  = -90 + back_splay;
front_heading = 90 - front_fan;

// Middle of the top step: the outer edge of each flight starts at a corner
back_top  = B + back_width / 2 * dir(back_heading - 90);
front_top = C + front_width / 2 * dir(front_heading + 90);

// Rise and steps: the back stairs end at the tower doors, the front stairs go up to the platform
back_rise   = deck_height;
front_rise  = platform_top;
back_steps  = round(back_rise / stair_riser);
front_steps = round(front_rise / stair_riser);

// Landings reach back into the deck
front_mis     = abs(front_heading - (cd_angle - 90));     // top step vs. the C-D edge
back_landing  = tower_side;                               // the tower stands on it
front_landing = front_width * tan(front_mis) + 0.3;

// Central stair: on the axis, going north from the apex D. The apex pokes out between the sides of the
// top step, so the landing reaches back to cover the gap.
apex_top     = D;
apex_heading = 90;
apex_landing = apex_width / 2 * tan(180 - cd_angle) + 0.3;

// Tower, centered on the back flight, front face on the top step
tower_pos = back_top - tower_side / 2 * dir(back_heading);

// --- Arches (one per side of the pentagon, like the real bridge) ---
function arch_inset(a)   = sqrt(pow(a[2], 2) - pow(a[0] / 2, 2));  // vault center, inside the face
function arch_stretch(a) = 2 * a[1] / a[0];                        // vertical stretch
for (a = [main_arch, side_arch, end_arch])
    assert(a[2] > a[0] / 2, "vault radius must be larger than half the opening width");

// C-D: the free part of the side, next to the front stair
front_foot = front_width / cos(front_mis);
apex_foot  = apex_width / 2 / abs(cos(cd_angle));              // part of C-D taken by the central stair
assert(side_arch[0] < upper_side - front_foot - apex_foot, "side_arch is too wide for the free part of C-D");
cd_mid     = C + (front_foot + upper_side - apex_foot) / 2 * dir(cd_angle);
cd_center  = cd_mid + arch_inset(side_arch) * dir(cd_angle + 90);

// B-C: the free part of the side, past the tower
bc_len   = norm(C - B);
tower_reach = max([for (sa = [-1, 1], sb = [-1, 1])
    (tower_pos - B + sa * tower_side / 2 * dir(back_heading)
                   + sb * tower_side / 2 * dir(back_heading + 90)) * dir(bc_angle)]);
assert(end_arch[0] < bc_len - 1, "end_arch is too wide for B-C");
bc_mid    = B + bc_len / 2 * dir(bc_angle);                 // centered on the whole side, the tower stands on top of its end
bc_center = bc_mid + arch_inset(end_arch) * dir(bc_angle + 90);

// Right-hand arches, then their mirror twins; the main one is on the axis
arch_centers = [[0, mm(y0 + arch_inset(main_arch)), 0],
                [ mm(cd_center[0]), mm(cd_center[1]), 0],
                [-mm(cd_center[0]), mm(cd_center[1]), 0],
                [ mm(bc_center[0]), mm(bc_center[1]), 0],
                [-mm(bc_center[0]), mm(bc_center[1]), 0],
                [0, mm(y0 + vault_y), 0]];                    // central chamber where the five vaults meet
arch_r = [mm(main_arch[2]), mm(side_arch[2]), mm(side_arch[2]), mm(end_arch[2]), mm(end_arch[2]), mm(vault_r)];
arch_z = [arch_stretch(main_arch), arch_stretch(side_arch), arch_stretch(side_arch),
          arch_stretch(end_arch),  arch_stretch(end_arch),  vault_peak / vault_r];

// --- Assembly ---
if (part != "pedestal") model();
if (part != "model" && with_pedestal)
    pedestal(points = footprint_points, margin = pedestal_margin, height = pedestal_height,
             chamfer = pedestal_chamfer, z_top = 0.02);

module model() {
    // Body + stepped relief, with the passages from the towers carved out of them
    difference() {
        union() {
            body(d1 = mm(d1), d2 = mm(d2), bh1 = mm(bh1), bh2 = mm(bh2), h = mm(platform_top),
                 cut_r = arch_r, cut_centers = arch_centers, cut_z_scale = arch_z, $fa = fa, $fs = fs);
            translate([0, 0, mm(platform_top) - 0.05])
                relief(points = [for (p = relief_outline()) mm2(p)], steps = relief_steps,
                       riser = mm(relief_riser), tread = mm(relief_tread));
        }
        mirrored() tower_exit_cut();
    }

    // Same border as the stairs, all around the platform, open where a stair or tower joins
    body_rim(d1 = mm(d1), d2 = mm(d2), bh1 = mm(bh1), bh2 = mm(bh2),
             z = mm(platform_top), rim_h = mm(wall_h_side), rim_t = mm(wall_t_side)) {
        mirrored() {
            flight_gap(front_top, front_heading, front_landing, front_width);
            tower_gap();
        }
        flight_gap(apex_top, apex_heading, apex_landing, apex_width);
    }

    // Tall wall along A-B, between the towers
    difference() {
        translate([-mm(B[0]), mm(y0), mm(platform_top) - 0.05])
            cube([2 * mm(B[0]), mm(wall_t_ab), mm(wall_top_ab - platform_top) + 0.05]);
        mirrored() tower_gap();
    }

    difference() {
        union() {
            mirrored() {
                flight(back_top,  back_heading,  back_landing,  back_run,  back_width,  back_rise,  back_steps);
                flight(front_top, front_heading, front_landing, front_run, front_width, front_rise, front_steps);
            }
            fan_flight(apex_top, apex_heading, apex_landing, apex_pad, apex_run, apex_width, apex_width_bot,
                       front_rise, front_steps, round(front_steps / 2), apex_land_len);
        }
        body_cuts(arch_r, arch_centers, arch_z, $fa = fa, $fs = fs);    // keep the vault clear
    }

    mirrored() back_tower();

    // Pillars: a pair at the head of each front stair, on the outer edges
    mirrored() stair_pillars(front_top, front_heading, front_width);
    stair_pillars(apex_top, apex_heading, apex_width);
}

// Points the pedestal has to cover: both sides of every flight and the corners of the body
function flight_pts(top, heading, landing, run, w0, w1) =
    let (a = dir(heading), n = dir(heading + 90))
    [top - landing * a + w0 / 2 * n, top - landing * a - w0 / 2 * n,
     top + run * a + w1 / 2 * n,     top + run * a - w1 / 2 * n];
function mm2(p) = [mm(p[0]), mm(p[1])];
right_pts = concat(flight_pts(back_top,  back_heading,  back_landing,  back_run,  back_width,  back_width),
                   flight_pts(front_top, front_heading, front_landing, front_run, front_width, front_width),
                   [B, C]);
footprint_points = concat(
    [for (p = right_pts) mm2(p)],
    [for (p = right_pts) mm2([-p[0], p[1]])],
    [for (p = flight_pts(apex_top, apex_heading, apex_landing, apex_pad + apex_run, apex_width, apex_width_bot)) mm2(p)],
    [mm2(D)]);

// A part plus its mirror twin across the YZ plane
module mirrored() {
    children();
    mirror([1, 0, 0]) children();
}

// A stair flight: `top` is the middle of the top step, `heading` points downhill
module flight(top, heading, landing, run, width, rise, steps) {
    translate([mm(top[0]), mm(top[1]), 0])
        rotate([0, 0, heading])
            translate([-mm(landing), 0, 0])
                stairs(total_height   = mm(rise),
                       top_len        = mm(landing),
                       base_len       = mm(landing + run),
                       width          = mm(width),
                       num_steps      = steps,
                       rail_height    = mm(parapet_h),
                       rail_thickness = mm(parapet_t),
                       landing_rail   = false);
}

// Same as flight(), but widening from w_top at the head to w_bot at the foot
module fan_flight(top, heading, landing, pad, run, w_top, w_bot, rise, steps, land_step, land_len) {
    translate([mm(top[0]), mm(top[1]), 0])
        rotate([0, 0, heading])
            translate([-mm(landing), 0, 0])
                fan_stairs(total_height   = mm(rise),
                           top_len        = mm(landing + pad),
                           run            = mm(run),
                           width_top      = mm(w_top),
                           width_bot      = mm(w_bot),
                           num_steps      = steps,
                           landing_step   = land_step,
                           landing_len    = mm(land_len),
                           rail_height    = mm(parapet_h),
                           rail_thickness = mm(parapet_t));
}

// The passage through a tower goes on inside the body: flat at the door level through the tower,
// then a short stair climbing to the platform. Subtracted from the body (the tower keeps its own slot).
exit_n = max(1, round(floor_raise / exit_riser));          // (floor_raise = 0 gives a flat passage)
module tower_exit_cut() {
    r  = floor_raise / exit_n;                          // exact step height
    ya = -tower_side / 2 - 0.3;                        // starts just outside the front face of the tower
    yb = tower_side / 2;                                // inner face of the tower
    z0 = deck_height;
    pts = concat(
        [[ya, z0], [yb, z0]],
        [for (i = [1 : exit_n]) each [[yb + (i - 1) * exit_tread, z0 + i * r],
                                      [yb + i * exit_tread,       z0 + i * r]]],
        [[yb + exit_n * exit_tread, platform_top + 1], [ya, platform_top + 1]]);
    translate([mm(tower_pos[0]), mm(tower_pos[1]), 0])
        rotate([0, 0, back_heading + 90])
            rotate([90, 0, 90])
                linear_extrude(height = mm(exit_width), center = true)
                    polygon([for (p = pts) [mm(p[0]), mm(p[1])]]);
}

// Opening in the platform border where a flight joins (as wide as the flight)
module flight_gap(top, heading, landing, width) {
    translate([mm(top[0]), mm(top[1]), -1])
        rotate([0, 0, heading])
            translate([-mm(landing), -mm(width) / 2, 0])
                cube([mm(landing + 0.5), mm(width), mm(20)]);
}

// Opening in the platform border under the tower
module tower_gap() {
    s = mm(tower_side + 0.4);
    translate([mm(tower_pos[0]), mm(tower_pos[1]), -1])
        rotate([0, 0, back_heading + 90])
            translate([-s / 2, -s / 2, 0])
                cube([s, s, mm(20)]);
}

// A pair of pillars flanking the head of a stair, standing on the platform
module stair_pillars(top, heading, width) {
    for (side = [-1, 1]) {
        p = top + side * (width / 2 - pillar_w / 2) * dir(heading + 90) - 0.15 * dir(heading);
        translate([mm(p[0]), mm(p[1]), mm(platform_top) - 0.05])
            rotate([0, 0, heading])
                pillar(size     = mm(pillar_w),
                       shaft_h  = mm(pillar_shaft),
                       cap_size = mm(pillar_cap_w),
                       cap_h    = mm(pillar_cap_h),
                       dome_h   = mm(pillar_dome_h),
                       ball_d   = mm(pillar_ball_d));
    }
}

// Tower at the top of the back stair, passage aligned with the flight
module back_tower() {
    side = mm(tower_side);
    roof = mm(tower_roof);

    translate([mm(tower_pos[0]), mm(tower_pos[1]), mm(deck_height)])
        rotate([0, 0, back_heading + 90])
            tower(height      = mm(tower_total) - roof,
                  size        = side,
                  slot_width  = mm(1.1),
                  slot_height = mm(1.5),
                  hole_d      = mm(1.1),
                  hole_z      = mm(1.65),
                  cap_h       = roof,
                  cap_r       = 0.813 * side,       // roof eaves = 1.15 * tower side
                  cornice_h   = mm(0.5),
                  cornice_out = mm(0.2));
}

// --- Check printout ---
function len2(p, q) = norm(p - q);
echo(AB = 2 * B[0], BC = len2(B, C), CD = len2(C, D), EC = 2 * C[0], depth = D[1] - y0);
echo(back_slope  = atan(back_rise / back_run),   back_steps  = back_steps);
echo(front_slope = atan(front_rise / front_run), front_steps = front_steps);
echo(tower_reach_on_BC = tower_reach, free_BC = bc_len - tower_reach);
echo(free_CD = upper_side - front_foot - apex_foot, apex_landing = apex_landing);
exit_end = tower_pos + (tower_side / 2 + exit_n * exit_tread) * dir(back_heading + 180);
echo(exit_steps = exit_n, exit_end_at = exit_end, relief_half_width = relief_w / 2);
echo(apex_width_bot = apex_width_bot, apex_riser = front_rise / front_steps, apex_tread = (apex_run - apex_land_len) / (front_steps - 1));
