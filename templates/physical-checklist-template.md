# Physical Revision Checklist

## Revision
- Revision ID: `print-YYYYMMDD-rNN-physical`
- Git tag: `sXX-rNN` (legacy `T-rNN` allowed for existing releases)
- Git commit:
- Publication date (UTC):

## Scope Purity
- [ ] `model.stl` exists and non-zero size.
- [ ] `slicer.3mf` exists and non-zero size.
- [ ] `tests/physical/` exists.
- [ ] `tests/online/` does not exist.

## Required Artifacts
- [ ] `metadata.json` exists and parses.
- [ ] `source/` exists.
- [ ] `complete.flag` was written last.
- [ ] `physical-tests-results.json` includes `printer_id`.

## Governance
- [ ] Folder name matches `metadata.json.revision_id`.
- [ ] Tag does not already exist before publish.
- [ ] No rebase/amend/force-push used after first tag.

## Ledger
- [ ] `revisions` row inserted.
- [ ] `status` updated to lifecycle value.
- [ ] `physical_checklist_doc_url` populated.

## Reviewer
- Reviewer:
- Review timestamp (UTC):
- Result: `passed` / `failed`
- Notes:
