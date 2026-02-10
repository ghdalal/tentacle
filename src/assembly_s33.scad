// =============================================================
// THE TENTACLE - FINAL ASSEMBLY (RESTORED FLUSH BASE)
// =============================================================
// Overview
// - Final consolidated assembly, designed at 1/3 scale (project convention)
// - Coordinate convention: Y is vertical for receptacles/pivots; X is lateral
// - File organizes the assembly into reusable modules: base, spine, receptacle,
//   hanging bin, and wedge. Constants at the top drive geometry so edits are localized.
//
// Documenting constants: each constant below includes a short rationale that
// explains its role, the reason for the chosen value, and the component(s) that
// depend on it. Keep these rationales up-to-date when changing geometry.
// =============================================================

$fn = 1200; // Circle resolution: very high to keep hull()-generated spine smooth

// --- STANDARDIZED CONSTANTS -----------------------------------
// U: primary modular unit used across the design. Choosing a single base unit
// makes scaling and derived dimensions predictable. Here U=14 corresponds to
// the project's 1x Gridfinity face at 1/3 scale (42mm / 3).
U            = 14.00;
// Half_U, Two_U: derived conveniences to avoid repeated arithmetic and to make
// intent obvious when used in modules (half-widths, double-heights, etc.).
Half_U       = U / 2;
Two_U        = U * 2;

// COG_X: center-of-geometry X coordinate used for aligning receptacles/spine
// over the base. Setting it to `U` places the COG one modular unit from the
// origin, which matches the lateral layout used elsewhere in the assembly.
COG_X        = U;

// BASE_Z: vertical extrusion depth for base components. Using Two_U keeps the
// base height proportional to the modular unit and gives enough Z clearance
// for the spine/receptacle geometry to intersect cleanly.
BASE_Z       = Two_U; 

// --- EPSILON / FIT TUNING -------------------------------------
// Small offsets and overlap values used to ensure clean boolean joins and
// predictable mechanical fit without leaving hairline gaps due to floating
// precision and STL/CSG edge cases.
OVERLAP      = 0.10;  // Small positive overlap used where two bodies meet to avoid gaps

// Shared cavity / wall thickness defaults
WALL  = 1.20; // Typical wall thickness for printed parts at this scale (matches material tolerances)
FLOOR = 1.20; // Base floor thickness used for cavities and bins
LIP   = 0.00; // Optional lip value left zero by default; adjust if a retaining lip is required
EPS_Y = 0.05; // Small vertical epsilon to prevent coplanar face issues in boolean operations

// DATUM_Y: assembly datum in Y used as the baseline for receptacles and pivot
// placement. This keeps pivot-related values and receptacle positions consistent.
DATUM_Y      = 55.25; 

// Pivot location for the hanging bin (Component D). D_PIVOT_X is expressed as
// an offset from the `COG_X` to tie hinge placement logically to the top
// receptacle's center. Using `(COG_X - U/4)` positions the pivot slightly
// interior to the receptacle edge to achieve the desired hang angle.
D_PIVOT_X    = (COG_X - U/4);
D_PIVOT_Y    = DATUM_Y; // Tie pivot Y directly to the assembly datum for consistency

// ---------------------------------------------------------------
// Notes on editing
// - Prefer changing `U` to rescale the assembly; many values derive from it.
// - Use small EPSILON values (`OVERLAP`, `EPS_Y`) when adjusting boolean joins.
// - Keep $fn high if you rely on hull()+circle sampling for visual smoothness;
//   lowering $fn speeds render but may reveal faceting on the spine.
// =============================================================

// ---------------- HELPERS ----------------

function bezier(t, p0, p1, p2, p3) = 
    pow(1-t, 3)*p0 + 3*pow(1-t, 2)*t*p1 + 3*(1-t)*pow(t, 2)*p2 + pow(t, 3)*p3;

module debug_color(debug, default_color) {
    color(debug ? [1, 0, 0, 0.5] : default_color) 
        children();
}

// ---------------- MODULES ----------------

module component_base(show=true, debug=false) {
    if (show) {
        BASE_X = Two_U;           
        BASE_Y = Half_U;           
        debug_color(debug, "SteelBlue")
            cube([BASE_X, BASE_Y, BASE_Z]);
    }
}

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

module component_receptacle(show=true, debug=false) {
    if (show) {
        debug_color(debug, "ForestGreen")
        translate([COG_X - (Half_U/2), DATUM_Y - OVERLAP, 0]) 
            cube([Half_U, Half_U + OVERLAP, Two_U]);
    }
}

module component_hanging_bin(show=true, debug=false) {
    if (show) {
        debug_color(debug, "gray")
        translate([D_PIVOT_X, D_PIVOT_Y, 0]) 
            rotate([0, 0, -45])
                translate([-Half_U, -Two_U, 0])
                    cube([U, Two_U, Two_U]);
    }
}

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