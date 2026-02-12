# Tentacle Runbook

## 1. Publish a New Revision
1. Select scope: `prototype`, `physical`, `online`, or `production`.
2. Allocate next global revision number `rNN`.
3. Create folder: `output/prints/print-YYYYMMDD-rNN-[scope]/`.
4. Place required artifacts for the selected scope.
5. Validate scope purity (required and forbidden artifacts).
6. Write `complete.flag` last.
7. Create Git tag `T-rNN`.
8. Abort publish if `T-rNN` already exists.

## 2. Post-Publish Evidence
1. Keep immutable artifacts unchanged:
   - `metadata.json`
   - `model.stl`
   - `slicer.3mf`
   - `source/`
2. Append evidence only under `tests/*`.
3. Update Sheet `status` through lifecycle:
   - `artifacts_ready`
   - `evidence_logged`
   - `ready_to_promote`
   - `passed` or `failed`

## 3. Promotion Procedure
1. Confirm source revision status is `ready_to_promote`.
2. If source status is not `passed`, require explicit confirmation.
3. Promote only along `physical -> online -> production`.
4. Create a new revision folder and new tag for promotion target.
5. Preserve ancestors without edits.
6. Set lineage fields in `metadata.json`:
   - Online target: `promoted_from = physical_revision_id`
   - Production target: `promoted_from = online_revision_id`, `physical_ancestor_revision_id`, `online_ancestor_revision_id`
7. If online assumptions differ from physical assumptions, populate `parameter_delta` in `metadata.json` and mirror into Sheet `parameter_deltas`.

## 4. GAS Sync Procedure
1. Restrict Drive scan to `prints_root_folder_id`.
2. Read only folders containing `complete.flag`.
3. Validate metadata parse, folder-name match, scope-required artifacts, scope-forbidden artifacts, and non-zero file sizes.
4. If incomplete, skip or mark `sync_pending`.
5. Update ledger fields except user-maintained `status`.

## 5. Prohibited Operations
- Rebase after first tag.
- Amend after first tag.
- Force-push after first tag.
- Tag reuse.
