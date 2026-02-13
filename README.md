# Tentacle: A Parametric Verticality Study
> **Ecosystem:** [Gridfinity](https://gridfinity.xyz/) | **Engine:** OpenSCAD | **Release Status:** `v0.3.3-alpha`

---

## 1.0 System Abstract
The **Tentacle** is a high-density, vertical storage solution designed to reclaim desk real estate within the Gridfinity ecosystem. By employing a high-density mixed loading pattern, it transitions tools from a horizontal footprint into a vertically accessible arc.

### 1.1 Core Specifications
* **Pitch:** Standard 42mm Gridfinity base compatibility.
* **Logic:** Parametric OpenSCAD source allowing for modular scaling ($s_{33}$, $s_{50}$, $s_{100}$).
* **Orientation:** Engineered gravity-assisted tool retention via curved geometry.

---

## 2.0 Design Validation
The project follows a "Vision-to-Validation" pipeline. Each revision is rendered for intent and then printed at scale to verify structural tolerances.

| 0.1 Design Intent (Concept Render) | 0.2 Physical Validation (s33 Prototype) |
| :--- | :--- |
| <img src="docs/assets/vision/tentacle-vision.png" width="450" alt="Tentacle Vision Render" /> | <img src="docs/assets/vision/tentacle-s33.jpg" alt="Tentacle s33 Physical Prototype" /> |

---

## 3.0 Repository Architecture
This repository is organized as a manufacturing pipeline. Files flow from logical definitions (`src/`) through validation (`templates/`) to immutable artifacts (`output/`).

```text
.
├── docs/           # Specifications, Naming Audits, & Assets
├── src/            # Parametric OpenSCAD source files
├── templates/      # JSON Schemas and QC Checklists
└── output/prints/  # Immutable Print-Ready Artifacts (STLs/3MFs)
