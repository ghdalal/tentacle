# Release Runbook

## 1. Publish a New Revision
1. Select scope: `prototype`, `physical`, `online`, or `production`.
2. Allocate next global revision number `rNN`.
3. Create folder: `output/prints/print-YYYYMMDD-rNN-[scope]/`.
4. Place required artifacts for the selected scope.
5. Validate scope purity (required and forbidden artifacts).
6. Write `complete.flag` last.
7. Create Git tag `sXX-rNN` (legacy `T-rNN` allowed for existing releases).
8. Abort publish if the tag already exists.

## 2. Post-Publish Evidence
1. Keep immutable artifacts unchanged:
   - `metadata.json`
   - `model.stl`
   - `slicer.3mf`
   - `source/`
2. Append evidence only under `tests/*`.
3. Evidence append window is 48 hours after `complete.flag`.
4. Update Sheet `status` through lifecycle:
   - `artifacts_ready`
   - `evidence_logged`
   - `ready_to_promote`
   - `passed` or `failed`
5. Only CODEOWNERS may set `ready_to_promote` or `passed`.
6. If `.scad` sources, `metadata.json`, or `parameter_delta` change, reset status to `artifacts_ready`.

## 3. Promotion Procedure
1. Confirm source revision status is `ready_to_promote`.
2. If source status is not `passed`, require explicit confirmation.
3. Promote only along `physical -> online -> production`.
4. Create a new revision folder and new tag for the promotion target.

### 3.1 Exception: `physical -> production`
1. Ensure `metadata.json.override_reason` is populated with an allowed category.
2. Record CODEOWNER approval in the ledger.
3. Proceed with a production revision only after approval.
4. Set lineage fields:
   - `promoted_from = physical_revision_id`
   - `physical_ancestor_revision_id = physical_revision_id`
   - `online_ancestor_revision_id = null`

## 4. GAS Sync Procedure
1. Restrict Drive scan to `prints_root_folder_id`.
2. Read only folders containing `complete.flag`.
3. Validate metadata parse, folder-name match, scope-required artifacts, scope-forbidden artifacts, and non-zero file sizes.
4. If incomplete, skip ingestion and optionally record `sync_pending` as a sync result.
5. Update ledger fields except user-maintained `status`.

## 5. Prohibited Operations
- Rebase after first tag.
- Amend after first tag.
- Force-push after first tag.
- Tag reuse.
