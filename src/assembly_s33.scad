// =============================================================
// THE TENTACLE - FINAL ASSEMBLY (RESTORED FLUSH BASE)
// =============================================================
// Overview
// - Final consolidated assembly built at 1/3 scale (project standard)
// - Coordinate system: Y is vertical (receptacles/pivots), X is lateral
// - Modular organization: base, spine, receptacle, hanging bin, and wedge
// - Each constant is documented with its role and justification; module
//   descriptions explain the geometry and mechanical intent of each part.
//
// Design philosophy
// - U (14mm) is the primary modular unit; derive others from U to scale cleanly
// - Epsilon values manage floating-precision and STL/CSG edge cases
// - Modules can be shown/hidden and color-coded for debugging
// =============================================================

$fn = 1200;  // Circle resolution for smooth hull() sampling of spine curve
$fs = 0.2;   // Fast surface resolution (smaller = finer, affects render time)
$fa = 1;     // Fast angle resolution (smaller = more segments, smoother curves)

// --- STANDARDIZED CONSTANTS (derived from primary unit U) ----
// U: primary modular unit at 1/3 scale. U=14 corresponds to the project's
// 1x Gridfinity face (42mm / 3). All major dimensions derive from U to ensure
// proportional scaling: a single change to U scales the entire assembly.
U            = 14.00;

// Half_U, Two_U: derived helpers used throughout modules to avoid repeated
// arithmetic and express intent clearly (e.g., "Half_U" means half-width,
// "Two_U" means full height). Using these keeps the code more readable.
Half_U       = U / 2;       // 7.00 – used for socket depths, pivot offsets
Two_U        = U * 2;       // 28.00 – used for base height, bin dimensions

// COG_X: center-of-geometry X coordinate used to center and align major
// assembly features (receptacle socket, spine path). Setting it to U aligns
// lateral geometry to the modular grid; receptacles are positioned relative
// to this point so they remain centered if U changes.
COG_X        = U;           // 14.00 – centerline for receptacle/socket alignment

// BASE_Z: vertical depth (Z direction) of the base and spine extrusions.
// Using Two_U ensures proportional height relative to the base breadth and
// provides sufficient clearance for the spine/receptacle join to resolve cleanly.
BASE_Z       = Two_U;       // 28.00 – full assembly Z height for stacking

// --- EPSILON / FIT TUNING (boolean join and clearance tuning) ----
// These small values compensate for floating-point precision, STL artifacts,
// and CSG edge cases. Use them when two bodies must meet without gaps or
// when slight overlaps are needed for clean unions/differences.

// OVERLAP: positive offset applied where bodies meet (e.g., spine and
// receptacle). A small overlap (0.1) ensures the CSG operation produces
// a watertight model without hairline gaps that cause faceting or voids.
OVERLAP      = 0.10;        // Applied at spine-receptacle and receptacle-base joins

// WALL, FLOOR: typical thickness values for printed parts at this scale.
// These ensure sufficient material for structural integrity and may be used
// as future defaults if cavities are added to components.
WALL         = 1.20;        // Wall thickness for enclosed cavities (not yet used)
FLOOR        = 1.20;        // Floor thickness for bin bottoms (not yet used)
LIP          = 0.00;        // Retaining lip offset; zero by default (can enable if needed)

// EPS_Y: small vertical offset to avoid coplanar face issues in boolean
// operations. Some facets may cause rendering artifacts if they lie exactly
// on the same plane; a tiny shift (0.05) prevents Z-fighting.
EPS_Y        = 0.05;        // Prevents coplanar face issues in spine-receptacle interface

// --- ASSEMBLY DATUMS (reference points for coordinate placement) ----
// DATUM_Y: assembly datum in Y that serves as the baseline for receptacle
// and pivot placement. All Y-positioned features are defined relative to
// DATUM_Y, so a single change aligns the entire receptacle assembly.
DATUM_Y      = 55.25;       // Receptacle base Y coordinate (pin point for all Y offsets)

