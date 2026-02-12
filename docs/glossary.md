# Glossary

- Revision ID: Identifier formatted as `print-YYYYMMDD-rNN-[scope]`.
- Revision Folder: Directory `output/prints/print-YYYYMMDD-rNN-[scope]/` that stores one released revision.
- Global Revision Number (`rNN`): Monotonic revision counter shared by all scopes.
- Scope: Release stage of a revision: `prototype`, `physical`, `online`, or `production`.
- Tag (`T-rNN`): Git tag bound to one revision number; never reused.
- Scope Purity: Required and forbidden artifact rules enforced per scope.
- complete.flag: File written last by the Windows publish process to mark artifact freeze readiness for ingestion.
- Immutable Artifacts: `metadata.json`, `model.stl`, `slicer.3mf`, and `source/` after `complete.flag`.
- Evidence Artifacts: Files under `tests/*`; may be appended after `complete.flag`.
- Promotion: Creation of a new revision from an ancestor following `physical -> online -> production`.
- Lineage: Metadata links between promoted revisions and their ancestors.
- Parameter Delta: `metadata.json.parameter_delta` values recorded when online assumptions differ from physical assumptions.
- Ledger: Google Sheets tabs (`revisions`, `online_notes`) used for traceability and promotion status.
- GAS Ingestion: Google Apps Script synchronization from Drive revision folders to the Sheets ledger.
- Status Lifecycle: `artifacts_ready`, `evidence_logged`, `ready_to_promote`, `passed`, `failed`.
