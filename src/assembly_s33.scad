// THE TENTACLE - RECONCILED 1:1 WIDTH
// SCALE: 1/3rd (1:3) | AXIS: Y-UP
// STATUS: Top Receptacle increased to 30mm to match Spine/Base
// UNITS: millimeters

$fn = 120; // render resolution for circles (higher = smoother)

// --- GLOBAL CONSTANTS ---
BASE_X       = 30.00; // base plate length along +X
BASE_Y       = 7.50;  // base plate thickness along +Y
BASE_Z       = 30.00; // base plate height along +Z
COG_X        = 14.00; // reference X for center-of-geometry / receptacle alignment

// Receptacle C (Width increased to match BASE_Z)
REC_X        = 7.50;  // receptacle width along +X
REC_Y        = 7.50;  // receptacle depth along +Y
REC_Z        = 30.00; // Updated from 27.00 to 30.00 (matches BASE_Z)
REC_START_Y  = 55.00; // Y position where receptacle begins

// --- SPINE DIMENSIONS ---
SPINE_BASE_T = 7.50; // starting diameter near base
SPINE_T      = 7.50; // diameter for the rest of the spine

// Path control points (X,Y) for the C-spine centerline
// Path logic - P0 [29.95, 3.75] for robust overlap
p0 = [29.95, 3.75];    // near base plate
p1 = [49.00, 3.75];    // forward extension
p2 = [49.00, 59.00];   // vertical climb
p3 = [14.00, 59.00];   // terminal point aligned to receptacle

// Cubic bezier interpolation for the 2D spine path
function bezier(t, p0, p1, p2, p3) = 
    pow(1-t, 3)*p0 + 3*pow(1-t, 2)*t*p1 + 3*(1-t)*pow(t, 2)*p2 + pow(t, 3)*p3;

// --- COMPONENT A: BASE PLATE ---
// Color tags are for visual inspection only; they do not affect geometry.
color("SteelBlue") {
    cube([BASE_X, BASE_Y, BASE_Z]);
}

// --- COMPONENT B: C-SPINE ---
color("DarkOrange") {
    // Extruded to full 30mm width
    linear_extrude(height = BASE_Z) {
        difference() {
            // SMOOTHING ENGINE: Sequential Hull
            // Step size 0.01 => ~100 segments along the bezier
            for (t = [0 : 0.01 : 0.99]) {
                hull() {
                    // Taper only across the first 30% of the path
                    d1 = (t < 0.3) ? 
                          SPINE_BASE_T - (t/0.3)*(SPINE_BASE_T - SPINE_T) : 
                          SPINE_T;
                    translate(bezier(t, p0, p1, p2, p3)) circle(d = d1);
                    
                    next_t = t + 0.01;
                    // Match taper at the next step to keep the hull smooth
                    d2 = (next_t < 0.3) ? 
                          SPINE_BASE_T - (next_t/0.3)*(SPINE_BASE_T - SPINE_T) : 
                          SPINE_T;
                    translate(bezier(next_t, p0, p1, p2, p3)) circle(d = d2);
                }
            }
            
            // ABSOLUTE TERMINATION: Capped exactly at the bin interface (Y=55)
            translate([-10, REC_START_Y]) square([120, 50]);
            
            // Ground Plane Guard: trims anything below Y=0
            translate([-10, -50]) square([120, 50]);
        }
    }
}

// --- COMPONENT C: TOP RECEPTACLE ---
color("ForestGreen") {
    // Perfectly flush with the 30mm spine and base
    translate([COG_X - (REC_X/2), REC_START_Y, 0.00]) {
        cube([REC_X, REC_Y, REC_Z]);
    }
}

// --- VALIDATION DATUM ---
// Debug-only alignment line through the receptacle center (ghosted with %)
% color("red") translate([COG_X, -5, 15]) cube([0.1, 85, 0.1], center=true);
