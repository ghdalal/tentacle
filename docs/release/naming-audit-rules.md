# Naming Audit Rules and Project Governance

This document establishes the structural requirements, naming conventions, and governance policies for the OpenSCAD design repository. These rules ensure consistency across physical manufacturing outputs, documentation assets, and automated audit processes.

## Table of Contents

* [Project Structure and Roots](#project-structure-and-roots)
* [Naming Conventions: Source Development](#naming-conventions-source-development)
* [Naming Conventions: Published Releases](#naming-conventions-published-releases)
* [Naming Conventions: Documentation Assets](#naming-conventions-documentation-assets)
* [Blessed File Formats](#blessed-file-formats)
* [Governance Rules](#governance-rules)
* [Summary and Next Steps](#summary-and-next-steps)

---

## Project Structure and Roots

The repository is organized into distinct root directories based on the lifecycle of the files. All contributors must adhere to this top-level hierarchy to maintain compatibility with automation scripts.
Canonical root structure is defined in `docs/release/versioning.md` Section 5.

* **Documentation Root (`docs/`):** All long-form documentation, user guides, and the coffee table book project assets reside here.
* **Source Root (`src/`):** This is the workspace for active development. Only OpenSCAD files and immediate design logic belong in this folder.
* **Templates Root (`templates/`):** Contains reusable OpenSCAD modules and configuration templates that are not variant-specific.
* **Release Root (`output/prints/`):** The canonical location for every finalized version intended for 3D printing or archival.

### Rule: docs root (Failure)
`docs/` MUST exist and is the canonical documentation root.

### Rule: src root (Failure)
`src/` MUST exist and is the source development root.

### Rule: templates root (Failure)
`templates/` MUST exist and is the shared template root.

### Rule: output prints root (Failure)
`output/prints/` MUST exist and is the release root.

---

## Naming Conventions: Source Development

Source development focuses on variant isolation. Each unique design iteration or component family is treated as a "variant."

* **Variant Directories:** Located at `src/<variant>/`. Folders must be strictly lowercase and use kebab-case (e.g., `src/tentacle-base/`).
* **Shared Modules:** `src/common/` is reserved for shared modules and helpers and is not a variant.
* **Dynamic Entrypoint Naming:** Every variant must have a primary assembly file following the pattern `src/<variant>/assembly_<variant>.<ext>`.
* *Example:* For the folder `src/s33/`, the entry file must be `assembly_s33.<ext>`.
* **Isolation Policy:** Files within a variant folder should only reference local files or the `templates/` directory to prevent cross-variant dependencies.

### Rule: variant directory format (Failure)
Variant directories under `src/` (excluding `src/common/`) MUST be lowercase kebab-case.

### Rule: variant entry file (Failure)
Each variant directory MUST contain `assembly_<variant>.<ext>` where `<variant>` matches the directory name.

### Rule: src entrypoints location (Failure)
No `.scad` files are allowed directly under `src/`. Entrypoints must live under `src/<variant>/`.

---

## Naming Conventions: Published Releases

The `output/prints/` directory serves as the historical record for the project. Naming here is highly regulated to allow for regex-based auditing.
This audit focuses on naming and minimal structure; full scope artifact requirements live in `docs/release/versioning.md`.

### Revision Folders

Every release is contained within a revision folder named using the following regex: `print-\d{8}-r\d+-(prototype|physical|online|production)`.

* **Format:** `print-YYYYMMDD-rNN-[scope]`
* **Revision ID:** `print-YYYYMMDD-rNN-[scope]`
* **Example:** `print-20260213-r01-prototype`

### Rule: revision folder format (Failure)
Revision folder names MUST follow `print-YYYYMMDD-rNN-[scope]`.

### Rule: revision folder regex (Failure)
Revision folder names MUST match `print-\d{8}-r\d+-(prototype|physical|online|production)`.

### Rule: revision scope values (Failure)
Allowed scope values are `prototype`, `physical`, `online`, and `production`.

### Rule: revision id match (Failure)
Every revision MUST include `metadata.json` with `revision_id` matching the folder name.

### Internal Revision Structure

### Rule: revision subfolders (Failure)
Every revision MUST include `source/`. Non-prototype revisions MUST include `tests/`.

* **Source Folder:** Located at `output/prints/<revision>/source/`. This contains the "frozen" assets for that specific revision.
* **High-Fi Renders:** `render_iso.<ext>` and `render_side.<ext>`.
* **Quick Previews:** `preview_iso.<ext>` and `preview_side.<ext>`.

### Rule: render preview names (Failure)
`source/` MUST contain `render_iso.<ext>`, `render_side.<ext>`, `preview_iso.<ext>`, and `preview_side.<ext>`.

### Rule: render preview views (Failure)
Both render and preview sets MUST include `iso` and `side` views.

* **Test Results:** Located at `output/prints/<revision>/tests/` when required by scope.

### Rule: tests subfolders (Failure)
Only `online/` and `physical/` are allowed under `tests/`.

### Rule: tests scope gating (Failure)
* `prototype`: `tests/` MUST NOT exist.
* `physical`: `tests/physical/` required, `tests/online/` forbidden.
* `online`: `tests/online/` required, `tests/physical/` forbidden.
* `production`: both `tests/online/` and `tests/physical/` required.

### Rule: online test results (Failure)
`tests/online/` MUST include `online-tests-results.json` and `result-extract.zip`.

### Rule: physical test results (Failure)
`tests/physical/` MUST include `physical-tests-results.json`.

---

## Naming Conventions: Documentation Assets

Assets intended for the "The Tentacle" coffee table book or GitHub READMEs must be mirrored to the central documentation directory to keep the release folder immutable.

* **Vision Images:** Stored in `docs/assets/vision/` and named `vision-<suffix>.<ext>`.
* **Gallery Renders:** Stored in `docs/assets/renders/` following the pattern `<variant>-<release>-<view>-<type>.*`.
* **Technical Drawings:** Stored in `docs/assets/drawings/` following the pattern `<variant>-<release>-<view>-<type>.*`.

### Rule: docs assets subfolders (Warning)
Only `docs/assets/vision/`, `docs/assets/renders/`, and `docs/assets/drawings/` are allowed under `docs/assets/`.

### Rule: vision default name (Failure)
Vision filenames MUST include a suffix and follow `vision-<suffix>.<ext>`.

### Rule: vision v2 name (Failure)
If the vision changes materially, the filename SHOULD be updated to a new suffix (for example, `vision-v2.png`).

### Rule: docs renders pattern (Failure)
Renders MUST follow `<variant>-<release>-<view>-<type>.<ext>` and be lowercase.

### Rule: docs drawings pattern (Failure)
Drawings MUST follow `<variant>-<release>-<view>-<type>.<ext>` and be lowercase.

---

## Blessed File Formats (Warning)

To prevent repository bloat and ensure cross-platform compatibility, only "Blessed" formats are permitted. Files using unapproved extensions will trigger a **Naming Audit Warning**.

| Category | Approved Extensions |
| --- | --- |
| **CAD & Code** | `.scad` |
| **Geometry** | `.stl`, `.step`, `.3mf` |
| **Visuals** | `.png`, `.jpg`, `.jpeg`, `.webp` |
| **Data & Archives** | `.json`, `.zip` |

Entrypoint files under `src/<variant>/assembly_<variant>.<ext>` are exempt from the extension list.
Vision assets under `docs/assets/vision/` may use additional image extensions when needed.
Violations of blessed formats are warnings, not failures.

---

## Governance Rules

These rules define the mandatory behaviors for all files and folders within the project ecosystem.

* **Immutability (Failure):** Once a folder is published under `output/prints/`, its contents are finalized. They MUST NOT be modified, renamed, or replaced. Any changes require a new revision number (`rNN`).
* **Case Protocol (Failure):** All files and folders under `output/prints/` MUST be lowercase.
* **Asset Mirroring (Failure):** Documentation images must be moved from the `source/` folder of a revision to `docs/assets/` if they are to be used in external documentation. Active source files (`src/`) must never store final documentation images.

### Rule: prints lowercase (Failure)
No uppercase characters are allowed in any file or folder name under `output/prints/`.

---

## Summary and Next Steps

This document provides the single source of truth for the project's organization. By adhering to these naming audit rules, we ensure that "The Tentacle" project remains scalable and that every 3D printed part can be traced back to its specific OpenSCAD source and test results.

**Immediate Next Steps:**

1. Review existing folders in `output/prints/` for compliance with the lowercase and regex rules.
2. Standardize the entrypoint naming in the `src/` directory to match the variant folder names.
3. Configure CI/CD linting to flag any "Non-Blessed" file formats.
