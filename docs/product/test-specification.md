# Tentacle Test Specification

## 4. Test Case Scenarios (Physical Validation)

### 4.1 TC-01: Critical Dimensional Verification
Purpose: Confirm printed part remains within tolerance on major dimensions.

- Inputs/Tools: Calipers, angle gauge
- Steps:
  1. Measure overall height, footprint width/depth, base height.
  2. Verify 45 deg hanging receptacle angle.
  3. Record deviation from nominal.
- Acceptance Criteria: All measured values within +/-0.5 mm (except angle tolerance as defined by measurement capability).
  - Angle tolerance: 45 deg +/- 1 deg.

### 4.2 TC-02: Interface Fitment (Gridfinity Modules)
Purpose: Validate receptacle interoperability and insertion usability.

- Inputs/Tools: Known-good Gridfinity modules (2x2x1 and 2x1x1)
- Steps:
  1. Insert modules into base, hanging, and top receptacles.
  2. Confirm no excessive force is required.
  3. Check seated position and removal behavior.
- Acceptance Criteria: Modules fully seat, remain retained in expected orientation, and can be removed without binding.
  - Seating force must be < 5 N.

### 4.3 TC-03: Static Load Capacity
Purpose: Confirm payload capacity and structural integrity.

- Inputs/Tools: Incremental weights up to 200 g
- Steps:
  1. Apply staged load in 50 g increments up to 200 g.
  2. Hold at maximum load for 10-30 minutes.
  3. Inspect for permanent deformation or crack initiation.
- Acceptance Criteria: No structural failure, no permanent deformation affecting intended function.

### 4.4 TC-04: Stability and Tip Resistance
Purpose: Verify center-of-gravity behavior under realistic loading.

- Inputs/Tools: Typical module payload distribution
- Steps:
  1. Populate base, hanging, and top receptacles with representative items.
  2. Place on flat surface and apply light handling disturbances.
  3. Observe rocking, drift, or tipping tendencies.
- Acceptance Criteria: No tipping in nominal use conditions; acceptable stability during light interaction.
  - Stability requirement: must not tip at a 15 deg tilt.
