# Tentacle Revision Governance Specification

## 1. Revision Identity
- Revision folder format: `output/prints/print-YYYYMMDD-rNN-[scope]/`
- `rNN` is globally monotonic.
- Git tag format: `T-rNN`
- Tag reuse is forbidden.
- Publish abort condition: tag already exists.

## 2. History Integrity
- Git history is append-only after the first tag.
- Forbidden operations: rebase, amend, force-push.

## 3. Scope Purity Rules

### 3.1 prototype
Required:
- `metadata.json`
- `source/`
- `complete.flag`

Forbidden:
- `tests/`
- `model.stl`
- `slicer.3mf`

### 3.2 physical
Required:
- `model.stl`
- `slicer.3mf`
- `tests/physical/`

Forbidden:
- `tests/online/`

### 3.3 online
Required:
- `model.stl`
- `tests/online/`
- Physical ancestor reference in `metadata.json`

Forbidden:
- `tests/physical/`
- `slicer.3mf`

### 3.4 production
Required:
- `model.stl`
- `slicer.3mf`
- `tests/physical/`
- `tests/online/`
- Explicit physical and online ancestors in `metadata.json`

## 4. complete.flag Semantics
- Written last by the Windows publish script.
- Required before GAS ingestion.
- Indicates artifact freeze, not evidence completion.
- Immutability set:
  - `metadata.json`
  - `model.stl`
  - `slicer.3mf`
  - `source/`
- `tests/*` evidence may be appended after `complete.flag`.

## 5. Promotion Policy
- Mandatory sequence: `physical -> online -> production`
- Promotion always creates a new revision.
- Ancestor revisions are never edited.
- Promotion gate: Sheet `status` must be `ready_to_promote`.
- If ancestor `status` is not `passed`, mandatory confirmation is required.

## 6. Lineage Fields
### 6.1 online revision metadata
- `promoted_from = physical_revision_id`

### 6.2 production revision metadata
- `promoted_from = online_revision_id`
- `physical_ancestor_revision_id`
- `online_ancestor_revision_id`

## 7. Parameter Delta Requirement
- If online assumptions differ from physical assumptions, `metadata.json.parameter_delta` is required.
- Ledger column mirror: `parameter_deltas`.

## 8. Ledger Model
Revisions tab columns:
- `revision_id`
- `publication_date_utc`
- `scope`
- `previous_revision`
- `description`
- `git_tag`
- `git_commit`
- `promoted_from`
- `promotion_reason`
- `physical_ancestor_revision_id`
- `online_ancestor_revision_id`
- `parameter_deltas`
- `drive_revision_folder_url`
- `metadata_file_url`
- `physical_checklist_doc_url`
- `online_notes_count` (formula-driven)
- `status` (user-maintained)

Revision id regex:
- `print-\d{8}-r\d+-[a-z]+`

Online notes tab columns:
- `timestamp_utc`
- `revision_id`
- `note_type`
- `summary`
- `details`
- `author`
- `attachments_folder_url`

## 9. GAS Sync Rules
- Restrict Drive search to `prints_root_folder_id`.
- Ingest only folders that contain `complete.flag`.
- Validate required artifacts per scope.
- Validate non-zero artifact file sizes.
- Reject metadata if `revision_id` mismatches folder name.
- Reject malformed `metadata.json`.
- If artifacts are incomplete: skip ingestion or mark `sync_pending`.
- Never overwrite user-maintained `status`.

## 10. Status Lifecycle
Allowed status values:
- `artifacts_ready`
- `evidence_logged`
- `ready_to_promote`
- `passed`
- `failed`

Promotion precondition:
- `ready_to_promote`
