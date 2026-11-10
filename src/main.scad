use <body.scad>
use <tower.scad>
use <back_stairs.scad>

// --- Body parameters ---
body_d1  = 24;
body_d2  = 4;
body_bh1 = 20;
body_bh2 = 8;
body_h   = 16;

// --- Tower placement ---
tower_scale = body_d2 / 2;                             // tower size follows the body
tower_rot   = atan(body_d2 / body_bh1);               // use -atan(body_d2 / body_bh1) to match the side exactly
tower_pos   = [body_d1 / 2 + body_d2 + 1.4, -7, body_h];

body(d1 = body_d1, d2 = body_d2, bh1 = body_bh1, bh2 = body_bh2, h = body_h);

rotate([0, 0, tower_rot])
    translate(tower_pos)
        scale(tower_scale)
            tower();
            
translate([14, -6, 0])            
    rotate([0, 0, 290])            
        scale(0.45)           
            back_stairs();