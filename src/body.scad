$fa = 1;
$fs = 0.4;
// Module definition
module body(d1, d2, bh1, bh2, h) {
    // Points
    p0 = [d2, 0];
    p1 = [0, bh1];
    p2 = [d1, bh1 + bh2];
    p3 = [d1 + d1, bh1];
    p4 = [d1 + d1 - d2, 0];
    points = [p0, p1, p2, p3, p4];
    // Base extrusion
    translate([-d1,-(d1 + d2) * 0.5,0])
        linear_extrude(height=h)
            polygon(points);
}

/*body(
    d1 = 24,
    d2 = 4,
    bh1 = 20,
    bh2 = 8,
    h = 16
);*/