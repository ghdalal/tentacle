# Output Folder Naming Suggestions

Use a consistent file naming pattern so test artifacts are easy to sort and compare.

## Recommended pattern

`<scope>_<test-id>_<variant>_<status>_<timestamp>.<ext>`

- `scope`: what was generated (`assembly`, `render`, `preview`, `diff`)
- `test-id`: stable test identifier (`t01`, `t02`, `regressionA`)
- `variant`: scenario or parameter (`default`, `45deg`, `petg`, `aluminum`)
- `status`: `current`, `baseline`, `candidate`, or `failed`
- `timestamp`: `YYYYMMDD-HHMMSS` (optional, useful for repeated runs)
- `ext`: file extension (`png`, `stl`, `log`, `json`)

## Example names

- `assembly_t01_default_current_20260211-101530.png`
- `assembly_t01_default_baseline.png`
- `assembly_t01_default_diff.png`
- `render_t02_45deg_current.png`
- `preview_t03_petg_candidate.png`
- `mesh_t04_aluminum_current.stl`
- `metrics_t04_aluminum_current.json`
- `run_t04_aluminum_failed.log`

## Suggested subfolders

If output grows, split files by type:

- `output/images/`
- `output/models/`
- `output/logs/`
- `output/metrics/`

Then keep the same naming pattern in each subfolder.
