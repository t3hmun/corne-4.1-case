

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

difference() {
  linear_extrude(5) offset(r=2) polygon(points=outline);
  translate([0, 0, 2]) linear_extrude(100) polygon(points=outline);
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
