# Tentacle Release Versioning and Governance

## 0. Authority
- This document is the Single Source of Truth (SSoT) for release governance and versioning rules.
- `docs/README.md` is a portal; if a conflict exists, this document prevails.

## 1. Revision Identity
- Revision folder format: `output/prints/print-YYYYMMDD-rNN-[scope]/`
- Revision ID format: `print-YYYYMMDD-rNN-[scope]`
- `rNN` is globally monotonic across all scopes.
- Tag format for future releases: `sXX-rNN` (example: `s33-r01`).
  - `XX` is the variant (for example, `s33`, `s50`).
  - Tags are immutable pointers into history and must never be reused.
  - Legacy tags may use `T-rNN` and remain valid for existing releases.

## 2. History Integrity
- Git history is append-only after the first tag.
- Forbidden operations: rebase, amend, force-push, tag reuse.

## 3. Definitions
- Revision: a frozen, published snapshot of artifacts and, when applicable, test evidence.
- Published: a revision folder exists under `output/prints/` and is populated for its scope.
- Scope: a per-revision classification defining validation requirements.
- Scope Purity: required and forbidden artifact rules enforced per scope.

Allowed scope values:

| scope      | meaning                                               | tests directory |
|------------|--------------------------------------------------------|-----------------|
| prototype  | design iteration only                                  | forbidden       |
| physical   | printed and physically evaluated                       | required        |
| online     | digital validation only                                | required        |
| production | final candidate; must satisfy both physical and online | required        |

Scope MAY change between revisions. Scope is per revision, not per branch.

## 4. Immutability and New Revision Triggers

### 4.1 Immutability
Once published:
- Files SHALL NOT be edited, replaced, or deleted.
- Test data SHALL NOT be modified.

Any correction requires publishing a new revision.

### 4.2 Mandatory New Revision Conditions
A new revision MUST be created if any of the following changes:
- Source content (any file inside `source.zip`)
- Derived artifacts (renders, previews)
- Generated STL (`model.stl`)
- Slicer file (`slicer.3mf`)
- Printer hardware used (physical/production)
- Test results JSON
- Measurements
- Photographs (including retakes)
- Scope designation
- Metadata content

If traceability, reproducibility, or validation changes, publish a new revision.

### 4.3 Re-testing Policy
If a previously printed object is re-measured or re-evaluated (even without geometry change), this SHALL be recorded as a new revision.

## 5. Canonical Folder Structure (Minimal Depth)
All folder and file names SHALL be strict lowercase.

```
output/
  prints/
    print-YYYYMMDD-rNN-[scope]/

      metadata.json

      source/
        source.zip
        render_iso.png
        render_side.png
        preview_iso.png
        preview_side.png

      model.stl              (required for physical/online/production; forbidden for prototype)
      slicer.3mf             (required for physical/production; forbidden for prototype/online)

      tests/                 (forbidden for prototype)

        online/              (required only for online and production)
          result-extract.zip
          online-tests-results.json

        physical/            (required only for physical and production)
          front.jpg
          left.jpg
          right.jpg
          iso.jpg
          top.jpg
          back.jpg
          bottom.jpg
          physical-tests-results.json
```

## 6. File Requirements by Scope

### 6.1 Prototype Scope (`prototype`)
Required:
- `metadata.json`
- `source/source.zip`
- `source/render_iso.png`
- `source/render_side.png`
- `source/preview_iso.png`
- `source/preview_side.png`

MUST NOT exist:
- `model.stl`
- `slicer.3mf`
- `tests/`

### 6.2 Physical Scope (`physical`)
Required:
- All prototype-required artifacts
- `model.stl`
- `slicer.3mf`
- `tests/physical/` full photo set
- `tests/physical/physical-tests-results.json`

MUST NOT exist:
- `tests/online/`

### 6.3 Online Scope (`online`)
Required:
- All prototype-required artifacts
- `model.stl`
- `tests/online/result-extract.zip`
- `tests/online/online-tests-results.json`

MUST NOT exist:
- `slicer.3mf`
- `tests/physical/`

### 6.4 Production Scope (`production`)
Required:
- All prototype-required artifacts
- `model.stl`
- `slicer.3mf`
- `tests/online/result-extract.zip`
- `tests/online/online-tests-results.json`
- `tests/physical/` full photo set
- `tests/physical/physical-tests-results.json`

