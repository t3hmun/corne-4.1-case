
//
// CONFIG VALUES
//

// Some of these are fudge value some might just be different for your board.

// Extra inside space for the PCB. My board doesn't fit in the proper measurements, tolerances? This makes it a bit bigger all around.
extra = 1;
// Wall thickness
edge = 1;
// Height under the PCB 
tray_th = 2;
// Max height of components, PCB rest height
comp_gap = 3;
// Thickness of the grid the switches click into
grid_th = 1.2;
// The full height
wall_h = tray_th + comp_gap + grid_th;
// Minimum thickness of PCB
pcb_th = 1.5;
// Post radius, the posts that hold the PCB in place
post_radius = (5 - 0.5) / 2;
// Part of the post that the PCB rests on, has to be small enough not to hit any components
post_rest_radius_extra = 0.8;
// Post should stay under the surface of the PCB
post_height = tray_th + comp_gap + pcb_th;
// How much trss sticks out over the PCB
trss_top_th = 1;

//
// VALUES DERIVED FROM DRAWING
//

// All the dimensions in https://github.com/foostan/crkbd/blob/main/README.md 
// Actual image: https://github.com/foostan/crkbd/assets/736191/87ebea53-3c5c-42a1-97b3-f9292e4dacae

k = 19.05; // Key spacing, 19.05mm is the standard Cherry MX key spacing

// These are the steps between the columns at the top
s2 = 4.763; // Step after the first 2 keys
s3 = 2.381; // Step after the third key
s4 = -s3; // Step after the fourth, fifth and sixth key
s5 = -s3; // Step after the fourth, fifth and sixth key
s6 = -s3; // Step after the fourth, fifth and sixth key

a = 11.94; // Tilt for the bottom keys, same tilt twice

//
// PCB OUTLINE
//

// Calculated coorinates

trx = 7 * k; // top right x
try = 3 * k + s2 + s3 + s4 + s5 + s6; // top right y

// The bottom coordinates after 0,0 (negative y) anti-clockwise calculated off one another. 

bx1 = 3 * k;
by1 = 0;

bx2 = bx1 + 0.5 * k;
by2 = by1 - k + s2 + s3 + s4 + s5;

bx3 = bx2 + k + cos(a) * k;
by3 = by2 - sin(a) * k;

bx4 = bx3 + cos(2 * a) * k;
by4 = by3 - sin(2 * a) * k;

brx = trx;
bry = by4 + (tan(90 - 2 * a) * (brx - bx4)); // bottom rightest y, calculated making a right angle triangle that is 2 * a from vertical, theta is the distance between brx and bx4.

// This is the left hand keyboard
outline = [
  [0, 0], // Bottom left corner working clokwise \/
  [0, 3 * k],
  [2 * k, 3 * k],
  [2 * k, 3 * k + s2],
  [3 * k, 3 * k + s2],
  [3 * k, 3 * k + s2 + s3],
  [4 * k, 3 * k + s2 + s3],
  [4 * k, 3 * k + s2 + s3 + s4],
  [5 * k, 3 * k + s2 + s3 + s4],
  [5 * k, 3 * k + s2 + s3 + s4 + s5],
  [6 * k, 3 * k + s2 + s3 + s4 + s5],
  [6 * k, 3 * k + s2 + s3 + s4 + s5 + s6],
  [trx, try],

  [brx, bry], // Bottom rightest corner (not bottomest)
  [bx4, by4], // Bottomest right corner
  [bx3, by3],
  [bx2, by2],
  [bx1, by1],
  [0, 0], // Bottom left corner working anti-clockwise /\
];

// Tray is the pcb outline slightly expanded for tolerances, otherwise it doesn't fit.
module tray() {
  // Delta causes sharp corners, r would round them, which is not a good fit for a pcb
  offset(delta=extra) polygon(points=outline);
}

