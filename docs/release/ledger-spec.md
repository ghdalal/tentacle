# Google Sheets Ledger Specification

## Tab: revisions
Columns (in order):
1. `revision_id`
2. `publication_date_utc`
3. `scope`
4. `previous_revision`
5. `description`
6. `git_tag`
7. `git_commit`
8. `promoted_from`
9. `promotion_reason`
10. `override_approved_by` (required when `override_reason` is used)
11. `physical_ancestor_revision_id`
12. `online_ancestor_revision_id`
13. `parameter_deltas`
14. `drive_revision_folder_url`
15. `metadata_file_url`
16. `physical_checklist_doc_url`
17. `online_notes_count` (formula-driven)
18. `status` (user-maintained)

`revision_id` regex:
- `print-\d{8}-r\d+-[a-z]+`

`git_tag` format:
- Future releases: `sXX-rNN`
- Legacy releases may use `T-rNN`

`online_notes_count` formula:
- Row formula: `=IF(A2="","",COUNTIF(online_notes!B:B,A2))`
- Fill down for all revision rows.

`status` allowed lifecycle values:
- `artifacts_ready`
- `evidence_logged`
- `ready_to_promote`
- `passed`
- `failed`

## Tab: online_notes
Columns (in order):
1. `timestamp_utc`
2. `revision_id`
3. `note_type`
4. `summary`
5. `details`
6. `author`
7. `attachments_folder_url`

## Tab: sync_results (optional)
Columns (in order):
1. `timestamp_utc`
2. `revision_id`
3. `result` (for example: `sync_pending`)

## Governance Constraints
- Promotion requires `revisions.status = ready_to_promote`.
- Do not overwrite `revisions.status` during GAS sync.
- For online revisions with changed assumptions, `revisions.parameter_deltas` must mirror `metadata.json.parameter_delta`.
- `sync_pending` is a sync result marker, not a `revisions.status` lifecycle value.
