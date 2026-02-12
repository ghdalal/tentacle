# Tentacle DevOps Strategy

## Objective
Define deterministic publication, traceability, and promotion for print revisions without rewriting history.

## Revision Identity
- Revision folder: `output/prints/print-YYYYMMDD-rNN-[scope]/`
- `rNN` is globally monotonic across all scopes.
- Git tag: `T-rNN`
- Tag reuse is forbidden.
- Publisher must abort if tag already exists.

## Repository History Policy
- History is append-only after the first tag.
- Rebase is forbidden.
- Amend is forbidden.
- Force-push is forbidden.

## Scope Rules
- `prototype`: no `tests/`; must not include `model.stl` or `slicer.3mf`; must include `metadata.json`, `source/`, `complete.flag`
- `physical`: must include `model.stl`, `slicer.3mf`, `tests/physical/`; must not include `tests/online/`
- `online`: must include `model.stl`, `tests/online/`; must not include `tests/physical/` or `slicer.3mf`; must reference its physical ancestor in `metadata.json`
- `production`: must include `model.stl`, `slicer.3mf`, `tests/physical/`, `tests/online/`; must declare both physical and online ancestors

## Artifact Freeze Signal
- `complete.flag` is written last by the Windows publish script.
- GAS ingestion requires `complete.flag`.
- `complete.flag` freezes `metadata.json`, `model.stl`, `slicer.3mf`, and `source/`.
- Evidence in `tests/*` may be appended after `complete.flag` for up to 48 hours.

## Promotion Policy
- Mandatory path: `physical -> online -> production`
- Promotion always creates a new revision.
- Ancestor revisions are never edited.
- Promotion requires Sheet `status = ready_to_promote`.
 - `physical -> production` is disallowed by default; requires `override_reason` and CODEOWNER approval when used as an exception.
- If ancestor status is not `passed`, explicit confirmation is mandatory.

## Lineage Fields
- `online`: `promoted_from = physical_revision_id`
- `production`:
  - `promoted_from = online_revision_id`
  - `physical_ancestor_revision_id`
  - `online_ancestor_revision_id`

## Parameter Delta
- If online assumptions differ from physical assumptions, `metadata.json.parameter_delta` is required.
- Ledger mirror field: `parameter_deltas`

## Ledger and Sync Boundary
- Google Sheets is the operational ledger (`ledger/sheet-spec.md`).
- GAS ingestion must stay under `prints_root_folder_id`.
- Sync must not overwrite user-managed `status` values.
