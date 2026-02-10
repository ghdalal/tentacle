// =============================================================
// THE TENTACLE - FINAL CONSOLIDATED ASSEMBLY
// =============================================================
// Overview
// - Unified assembly at 1/3 scale (design units ~ mm / 3)
// - Y is used as the vertical axis for receptacles and pivoting
// - Logical components: A) Base plate, B) Spine & extension, C) Top receptacle, D) Hanging bin
//
// Conventions & intent
// - $fn: controls smoothness for circle/hull operations used by the spine
// - Constants are grouped by component and include a short rationale for future edits
// =============================================================

$fn = 120; // Use high resolution so hull() between sampled circles is smooth

// --- GLOBAL CONSTANTS (with rationale) -------------------------
// Base plate: provides the fixed footprint and structural anchor
BASE_X       = 30.00; // X-length of the base plate: tuned to achieve 30mm unified breadth
BASE_Y       = 7.50;  // Y-thickness of the base plate: thin support to save material and weight
BASE_Z       = 30.00; // Z-depth (height) of the base plate extrusion
COG_X        = 14.00; // X coordinate used as the assembly center-of-geometry (aligns receptacle)

// Top receptacle (Component C): socket that receives/houses pivot area for hanging bin
REC_X        = 7.50;  // X-size of socket: sized to center on `COG_X` and match gridface proportions
REC_Y        = 7.50;  // Y-depth of socket: tuned for reliable seating while keeping material minimal
REC_Z        = 30.00; // Z-height of receptacle: matches base extrusion so stacking/clearance is consistent
REC_START_Y  = 55.00; // Y origin where the receptacle base is positioned in assembly coordinates

// Hanging bin (Component D): Gridfinity-derived dimensions and pivot placement
GRID_1x_SCALED  = 14.00; // Scaled 1x Gridfinity cell (42mm / 3) – used for face alignment and quick reference
GRID_2x_SCALED  = 28.00; // Scaled 2x Gridfinity cell (84mm / 3) – used when referencing bin length
BIN_BREADTH     = 30.00; // Visual breadth of the bin to harmonize with base breadth and clearances
D_PIVOT_X       = 10.25; // Local pivot X (edge-aligned to top receptacle): chosen to place hinge at socket edge
D_PIVOT_Y       = 62.00; // Pivot Y offset: slide the pivot upward from REC_START_Y to alter hang geometry (55 + 7)

// Spine sampling and thickness
SPINE_T      = 7.50; // Diameter of sampled circles along the bezier path; controls spine stiffness and appearance

// Bezier path control points: define the 2D trajectory of the spine in plan (X, Y)
p0 = [29.95, 3.75]; // Start near the base plate edge to anchor the spine
p1 = [49.00, 3.75]; // Pull the curve out along X to shape the base sweep
p2 = [49.00, 59.00]; // Lift the curve in Y to create the shoulder under the receptacle
p3 = [14.00, 59.00]; // End point positions the path beneath the top receptacle for a natural join

// Cubic Bezier interpolation used to sample many small circles along the spine path
function bezier(t, p0, p1, p2, p3) = 
    pow(1-t, 3)*p0 + 3*pow(1-t, 2)*t*p1 + 3*(1-t)*pow(t, 2)*p2 + pow(t, 3)*p3;

// --- COMPONENT A: BASE PLATE ---
color("SteelBlue") {
    cube([BASE_X, BASE_Y, BASE_Z]);
}

// --- COMPONENT B: UNIFIED C-SPINE & EXTENSION ---
color("DarkOrange") {
    linear_extrude(height = BASE_Z) { 
        difference() {
            for (t = [0 : 0.01 : 0.99]) {
                hull() {
                    translate(bezier(t, p0, p1, p2, p3)) circle(d = SPINE_T);
                    translate(bezier(t + 0.01, p0, p1, p2, p3)) circle(d = SPINE_T);
                }
            }
            // Socket for Top Receptacle
            translate([COG_X - (REC_X/2), REC_START_Y]) square([REC_X, REC_Y]);
            // Top Terminal Cut
            translate([-50, REC_START_Y + REC_Y]) square([200, 20]);
            // Ground Guard
            translate([-50, -50]) square([200, 50]);
        }
    }
}

// --- COMPONENT C: TOP RECEPTACLE ---
color("ForestGreen") {
    translate([COG_X - (REC_X/2), REC_START_Y, 0.00]) {
        cube([REC_X, REC_Y, REC_Z]);
    }
}

// --- COMPONENT D: BOTTOM-ALIGNED HANGING RECEPTACLE (HARD VALUES) ---
// ALIGNMENT: Bottom of D meets Bottom of C (Y=55.00)
// PIVOT: X=10.25 (Edge of C), Y=55.00 (Base of C)
// ROTATION: -45 Degrees

color("gray") {
    // Pivot anchored at the bottom-edge of the top receptacle
    translate([10.25, 55.00, 0]) { 
        rotate([0, 0, -45]) {
            // Internal shift: 
            // -7.00 (Local X) centers the 14mm face on the pivot
            // -28.00 (Local Y) ensures the bin hangs BELOW the pivot line
            translate([-7.00, -28.00, 0]) {
                cube([14.00, 28.00, 30.00]);
            }
        }
    }
}

// ALIGNMENT: Compensates for the -7.00mm shift in Component D
// COLOR: Pink for visibility

color("Pink") {
    linear_extrude(height = 30.00) {
        polygon(points = [
            [10.25, 55.00],                   // 1. Pivot (Vertex)
            [10.25, 62.50],                   // 2. Top of Green Bin (55 + 7.5)
            
            // 3. CORRECTED CONTACT POINT:
            // We use 7.5 / sin(45) to find the hypotenuse length 
            // required to hit the top-height (62.5) along the 45° slope.
            // Result: [4.95, 60.30]
            [10.25 - 4.95, 55.00 + 4.95] 
        ]);
    }
}

