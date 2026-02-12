# Tentacle Revision Governance Specification

## 0. Authority
- This document is the Single Source of Truth (SSoT) for governance and technical specification rules.
- `README.md` and `docs/glossary.md` are summaries. If a conflict exists, this document prevails.

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

MUST NOT exist:
- `tests/`
- `model.stl`
- `slicer.3mf`

### 3.2 physical
Required:
- `model.stl`
- `slicer.3mf`
- `tests/physical/`

MUST NOT exist:
- `tests/online/`

### 3.3 online
Required:
- `model.stl`
- `tests/online/`
- Physical ancestor reference in `metadata.json`

MUST NOT exist:
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
- Evidence append window: maximum 48 hours after `complete.flag` is written.
- Policy enforcement:
  - Validate script issues a warning if evidence is appended after 48 hours.
  - A hard fail occurs only if a CODEOWNER has already finalized `status = passed`.
- Evidence append authorization: any contributor may append evidence within the window.

## 5. Revision Creation vs Promotion
- `prototype -> physical` is a source-to-artifact transition and is a new revision without lineage requirements.
- Promotion is strictly the path: `physical -> online -> production`.
- Promotion always creates a new revision. Ancestor revisions are never edited.
- Promotion gate: Sheet `status` must be `ready_to_promote`.
- If ancestor `status` is not `passed`, mandatory confirmation is required.

### 5.1 Exception: `physical -> production`
- Default: not allowed.
- Exception requires all of the following:
  - `metadata.json.override_reason` is populated.
  - A CODEOWNER provides explicit approval recorded in the ledger.
  - The production revision sets:
    - `promoted_from = physical_revision_id`
    - `physical_ancestor_revision_id = physical_revision_id`
    - `online_ancestor_revision_id = null`

Valid `override_reason` categories:
- `Emergency Field Repair`
- `Legacy Validation Carryover`
- `Component Criticality: Low`

## 6. Lineage Fields
### 6.1 online revision metadata
- `promoted_from = physical_revision_id`

### 6.2 production revision metadata
- `promoted_from = online_revision_id`
- `physical_ancestor_revision_id`
- `online_ancestor_revision_id`

## 7. Parameter Delta Requirement
- "Assumptions" are the OpenSCAD parameter values used to generate the model.
- If online assumptions differ from physical assumptions, `metadata.json.parameter_delta` is required.
- `parameter_delta` structure:
  - Object mapping parameter names to `{ "from": <value>, "to": <value> }`.
  - `<value>` may be a number, string, boolean, or null.
- Ledger column mirror: `parameter_deltas`.

## 8. Physical Revision Hardware Change Triggers
Any of the following changes require a new physical revision, even if artifacts appear identical:
- Nozzle diameter
- Hotend or extruder components
- Cooling modifications
- Major firmware type changes (for example, Marlin -> Klipper)

## 9. Breaking Change Definition
- A breaking change violates the Envelope Constraint: the new artifact cannot be swapped into an existing assembly without modifying adjacent modules or the baseplate.

## 10. Ledger Model
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
- `override_approved_by` (required when `override_reason` is used)
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

## 11. GAS Sync Rules
- Restrict Drive search to `prints_root_folder_id`.
- Ingest only folders that contain `complete.flag`.
- Validate required artifacts per scope.
- Validate non-zero artifact file sizes.
- Reject metadata if `revision_id` mismatches folder name.
- Reject malformed `metadata.json`.
- If artifacts are incomplete: skip ingestion and optionally record `sync_pending` as a sync result in the sync_results tab.
- Never overwrite user-maintained `status`.

## 12. Status Lifecycle
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

## 13. Branch Archival Policy
- Branch inactivity is defined by the associated Pull Request.
- If there are no new commits or comments for 30 days, the branch is eligible for archival.