// D_PIVOT_X, D_PIVOT_Y: placement of the hanging bin pivot point.
// D_PIVOT_X is offset from COG_X (by -U/4) to position the hinge slightly
// interior to the receptacle edge, achieving the desired -45° hang angle.
// D_PIVOT_Y ties to DATUM_Y to keep the pivot at the receptacle datum.
D_PIVOT_X    = (COG_X - U/4);    // 10.50 – pivot X (interior to receptacle)
D_PIVOT_Y    = DATUM_Y;          // 55.25 – pivot Y (tied to assembly datum)

// --- EDITING GUIDELINES ----
// When adjusting geometry:
// 1. Prefer changing U to rescale proportionally; many values derive from it.
// 2. Use OVERLAP and EPS_Y to fix gaps or faceting in boolean operations.
// 3. DATUM_Y controls the receptacle/pivot Y placement globally.
// 4. Each module can be toggled on/off via the show parameter for debugging.
// ============================================================

// --- HELPER FUNCTIONS AND UTILITIES ---

// bezier(t, p0, p1, p2, p3): cubic Bézier interpolation
// Evaluates a cubic Bézier curve at parameter t ∈ [0, 1] given four control
// points (p0, p1, p2, p3). Used to sample a smooth 2D path for the spine curve
// in the X-Y plane; the spine is then hull()ed with circles to form a solid.
function bezier(t, p0, p1, p2, p3) = 
    pow(1-t, 3)*p0 + 3*pow(1-t, 2)*t*p1 + 3*(1-t)*pow(t, 2)*p2 + pow(t, 3)*p3;

// debug_color(debug, default_color): conditional coloring module
// If debug=true, renders children in semi-transparent red [1,0,0,0.5] for
// visual inspection; otherwise uses default_color. Useful for isolating and
// inspecting individual components during CAD review.
module debug_color(debug, default_color) {
    color(debug ? [1, 0, 0, 0.5] : default_color) 
        children();
}

// --- MODULE DEFINITIONS (each provides show/debug toggles) ---

// component_base(show, debug): structural foundation
// Description
// - A thin rectangular plate that anchors the entire assembly.
// - Dimensions: BASE_X (Two_U × 28mm) in breadth, BASE_Y (Half_U × 7mm) in
//   thickness, BASE_Z (Two_U × 28mm) in height.
// - Color: SteelBlue (when debug=false); red highlight (when debug=true).
// Geometry role
// - Provides the footprint and reference datum for X/Y placement.
// - The spine and receptacle are positioned and joined relative to this base.
module component_base(show=true, debug=false) {
    if (show) {
        BASE_X = Two_U;           
        BASE_Y = Half_U;           
        debug_color(debug, "SteelBlue")
            cube([BASE_X, BASE_Y, BASE_Z]);
    }
}

// component_spine(show, debug): curved structural member connecting base to receptacle
// Description
// - A rounded, extruded curve that forms the primary structural spine.
// - Sampled using hull() of circles along a cubic Bézier curve (4 control points).
// - The spine sweeps from the base outward, curves upward, and terminates beneath
//   the receptacle for a clean mechanical join.
// - Color: DarkOrange (standard) or red (debug mode).
// Geometry role
// - Provides the curved connection between the base plate and the top receptacle.
// - The socket cavity (for receptacle housing) is cut from the spine interior.
// - Sampling step is adaptive: $preview mode uses 0.05 (coarser) for speed,
//   while final rendering uses 0.01 (finer) for smooth hulls.
module component_spine(show=true, debug=false) {
    if (show) {
        SPINE_T      = Half_U;     

        p0 = [Two_U, 3.75];     
        p1 = [3.5 * U, 3.75];     
        p2 = [3.5 * U, 59.00];    
        p3 = [U, 59.00];        
        
        debug_color(debug, "DarkOrange")
        linear_extrude(height = Two_U) { 
            difference() {
                step = $preview ? 0.05 : 0.01;
                for (t = [0 : step : 1 - step]) {
                    hull() {
                        translate(bezier(t, p0, p1, p2, p3)) circle(d = SPINE_T);
                        translate(bezier(t + step, p0, p1, p2, p3)) circle(d = SPINE_T);
                    }
                }
                
                // Keep Receptacle overlap for clean junction
                translate([COG_X - (U/4), DATUM_Y + OVERLAP]) square([Half_U, Half_U]);
                
                translate([-50, DATUM_Y + Half_U]) square([200, 20]);
                
                // UNDONE: Bottom cut is back to flush at Y=0
                translate([-50, -50]) square([200, 50]);
            }
        }
    }
}

