use <body.scad>
use <tower.scad>
use <stairs.scad>

// --- Print scale ---
model_scale = 150;                          // 1:150
function mm(m) = m * 1000 / model_scale;    // real metres -> model millimetres

// Dimensions are given in real metres. They are rough estimates, not survey data.

// --- Body ---
body_d1  = mm(4.8);
body_d2  = mm(0.8);                         // long side = 2 * (d1 - d2) = 8 m
body_bh1 = mm(4.0);
body_bh2 = mm(1.6);
body_h   = mm(4.05);                        // deck height

// --- Arches ---
arch_r       = mm(2.2);
arch_centers = [[0, mm(-2.0), 0], [mm(2.0), mm(0.4), 0], [mm(-2.0), mm(0.4), 0]];
arch_stretch = 1.27;                        // vertical stretch (1 = spherical)

// --- Back stairs ---
stair_width = mm(3.0);
stair_run   = mm(8.75);                     // horizontal length of the flight
stair_steps = 27;                           // 15 cm rise each
stair_angle = 20;                           // outward splay from the -Y axis (deg)

// --- Parapets ---
parapet_h = mm(0.45);
parapet_t = mm(0.30);

// --- Tower ---
tower_side  = stair_width;                  // the tower sits on the stair landing
tower_total = mm(6.0);                      // height above the deck, roof included
tower_roof  = 0.36 * tower_side;
tower_xy    = [mm(3.6), mm(-1.95)];         // center of tower and landing

// --- Assembly ---
body(d1 = body_d1, d2 = body_d2, bh1 = body_bh1, bh2 = body_bh2, h = body_h,
     cut_r = arch_r, cut_centers = arch_centers, cut_z_scale = arch_stretch);

back_unit();                    // right stair and tower
mirror([1, 0, 0]) back_unit();  // left twin, mirrored across the YZ plane

// One back flight with its tower
module back_unit() {
    difference() {
        back_stairs();
        body_cuts(arch_r, arch_centers, arch_stretch);    // keep the vault clear
    }
    back_tower();
}

// Back flight: the landing is centered on tower_xy, the steps go outward
module back_stairs() {
    translate([tower_xy[0], tower_xy[1], 0])
        rotate([0, 0, 270 + stair_angle])
            translate([-tower_side / 2, 0, 0])
                stairs(total_height   = body_h,
                       top_len        = tower_side,
                       base_len       = tower_side + stair_run,
                       width          = stair_width,
                       num_steps      = stair_steps,
                       rail_height    = parapet_h,
                       rail_thickness = parapet_t,
                       landing_rail   = false);
}

// Tower on top of the landing, passage aligned with the flight
module back_tower() {
    translate([tower_xy[0], tower_xy[1], body_h])
        rotate([0, 0, stair_angle])
            tower(height      = tower_total - tower_roof,
                  size        = tower_side,
                  slot_width  = 0.40 * tower_side,
                  slot_height = 0.50 * tower_side,
                  hole_d      = 0.40 * tower_side,
                  hole_z      = 0.44 * tower_side,
                  cap_h       = tower_roof,
                  cap_r       = 0.84 * tower_side);
}