## 7. Rendering and Preview Requirements
- `source/render_*.png` SHALL correspond to OpenSCAD F6 renders.
- `source/preview_*.png` SHALL correspond to OpenSCAD F5 previews.

Both categories MUST include:
- `*_iso.png` - isometric view
- `*_side.png` - side view

All four images are mandatory for every revision.

## 8. STL and Slicer Derivation Rules

### 8.1 STL Requirement
- `model.stl` SHALL be required for `physical`, `online`, and `production`.
- `model.stl` SHALL be forbidden for `prototype`.

### 8.2 Slicer Requirement
- `slicer.3mf` SHALL be required for `physical` and `production`.
- `slicer.3mf` SHALL be forbidden for `prototype` and `online`.

### 8.3 Derivation Constraint
If `slicer.3mf` exists:
- It SHALL be derived from `model.stl`.
- `model.stl` SHALL represent the exact geometry used for slicing.

## 9. Test Capture Requirements

### 9.1 Online Testing
Required files:
- `tests/online/result-extract.zip`
- `tests/online/online-tests-results.json`

Online testing SHALL NOT include physical measurements.

### 9.2 Physical Testing
Required files:
- `front.jpg`
- `left.jpg`
- `right.jpg`
- `iso.jpg`
- `top.jpg`
- `back.jpg`
- `bottom.jpg`
- `physical-tests-results.json`

Photo rules:
- Raw captures required.
- Cropping allowed.
- Minor color correction allowed.
- Full set required for all physical revisions, including failures.
- Retakes require new revision.

## 10. JSON Standards

### 10.1 Timestamp Format
All timestamps stored in JSON SHALL be ISO 8601 UTC.

Example:
```
2026-02-12T18:25:43Z
```

### 10.2 Schema Versioning
All test result JSON files SHALL include:
```
schema_version
```
Schema changes SHALL increment `schema_version`.

## 11. metadata.json Requirements
`metadata.json` is mandatory for every revision.

Required fields:
- `revision_id` (string; must match folder name)
- `publication_date_utc` (string; ISO 8601 UTC)
- `scope` (string; one of `prototype`, `physical`, `online`, `production`)
- `previous_revision` (string or null)
- `description` (string)
- `git_tag` (string; `sXX-rNN` for future releases, legacy `T-rNN` allowed)
- `git_commit` (string; 7-40 hex)

Additional required promotion fields:
- `promoted_from` (string or null)
- `promotion_reason` (string or null)
- `override_reason` (string or null; required only for `physical -> production` exceptions)

`override_reason` valid values:
- `Emergency Field Repair`
- `Legacy Validation Carryover`
- `Component Criticality: Low`

`parameter_delta`:
- Required when online assumptions differ from physical assumptions.
- Structure: `{ "param_name": { "from": <value>, "to": <value> } }`
- `<value>` may be a number, string, boolean, or null.

No checksum enforcement required.
No deprecation flag required.

## 12. Source Archive Policy (`source.zip`)
- `source.zip` SHALL contain all files necessary to reproduce the model and derived artifacts.
- Dependencies and assets SHALL be included.
- `source.zip` SHALL be treated as the authoritative source snapshot for that revision.

## 13. Printer Hardware Rule
If printer hardware changes (even with identical `model.stl` and `slicer.3mf`), a new revision SHALL be published. Printer identity SHALL be recorded in `physical-tests-results.json`.

Hardware changes requiring a new physical revision:
- Nozzle diameter
- Hotend or extruder components
- Cooling modifications
- Major firmware type changes (for example, Marlin -> Klipper)

## 14. Branching Policy
Parallel experimentation SHALL occur outside:

```
output/prints/
```

Example:
```
work/
  experiment-spine/
  experiment-pivot/
```

Working branches:
- May change freely.
- Are not revision-numbered.
- Are not published artifacts.

Publishing from branches:
1. Assign next global revision number.
2. Create revision folder under `output/prints/`.
3. Copy finalized artifacts into the revision folder.
4. Publish and freeze permanently.

If multiple branches are ready simultaneously, publish them as separate sequential revisions. Publication order defines revision order.

