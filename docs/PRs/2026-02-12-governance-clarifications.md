# PR: Clarify Governance Rules and Schemas

## Summary
Clarifies governance and schema requirements, including promotion exceptions, evidence timing, status authorization, and parameter delta structure. Aligns docs, ledgers, and validation requirements with the updated rules.

## Changes
- Define SSoT and promotion vs. new revision rules, including `physical -> production` override requirements.
- Add 48-hour evidence append window with enforcement rules.
- Define `parameter_delta` structure and add `override_reason` to metadata schema.
- Require `printer_id` in physical test results and update checklist.
- Add status transition rules and authorization (CODEOWNERS for `ready_to_promote` / `passed`).
- Update ledger spec and sync results guidance.
- Align runbook, devops strategy, and script requirement docs.

## Testing
- Not run (docs-only changes).

## Notes / Risks
- Requires ledger schema to add `override_approved_by`.
- Validation scripts should be updated to enforce new fields and exception rules.
