# Promote Script Requirements (Strict)

## Scope
Define requirements for promotion from ancestor revisions into new revisions.

## Promotion Path
- Must allow only: `physical -> online -> production`.
- Exception: `physical -> production` is allowed only when `metadata.json.override_reason` is set and CODEOWNER approval is recorded in the ledger.
- Must always create a new revision.
- Must never edit ancestor revisions.

## Preconditions
- Must require source revision `status = ready_to_promote` in the Sheet.
- If source revision status is not `passed`, must require explicit confirmation before continuing.

## Revision Identity
- Must create target folder: `output/prints/print-YYYYMMDD-rNN-[scope]/`.
- Must allocate `rNN` from global monotonic sequence.
- Must create tag `sXX-rNN` (legacy `T-rNN` allowed for existing releases).
- Must abort if the tag already exists.

## Lineage Requirements
- For promotion to `online`:
  - Must set `promoted_from = physical_revision_id`.
  - Must reference physical ancestor in `metadata.json`.
- For promotion to `production`:
  - Standard:
    - Must set `promoted_from = online_revision_id`.
    - Must set `physical_ancestor_revision_id`.
    - Must set `online_ancestor_revision_id`.
  - Exception `physical -> production` (when allowed):
    - Must set `promoted_from = physical_revision_id`.
    - Must set `physical_ancestor_revision_id = physical_revision_id`.
    - Must set `online_ancestor_revision_id = null`.
    - Must require `metadata.json.override_reason`.

## Scope Purity Enforcement
- `online` target must include `model.stl` and `tests/online/`.
- `online` target must not include `tests/physical/` or `slicer.3mf`.
- `production` target must include `model.stl`, `slicer.3mf`, `tests/physical/`, and `tests/online/`.

## Parameter Delta
- If online assumptions differ from physical assumptions, must require `metadata.json.parameter_delta`.
- Must mirror this value to Sheet `parameter_deltas`.

## complete.flag and Immutability
- Must write `complete.flag` last for promoted revisions.
- Must keep `metadata.json`, `model.stl`, `slicer.3mf`, and `source/` immutable after `complete.flag`.
- May append evidence under `tests/*` after `complete.flag`.

## History Constraints
- Must preserve append-only history after first tag.
- Must not perform rebase, amend, or force-push.