// component_receptacle(show, debug): top socket housing for bin pivot
// Description
// - A cubic cavity that sits atop the spine and accepts the hanging bin's pivot.
// - Dimensions: Half_U × Half_U in X-Y (7mm × 7mm), Two_U in Z (28mm height).
// - Positioned at COG_X (centered) and DATUM_Y (assembly datum).
// - Color: ForestGreen (standard) or red (debug mode).
// Geometry role
// - Acts as the mechanical socket for the hanging bin's pivot point.
// - Slightly overlapped with the spine ($overlap) for a clean CSG join.
// - Provides a stable seating surface and alignment reference.
module component_receptacle(show=true, debug=false) {
    if (show) {
        debug_color(debug, "ForestGreen")
        translate([COG_X - (Half_U/2), DATUM_Y - OVERLAP, 0]) 
            cube([Half_U, Half_U + OVERLAP, Two_U]);
    }
}

// component_hanging_bin(show, debug): articulated storage bin
// Description
// - A rectangular bin that pivots -45° from the receptacle socket.
// - Dimensions: U × Two_U in base (14mm × 28mm), Two_U in height (28mm).
// - Pivot point anchored at D_PIVOT_X/D_PIVOT_Y (10.5, 55.25).
// - Color: gray (standard) or red (debug mode).
// Geometry role
// - The functional payload component: hangs from the assembly via the pivot.
// - Rotation of -45° is achieved via rotate([0, 0, -45]).
// - The local translation adjusts the bin's position relative to the pivot
//   to achieve the desired hanging geometry and clearances.
module component_hanging_bin(show=true, debug=false) {
    if (show) {
        debug_color(debug, "gray")
        translate([D_PIVOT_X, D_PIVOT_Y, 0]) 
            rotate([0, 0, -45])
                translate([-Half_U, -Two_U, 0])
                    cube([U, Two_U, Two_U]);
    }
}

// component_wedge(show, debug): bracing triangle
// Description
// - A triangular brace that visually/structurally connects the pivot to the receptacle.
// - Forms a right triangle with vertices at the pivot point, receptacle top edge,
//   and a point along the 45° slope (matching the bin's hang angle).
// - Color: Pink (standard, for visibility) or red (debug mode).
// Geometry role
// - Provides visual balance and optional bracing geometry.
// - The BRACE length is derived from Half_U * sin(45°) for geometric consistency.
// - Currently shown=false in the final assembly; can be toggled for strength or aesthetics.
module component_wedge(show=true, debug=false) {
    if (show) {
        BRACE        = Half_U * sin(45);

        debug_color(debug, "Pink")
        linear_extrude(height = BASE_Z) {
            polygon(points = [
                [D_PIVOT_X, D_PIVOT_Y],
                [D_PIVOT_X, DATUM_Y + Half_U],
                [D_PIVOT_X - BRACE, D_PIVOT_Y + BRACE] 
            ]);
        }
    }
}

// ---------------- FINAL ASSEMBLY ----------------

difference() {
    showAll=true;
    union() {
        component_base(show=showAll||false, debug=false);
        component_spine(show=showAll||true, debug=false); 
        component_receptacle(show=showAll||true, debug=false);
        component_hanging_bin(show=showAll||false, debug=false);
        component_wedge(show=showAll||false, debug=false); 
    }
}