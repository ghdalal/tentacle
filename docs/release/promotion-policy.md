# Promotion Policy

This policy describes how work moves from draft to release without committing build outputs.

## Stages
- Draft: work-in-progress on feature or experiment branches.
- Candidate: ready for review, with evidence gathered and status set to `ready_to_promote`.
- Release: published revision under `output/prints/` with immutable artifacts.

## Branch and PR Flow
1. Create a branch for the change (for example, `feature/...` or `exp/...`).
2. Prepare artifacts and evidence outside `output/prints/`.
3. Open a PR and run required checks.
4. When approved, publish a new revision under `output/prints/` and tag the commit.

## CI Expectations
- CI validates documentation and automation requirements.
- CI must not commit build outputs or modify `output/prints/`.

## Notes
- Promotion always creates a new revision and never edits ancestors.
- The allowed promotion path is `physical -> online -> production`, with the documented exception for `physical -> production`.