## 15. complete.flag Semantics
- Written last by the Windows publish script.
- Required before GAS ingestion.
- Indicates artifact freeze, not evidence completion.
- Immutability set:
  - `metadata.json`
  - `model.stl`
  - `slicer.3mf`
  - `source/`
- `tests/*` evidence may be appended after `complete.flag`.
- Evidence append window: maximum 48 hours after `complete.flag` is written.
- Policy enforcement:
  - Validate script issues a warning if evidence is appended after 48 hours.
  - A hard fail occurs only if a CODEOWNER has already finalized `status = passed`.
- Evidence append authorization: any contributor may append evidence within the window.

## 16. Revision Creation vs Promotion
- `prototype -> physical` is a source-to-artifact transition and is a new revision without lineage requirements.
- Promotion is strictly the path: `physical -> online -> production`.
- Promotion always creates a new revision. Ancestor revisions are never edited.
- Promotion gate: Sheet `status` must be `ready_to_promote`.
- If ancestor `status` is not `passed`, mandatory confirmation is required.
- Workflow details: see [promotion-policy.md](promotion-policy.md).

### 16.1 Exception: `physical -> production`
- Default: not allowed.
- Exception requires all of the following:
  - `metadata.json.override_reason` is populated.
  - A CODEOWNER provides explicit approval recorded in the ledger.
  - The production revision sets:
    - `promoted_from = physical_revision_id`
    - `physical_ancestor_revision_id = physical_revision_id`
    - `online_ancestor_revision_id = null`

## 17. Lineage Fields
### 17.1 online revision metadata
- `promoted_from = physical_revision_id`

### 17.2 production revision metadata
- `promoted_from = online_revision_id`
- `physical_ancestor_revision_id`
- `online_ancestor_revision_id`

## 18. Parameter Delta Requirement
- "Assumptions" are the OpenSCAD parameter values used to generate the model.
- If online assumptions differ from physical assumptions, `metadata.json.parameter_delta` is required.
- `parameter_delta` structure:
  - Object mapping parameter names to `{ "from": <value>, "to": <value> }`.
  - `<value>` may be a number, string, boolean, or null.
- Ledger column mirror: `parameter_deltas`.

## 19. Ledger Model
The ledger specification is defined in [ledger-spec.md](ledger-spec.md).

Summary of required fields in the revisions tab:
- `revision_id`
- `publication_date_utc`
- `scope`
- `previous_revision`
- `description`
- `git_tag`
- `git_commit`
- `promoted_from`
- `promotion_reason`
- `override_approved_by` (required when `override_reason` is used)
- `physical_ancestor_revision_id`
- `online_ancestor_revision_id`
- `parameter_deltas`
- `drive_revision_folder_url`
- `metadata_file_url`
- `physical_checklist_doc_url`
- `online_notes_count` (formula-driven)
- `status` (user-maintained)

## 20. GAS Sync Rules
- Restrict Drive search to `prints_root_folder_id`.
- Ingest only folders that contain `complete.flag`.
- Validate required artifacts per scope.
- Validate non-zero artifact file sizes.
- Reject metadata if `revision_id` mismatches folder name.
- Reject malformed `metadata.json`.
- If artifacts are incomplete: skip ingestion and optionally record `sync_pending` as a sync result in the sync_results tab.
- Never overwrite user-maintained `status`.

## 21. Status Lifecycle
Allowed status values:
- `artifacts_ready`
- `evidence_logged`
- `ready_to_promote`
- `passed`
- `failed`

Promotion precondition:
- `ready_to_promote`

Status transition rules:
- Expected progression: `artifacts_ready -> evidence_logged -> ready_to_promote -> passed|failed`.
- Regression to `artifacts_ready` is required if any `.scad` source files, `metadata.json`, or `parameter_delta` change.
- Authorization:
  - Only CODEOWNERS may set `ready_to_promote` or `passed`.
  - Other statuses may be set by contributors with repository write access.

`sync_pending` is not a `revisions.status` value.

## 22. Breaking Change Definition
- A breaking change violates the Envelope Constraint: the new artifact cannot be swapped into an existing assembly without modifying adjacent modules or the baseplate.

## 23. Branch Archival Policy
- Branch inactivity is defined by the associated Pull Request.
- If there are no new commits or comments for 30 days, the branch is eligible for archival.
