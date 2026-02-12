# Publish Script Requirements (Strict)

## Scope
Define requirements for the Windows publish script that creates a new revision folder and tag.

## Required Behavior
- Must create revision folder with format: `output/prints/print-YYYYMMDD-rNN-[scope]/`.
- Must allocate `rNN` as a globally monotonic revision number.
- Must set Git tag format to `sXX-rNN` (legacy `T-rNN` allowed for existing releases).
- Must abort if the tag already exists.
- Must never reuse a tag.

## Scope Purity Enforcement
- `prototype`:
  - Must contain `metadata.json`, `source/`, `complete.flag`.
  - Must not contain `tests/`.
  - Must not contain `model.stl`.
  - Must not contain `slicer.3mf`.
- `physical`:
  - Must contain `model.stl`, `slicer.3mf`, `tests/physical/`.
  - Must not contain `tests/online/`.
- `online`:
  - Must contain `model.stl`, `tests/online/`.
  - Must not contain `tests/physical/`.
  - Must not contain `slicer.3mf`.
  - Must require physical ancestor reference in `metadata.json`.
- `production`:
  - Must contain `model.stl`, `slicer.3mf`, `tests/physical/`, `tests/online/`.
  - Must require explicit `physical_ancestor_revision_id` and `online_ancestor_revision_id` in `metadata.json`.

## Metadata and Lineage
- Must enforce `metadata.json.revision_id` equals folder name.
- For `online`, must enforce `promoted_from = physical_revision_id`.
- For `production`, must enforce:
  - `promoted_from = online_revision_id`
  - `physical_ancestor_revision_id`
  - `online_ancestor_revision_id`
- If online assumptions differ from physical assumptions, must require `metadata.json.parameter_delta`.

## complete.flag Rule
- Must write `complete.flag` last.
- Must treat `metadata.json`, `model.stl`, `slicer.3mf`, and `source/` as immutable after `complete.flag`.
- May allow later evidence append under `tests/*`.

## History Constraints
- Must operate under append-only history after first tag.
- Must not require or perform rebase.
- Must not require or perform amend.
- Must not require or perform force-push.
