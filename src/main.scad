use <body.scad>
use <tower.scad>
use <stairs.scad>

// --- Print scale ---
model_scale = 200;                          // 1:200
function mm(m) = m * 1000 / model_scale;    // real metres -> model millimetres

// --- Measured on Google Earth (real metres) ---
long_side   = 17.53;                        // A-B
short_side  = 8.13;                         // B-C, mirrored to E-A
upper_side  = 9.81;                         // C-D, mirrored to D-E
back_run    = 10.0;                         // back stair, length
back_width  = 4.0;
front_run   = 14.0;                         // front stair, length
front_width = 2.9;

// --- Not measured: estimates, adjust when known (real metres / degrees) ---
corner_width = 18.62;                       // E-C, sets the pentagon shape (below 2 * upper_side)
back_splay   = 14;                          // outward angle from the side's normal, read off the sketch
front_splay  = 24;                          // same, front stair
deck_height  = 4.05;
stair_steps  = 27;
parapet_h    = 0.45;
parapet_t    = 0.30;
tower_side   = 3.0;
tower_total  = 6.0;                         // height above the deck, roof included
main_arch    = [8.0, 2.8, 4.6];             // opening width, opening height, vault radius
side_arch    = [5.0, 2.3, 3.5];

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
back_heading  = -90 + back_splay;
front_heading = cd_angle - 90 - front_splay;

// Middle of the top step: the outer edge of each flight starts at a corner
back_top  = B + back_width / 2 * dir(back_heading - 90);
front_top = C + front_width / 2 * dir(front_heading + 90);

// Landings reach back into the deck
back_landing  = tower_side;                               // the tower stands on it
front_landing = front_width * tan(front_splay) + 0.3;

// --- Arches ---
function arch_inset(a)   = sqrt(pow(a[2], 2) - pow(a[0] / 2, 2));  // vault center, inside the face
function arch_stretch(a) = 2 * a[1] / a[0];                        // vertical stretch

front_foot  = front_width / cos(front_splay);             // length of C-D taken by the stair
side_mid    = C + (front_foot + upper_side) / 2 * dir(cd_angle);
side_center = side_mid + arch_inset(side_arch) * dir(cd_angle + 90);

arch_centers = [[0, mm(y0 + arch_inset(main_arch)), 0],
                [ mm(side_center[0]), mm(side_center[1]), 0],
                [-mm(side_center[0]), mm(side_center[1]), 0]];
arch_r       = [mm(main_arch[2]), mm(side_arch[2]), mm(side_arch[2])];
arch_z       = [arch_stretch(main_arch), arch_stretch(side_arch), arch_stretch(side_arch)];

// --- Assembly ---
body(d1 = mm(d1), d2 = mm(d2), bh1 = mm(bh1), bh2 = mm(bh2), h = mm(deck_height),
     cut_r = arch_r, cut_centers = arch_centers, cut_z_scale = arch_z);

difference() {
    mirrored() {
        flight(back_top,  back_heading,  back_landing,  back_run,  back_width);
        flight(front_top, front_heading, front_landing, front_run, front_width);
    }
    body_cuts(arch_r, arch_centers, arch_z);    // keep the vault clear
}

mirrored() back_tower();

// A part plus its mirror twin across the YZ plane
module mirrored() {
    children();
    mirror([1, 0, 0]) children();
}

// A stair flight: `top` is the middle of the top step, `heading` points downhill
module flight(top, heading, landing, run, width) {
    translate([mm(top[0]), mm(top[1]), 0])
        rotate([0, 0, heading])
            translate([-mm(landing), 0, 0])
                stairs(total_height   = mm(deck_height),
                       top_len        = mm(landing),
                       base_len       = mm(landing + run),
                       width          = mm(width),
                       num_steps      = stair_steps,
                       rail_height    = mm(parapet_h),
                       rail_thickness = mm(parapet_t),
                       landing_rail   = false);
}

// Tower at the top of the back stair, passage aligned with the flight
module back_tower() {
    pos  = back_top - tower_side / 2 * dir(back_heading);
    side = mm(tower_side);
    roof = 0.36 * side;

    translate([mm(pos[0]), mm(pos[1]), mm(deck_height)])
        rotate([0, 0, back_heading + 90])
            tower(height      = mm(tower_total) - roof,
                  size        = side,
                  slot_width  = 0.40 * side,
                  slot_height = 0.50 * side,
                  hole_d      = 0.40 * side,
                  hole_z      = 0.44 * side,
                  cap_h       = roof,
                  cap_r       = 0.84 * side);
}

// --- Check printout ---
function len2(p, q) = norm(p - q);
echo(AB = 2 * B[0], BC = len2(B, C), CD = len2(C, D), EC = 2 * C[0], depth = D[1] - y0);