difference() {
  linear_extrude(wall_h) offset(r=edge + extra) polygon(points=outline); // Make a large block, offset to make walls around the pcb 
  // Cut out the space inside
  intersection() {
    translate([0, 0, tray_th - 0.01]) linear_extrude(wall_h - tray_th + 0.02) tray();

    union() {
      translate([0, 0, 0.2]) linear_extrude(20) offset(delta=-2) tray();
      translate([-10, -50, tray_th + comp_gap]) cube([200, 200, 100]);
      translate([55, -13, -10]) cube([20, 20, 100]);
      translate([0, 10, -10]) cube([10, 5, 50]);
      translate([0, 29, -10]) cube([10, 5, 50]);
      translate([0, 48, -10]) cube([10, 5, 50]);
      translate([trx - 20, try - 20, -10]) cube([100, 100, 50]);
      translate([trx - 10, try - 40, -10]) cube([100, 10, 50]);
      translate([trx - 10, try - 57, -10]) cube([100, 11, 50]);
    }
  }
  // Base pattern cutout
  difference() {
    translate([0, 0, -0.01]) linear_extrude(tray_th + 0.01) tray();
    trayPattern(tray_th); // Cut the tray pattern into to block that is being subtracted
  }
  //USB port cutout
  translate([trx - 15 + extra, try - 5, tray_th - 0.01]) cube([15, 10 + 2, comp_gap + 0.2]);
  //TRSS port cutout
  translate([trx + edge + extra - edge - 0.01, try - 47 - 10, tray_th]) cube([edge + 0.02, 10, comp_gap + trss_top_th]);
}

// Posts clockwise from bottom left
px1 = k;
py1 = k;
px2 = k;
py2 = 2 * k;
px3 = 5 * k;
py3 = 2 * k + s2 + s3 + s4 + (s5 / 2);
px4 = 5 * k;
py4 = 0 + s2 + s3 + s4 + s5;

module post(x, y) {
  union() {
    translate([x, y, 0]) cylinder(r=post_radius, h=post_height, $fn=feat_smoothness);
    translate([x, y, 0]) cylinder(r=post_radius + post_rest_radius_extra, h=tray_th + comp_gap, $fn=feat_smoothness);
  }
}

post(px1, py1);
post(px2, py2);
post(px3, py3);
post(px4, py4);

/* 
# TODO
- [x] Add a cool cutout pattern to bottom tray
- [x] Add in the 4 posts locator PCB
- [x] Add in supports under posts
- [x] Test print a thin version of the bottom tray and test fit - seems ok, made the mistake of using r intstead of delta, so the rounded inside corner get in the way.
- [ ] Add in extra supports around the board edge
    - A 2mm edge with gaps for the usb, trss and crystal, 1mm edge on left, no space around the sockets

- [ ] Find out the thickness of switch plate
- [ ] Proto part of the switch plate to test fit

*/

//
// # Everything below is just patterns put into the base to make it use less filament and look nice
//

feat_smoothness = 32;
feat_thick = 1.2;

module stencil(r, h) {
  difference() {
    cylinder(h=h, r=r, $fn=feat_smoothness);
    translate([0, 0, -h]) difference() {
        cylinder(h=h * 3, r=r - feat_thick, $fn=feat_smoothness);
        translate([0, 0, -2 * h]) cylinder(h=h * 4, r=r / 4 * 3, $fn=feat_smoothness);
      }
    translate([0, 0, -h]) difference() {
        cylinder(h=h * 3, r=r / 4 * 3 - feat_thick, $fn=feat_smoothness);
        translate([0, 0, -2 * h]) cylinder(h=h * 4, r=r / 4 * 2, $fn=feat_smoothness);
      }
    translate([0, 0, -h]) difference() {
        cylinder(h=h * 3, r=r / 4 * 2 - feat_thick, $fn=feat_smoothness);
        translate([0, 0, -2 * h]) cylinder(h=h * 4, r=r / 4 * 1, $fn=feat_smoothness);
      }
    translate([0, 0, -h]) difference() {
        cylinder(h=h * 3, r=r / 4 * 1 - feat_thick, $fn=feat_smoothness);
        //translate([0,0,-2*h]) cylinder(h=h*4, r=r/4*1, $fn=feat_smoothness);
      }
    translate([r, -r / 2, -h]) cylinder(h=h * 3, r=r, $fn=feat_smoothness);
    translate([-r, -r / 2, -h]) cylinder(h=h * 3, r=r, $fn=feat_smoothness);
    translate([0, -r, -h]) cylinder(h=h * 3, r=r, $fn=feat_smoothness);
  }
}

module seigaiha_grid(r, h) {
  vrep = 15;
  hrep = 15;
  translate([-hrep / 2 * r, -vrep / 2 * r])for (row = [0:vrep]) {
    translate([0, row * r, 0]) {
      stencil(r, h);
      for (col = [0:hrep]) {
        translate([col * r, (col % 2) * (r / 2), 0]) stencil(r, h);
      }
    }
  }
}

// This is meant to be cut out of cut out a tray shaped block (which is then cut out of the tray) so it is much bigger top and bottom
module trayPattern(th) {
  translate([0, 0, -1]) intersection() {
      linear_extrude(th + 2) tray();
      //cube(10,10,10);
      translate([60, 0, 0]) seigaiha_grid(10, th + 2);
    }
}
