# Validate Script Requirements (Strict)

## Scope
Define requirements for validation before or during GAS ingestion.

## Drive Boundary
- Must restrict Drive search to `prints_root_folder_id`.
- Must ignore revision-like folders outside that root.

## Ingestion Gate
- Must ingest only folders that contain `complete.flag`.
- If required artifacts are incomplete, must skip or mark `sync_pending`.

## Revision Identity Validation
- Must validate folder name format: `print-YYYYMMDD-rNN-[scope]`.
- Must validate `metadata.json.revision_id` equals folder name.
- Must validate `revision_id` regex: `print-\d{8}-r\d+-(prototype|physical|online|production)`.

## Metadata Validation
- Must reject malformed `metadata.json`.
- Must validate lineage fields by scope:
  - `online`: `promoted_from = physical_revision_id`
  - `production`:
    - Standard: `promoted_from = online_revision_id`, `physical_ancestor_revision_id`, `online_ancestor_revision_id`
    - Exception: allow `promoted_from = physical_revision_id` only if `override_reason` is set and `online_ancestor_revision_id = null`
- If online assumptions differ from physical assumptions, must require `metadata.json.parameter_delta`.

## Artifact Validation by Scope
- `prototype`:
  - Require `metadata.json`, `source/`, `complete.flag`
  - Forbid `tests/`, `model.stl`, `slicer.3mf`
- `physical`:
  - Require `model.stl`, `slicer.3mf`, `tests/physical/`
  - Forbid `tests/online/`
- `online`:
  - Require `model.stl`, `tests/online/`
  - Forbid `tests/physical/`, `slicer.3mf`
  - Require physical ancestor reference in `metadata.json`
- `production`:
  - Require `model.stl`, `slicer.3mf`, `tests/physical/`, `tests/online/`
  - Require explicit physical and online ancestors in `metadata.json`

## File Integrity Validation
- Must validate non-zero file size for required artifact files.

## Ledger Sync Constraints
- Must not overwrite user-maintained `status` in `revisions` tab.
- Must mirror `metadata.json.parameter_delta` into `parameter_deltas` when required.
