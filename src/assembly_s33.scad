// THE TENTACLE - RECONCILED 1:1 WIDTH
// SCALE: 1/3rd (1:3) | AXIS: Y-UP
// STATUS: Top Receptacle increased to 30mm to match Spine/Base

$fn = 120;

// --- GLOBAL CONSTANTS ---
BASE_X       = 30.00; 
BASE_Y       = 7.50;  
BASE_Z       = 30.00; 
COG_X        = 14.00; 

// Receptacle C (Width increased to match BASE_Z)
REC_X        = 7.50; 
REC_Y        = 7.50;  
REC_Z        = 30.00; // Updated from 27.00 to 30.00
REC_START_Y  = 55.00; 

// --- SPINE DIMENSIONS ---
SPINE_BASE_T = 7.50; 
SPINE_T      = 7.50; 

// Path logic - P0 [29.95, 3.75] for robust overlap
p0 = [29.95, 3.75];    
p1 = [49.00, 3.75];    
p2 = [49.00, 59.00];  
p3 = [14.00, 59.00];  

function bezier(t, p0, p1, p2, p3) = 
    pow(1-t, 3)*p0 + 3*pow(1-t, 2)*t*p1 + 3*(1-t)*pow(t, 2)*p2 + pow(t, 3)*p3;

// --- COMPONENT A: BASE PLATE ---
color("SteelBlue") {
    cube([BASE_X, BASE_Y, BASE_Z]);
}

// --- COMPONENT B: C-SPINE ---
color("DarkOrange") {
    // Extruded to full 30mm width
    linear_extrude(height = BASE_Z) {
        difference() {
            // SMOOTHING ENGINE: Sequential Hull
            for (t = [0 : 0.01 : 0.99]) {
                hull() {
                    d1 = (t < 0.3) ? 
                          SPINE_BASE_T - (t/0.3)*(SPINE_BASE_T - SPINE_T) : 
                          SPINE_T;
                    translate(bezier(t, p0, p1, p2, p3)) circle(d = d1);
                    
                    next_t = t + 0.01;
                    d2 = (next_t < 0.3) ? 
                          SPINE_BASE_T - (next_t/0.3)*(SPINE_BASE_T - SPINE_T) : 
                          SPINE_T;
                    translate(bezier(next_t, p0, p1, p2, p3)) circle(d = d2);
                }
            }
            
            // ABSOLUTE TERMINATION: Capped exactly at the bin interface (Y=55)
            translate([-10, REC_START_Y]) square([120, 50]);
            
            // Ground Plane Guard
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
% color("red") translate([COG_X, -5, 15]) cube([0.1, 85, 0.1], center=true);