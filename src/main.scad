use <body.scad>
use <tower.scad>
use <stairs.scad>

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
back_splay     = 23;                        // back stair: outward angle from the main axis (aerial photo ~19, front photo ~27)
front_fan      = 10;                        // front stair: outward angle from the main axis (they are almost parallel)
                                            //   was 24 deg off the C-D normal, i.e. ~42 deg in plan = the "45 degrees" problem
deck_height    = 4.0;                       // top of the back stairs = tower door sill
platform_raise = 1.9;                       // platform top above deck_height (front photo: wall top is ~2.3 m above the
                                            //   door sill, parapet included). 0 = flat deck like before
stair_riser    = 0.15;                      // step height, sets the number of steps
parapet_h      = 0.45;                      // border of the stairs AND of the platform
parapet_t      = 0.30;
tower_side     = 4.0;                       // = back_width, the tower is as wide as its stair
tower_total    = 8.3;                       // above the door sill, roof included
tower_roof     = 0.85;
main_arch      = [7.6, 3.9, 4.4];           // opening width, crown height, vault radius (A-B: semicircle)
side_arch      = [5.0, 3.4, 3.6];           // C-D and D-E
end_arch       = [3.6, 3.0, 2.6];           // B-C and E-A (the lateral sides)

platform_top = deck_height + platform_raise;

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

// Tower, centered on the back flight, front face on the top step
tower_pos = back_top - tower_side / 2 * dir(back_heading);

// --- Arches (one per side of the pentagon, like the real bridge) ---
function arch_inset(a)   = sqrt(pow(a[2], 2) - pow(a[0] / 2, 2));  // vault center, inside the face
function arch_stretch(a) = 2 * a[1] / a[0];                        // vertical stretch
for (a = [main_arch, side_arch, end_arch])
    assert(a[2] > a[0] / 2, "vault radius must be larger than half the opening width");

// C-D: the free part of the side, next to the front stair
front_foot = front_width / cos(front_mis);
cd_mid     = C + (front_foot + upper_side) / 2 * dir(cd_angle);
cd_center  = cd_mid + arch_inset(side_arch) * dir(cd_angle + 90);

// B-C: the free part of the side, past the tower
bc_len   = norm(C - B);
tower_reach = max([for (sa = [-1, 1], sb = [-1, 1])
    (tower_pos - B + sa * tower_side / 2 * dir(back_heading)
                   + sb * tower_side / 2 * dir(back_heading + 90)) * dir(bc_angle)]);
assert(end_arch[0] < bc_len - tower_reach, "end_arch is too wide for the free part of B-C");
bc_mid    = B + (tower_reach + bc_len) / 2 * dir(bc_angle);
bc_center = bc_mid + arch_inset(end_arch) * dir(bc_angle + 90);

// Right-hand arches, then their mirror twins; the main one is on the axis
arch_centers = [[0, mm(y0 + arch_inset(main_arch)), 0],
                [ mm(cd_center[0]), mm(cd_center[1]), 0],
                [-mm(cd_center[0]), mm(cd_center[1]), 0],
                [ mm(bc_center[0]), mm(bc_center[1]), 0],
                [-mm(bc_center[0]), mm(bc_center[1]), 0]];
arch_r = [mm(main_arch[2]), mm(side_arch[2]), mm(side_arch[2]), mm(end_arch[2]), mm(end_arch[2])];
arch_z = [arch_stretch(main_arch), arch_stretch(side_arch), arch_stretch(side_arch),
          arch_stretch(end_arch),  arch_stretch(end_arch)];

// --- Assembly ---
body(d1 = mm(d1), d2 = mm(d2), bh1 = mm(bh1), bh2 = mm(bh2), h = mm(platform_top),
     cut_r = arch_r, cut_centers = arch_centers, cut_z_scale = arch_z, $fa = fa, $fs = fs);

// Same border as the stairs, all around the platform, open where a stair or tower joins
body_rim(d1 = mm(d1), d2 = mm(d2), bh1 = mm(bh1), bh2 = mm(bh2),
         z = mm(platform_top), rim_h = mm(parapet_h), rim_t = mm(parapet_t)) {
    mirrored() {
        flight_gap(front_top, front_heading, front_landing, front_width);
        tower_gap();
    }
}

difference() {
    mirrored() {
        flight(back_top,  back_heading,  back_landing,  back_run,  back_width,  back_rise,  back_steps);
        flight(front_top, front_heading, front_landing, front_run, front_width, front_rise, front_steps);
    }
    body_cuts(arch_r, arch_centers, arch_z, $fa = fa, $fs = fs);    // keep the vault clear
}

mirrored() back_tower();

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
