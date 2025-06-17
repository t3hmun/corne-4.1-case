

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

// Calculated coorinates

trx = 7 * k; // top right x
try = 3 * k + s2 + s3 + s4 + s5 + s6; // top right y

// The bottom coordinates after 0,0 anti-clockwise calculated off one another. 

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

// My board doesn't fit in the proper measurements, tolerances? This makes it a bit bigger all around.
extra = 1;

edge = 1;
tray_th = 1;
wall_h = 2;

module tray() {
  // Delta causes sharp corners, r would round them, which is not a good fit for a pcb
  offset(delta=extra) polygon(points=outline);
}

difference() {
  linear_extrude(wall_h) offset(r=edge + extra) polygon(points=outline);
  difference() {
    translate([0, 0, -0.01]) linear_extrude(100) tray();
    trayPattern(); // Cut the tray pattern into to block that is being subtracted
  }
  translate([trx + edge + extra - 24, try + edge + extra - 15, tray_th]) cube([24.01, 15.01, wall_h - tray_th + 0.01]);
  translate([trx + edge + extra - edge - 0.01, try - 45 - 15, tray_th]) cube([edge + 0.02, 15.01, wall_h - tray_th + 0.01]);
}

/* 
# TODO
- [ ] Add a cool cutout pattern to bottom tray
- [ ] Add in the 4 posts locator PCB
- [ ] Add in supports under posts
- [ ] Test print a thin version of the bottom tray and test fit
- [ ] Add in extra supports around the board edge
    - A 2mm edge with gaps for the usb, trss and crystal, 1mm edge on left, no space around the sockets

- [ ] Find out the thickness of switch plate
- [ ] Proto part of the switch plate to test fit

*/

feat_smoothness = 18;
feat_thick = 1.2;

radius = 43 - 0.2; // total outer radius - a little bit so that it fits - these designs seem to expand a bit
height = 5;

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
  vrep = 10;
  hrep = 10;
  translate([-hrep / 2 * r, -vrep / 2 * r])for (row = [0:vrep]) {
    translate([0, row * r, 0]) {
      stencil(r, h);
      for (col = [0:hrep]) {
        translate([col * r, (col % 2) * (r / 2), 0]) stencil(r, h);
      }
    }
  }
}

module trayPattern() {
  translate([0, 0, -5 + tray_th]) intersection() {
      linear_extrude(5) tray();
      //cube(10,10,10);
      translate([60, 0, 0]) seigaiha_grid(15, height);
    }
}
