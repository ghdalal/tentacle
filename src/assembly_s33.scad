// THE TENTACLE - RECONCILED 1:1 WIDTH
// SCALE: 1/3rd (1:3) | AXIS: Y-UP
// STATUS: Top Receptacle increased to 30mm to match Spine/Base
//
// FILE OVERVIEW
// This file builds a base plate, a C-shaped spine, and a top receptacle.
// The spine is a 2D bezier path in XY, then extruded along +Z to full width.
//
// COORDINATE SYSTEM
// UNITS: millimeters
// ORIGIN: base plate corner at [0,0,0]
// AXES: +X is length, +Y is forward/up-plane in the drawing, +Z is height
//
// VISUALIZATION
// Colors are for visual inspection only; they do not affect geometry.

$fn = 120; // render resolution for circles (higher = smoother); tuned for smooth hulls

// =============================================================================
// GLOBAL DIMENSIONS (PRIMARY ENVELOPE)
// =============================================================================
BASE_X       = 30.00; // base plate length along +X; establishes overall footprint
BASE_Y       = 7.50;  // base plate thickness along +Y; provides stiffness under spine
BASE_Z       = 30.00; // base plate height along +Z; matches spine + receptacle height
COG_X        = 14.00; // reference X for center alignment; keeps receptacle centered

// =============================================================================
// RECEPTACLE C (TOP SOCKET)
// =============================================================================
// Width increased to match BASE_Z for a flush top profile.
REC_X        = 7.50;  // receptacle width along +X; sized to match spine thickness
REC_Y        = 7.50;  // receptacle depth along +Y; keeps socket compact
REC_Z        = 30.00; // Updated from 27.00 to 30.00 (matches BASE_Z)
REC_START_Y  = 55.00; // Y position where receptacle begins; aligns with spine cap

// =============================================================================
// SPINE DIMENSIONS
// =============================================================================
SPINE_BASE_T = 7.50; // starting diameter near base; allows a subtle entry taper
SPINE_T      = 7.50; // diameter for the rest of the spine; constant after taper

// =============================================================================
// SPINE PATH (C-BEZIER CENTERLINE)
// =============================================================================
// Path logic - P0 [29.95, 3.75] for robust overlap
// The points create a gentle C profile: forward, then up, then back to center.
p0 = [29.95, 3.75];    // near base plate; ensures overlap with the base footprint
p1 = [49.00, 3.75];    // forward extension; sets the C's outer reach
p2 = [49.00, 59.00];   // vertical climb; sets the top height and curvature
p3 = [14.00, 59.00];   // terminal point aligned to receptacle centerline

// =============================================================================
// CURVE EVALUATION
// =============================================================================
// Cubic bezier interpolation for the 2D spine path.
// The path is 2D in XY and later extruded along +Z.
function bezier(t, p0, p1, p2, p3) = 
    pow(1-t, 3)*p0 + 3*pow(1-t, 2)*t*p1 + 3*(1-t)*pow(t, 2)*p2 + pow(t, 3)*p3;

// =============================================================================
// COMPONENT A: BASE PLATE
// =============================================================================
color("SteelBlue") {
    cube([BASE_X, BASE_Y, BASE_Z]);
}

// =============================================================================
// COMPONENT B: C-SPINE
// =============================================================================
color("DarkOrange") {
    // Extruded to full 30mm width
    linear_extrude(height = BASE_Z) {
        // Subtractive "clipping planes" are done with oversized squares below.
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

// =============================================================================
// COMPONENT C: TOP RECEPTACLE
// =============================================================================
color("ForestGreen") {
    // Perfectly flush with the 30mm spine and base
    // REC_X is centered on COG_X via (COG_X - REC_X/2).
    translate([COG_X - (REC_X/2), REC_START_Y, 0.00]) {
        cube([REC_X, REC_Y, REC_Z]);
    }
}

// =============================================================================
// VALIDATION DATUM (DEBUG VISUAL)
// =============================================================================
// Debug-only alignment line through the receptacle center (ghosted with %)
// The % modifier renders only in preview to avoid boolean side effects.
% color("red") translate([COG_X, -5, 15]) cube([0.1, 85, 0.1], center=true);
