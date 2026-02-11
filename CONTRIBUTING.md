# Contributing

Branch naming
- Feature: `feature/<ticket?>/<short-desc>` — e.g. `feature/onethird`, `feature/TENT-42/add-motor-mount`
- Experiment: `exp/<short-desc>` — e.g. `exp/artistic`, `exp/engineering`
- Bugfix: `bugfix/<ticket?>/<short-desc>` — e.g. `bugfix/TENT-101/fix-overlap`
- Hotfix: `hotfix/<short-desc>`
- Chore: `chore/<short-desc>`
- Docs: `docs/<short-desc>`

Rules
- Use lowercase, hyphen-separated words; avoid spaces and special characters.
- Include ticket ID when available (format: `TENT-123`).
- Keep the descriptive part concise (prefer <50 characters).
- Base new branches from the default branch (`main` or `master` as appropriate).

Commit messages
- Use imperative, short subject lines: `type(scope): short description` (optional scope).
- Examples: `feat(onethird): add initial model`, `fix(packing): correct overlap`

Pull requests
- Open a PR from your branch to the default branch.
- PR title should be short and match the branch intent: `Feature: add onethird`.
- Include a short description, motivation, and any test instructions.
- Add reviewers and link related ticket/issue if present.

PR Checklist (suggested)
- [ ] Changes documented (if applicable)
- [ ] Builds without errors
- [ ] No sensitive data added
- [ ] Tests added/updated or manual test steps provided

Creating branches (example commands)
```powershell
# fetch updates and ensure you're on default branch
git fetch origin --prune
git checkout main 2>$null; if ($LASTEXITCODE -ne 0) { git checkout master 2>$null }

# feature branches
git checkout -b feature/onethird
git push -u origin feature/onethird

git checkout main
git checkout -b feature/red-team-agent
git push -u origin feature/red-team-agent

# experiment branches
git checkout main
git checkout -b exp/artistic
git push -u origin exp/artistic

git checkout main
git checkout -b exp/engineering
git push -u origin exp/engineering
```

Notes
- If `git push` fails due to missing remote or permissions, create branches locally and push later when you have access.
- Adjust `main`/`master` references if your repository uses a different default branch.

Thank you for contributing — open a PR when ready and drop a short description in the PR body.

Branches
- `feature/onethird`: Feature branch for the OneThird model and related assets.
	- Purpose: implement or refine the `onethird` 3D model and assembly.
	- Base: `main`.
	- Expected lifespan: short-to-medium; merge when feature is review-ready.
- `feature/red-team-agent`: Feature branch for the RedTeamAgent work.
	- Purpose: add or modify the `RedTeamAgent` component, AI agent code, or tests.
	- Base: `main`.
	- Expected lifespan: short-to-medium; keep focused on a single deliverable.
- `exp/artistic`: Experiment branch for artistic/visual iterations.
	- Purpose: try visual, rendering, texture, or creative changes that may be exploratory.
	- Base: `main`.
	- Expected lifespan: ephemeral; may never merge or may be squashed into a feature branch.
- `exp/engineering`: Experiment branch for engineering or structural experiments.
	- Purpose: prototype engineering changes, performance work, or alternative designs.
	- Base: `main`.
	- Expected lifespan: ephemeral; document outcomes in the PR if merged.

When to create these branches
- Create `feature/*` when implementing a discrete product feature or task.
- Create `exp/*` for exploratory work; prefix with a clear short description.
- Keep branches narrowly scoped and open PRs that explain the goal and testing steps.
