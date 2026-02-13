# Naming Audit Rules

<a id="governance-rules"></a>
## Governance Rules

[Jump](#conflicts)

<a id="rule-docs-root"></a>
Documentation MUST live under `docs/`. [Jump](#rule-docs-root)

<a id="rule-src-root"></a>
OpenSCAD sources MUST live under `src/`. [Jump](#rule-src-root)

<a id="rule-templates-root"></a>
Templates MUST live under `templates/`. [Jump](#rule-templates-root)

<a id="rule-output-prints-root"></a>
Published releases MUST live under `output/prints/`. [Jump](#rule-output-prints-root)

<a id="rule-prints-immutable"></a>
Files under `output/prints/` MUST NOT be modified, moved, or replaced after publication. [Jump](#rule-prints-immutable)

<a id="rule-src-entrypoints-location"></a>
OpenSCAD entrypoints MUST live under `src/<variant>/`. [Jump](#rule-src-entrypoints-location)

<a id="rule-s33-entry"></a>
The default 1/3 scale variant entry file MUST be `src/s33/assembly_s33.scad`. [Jump](#rule-s33-entry)

<a id="rule-new-variant-doc"></a>
If a new variant is added, it MUST be created as a new `src/<variant>/` folder and its entry file MUST be documented. [Jump](#rule-new-variant-doc)

<a id="rule-revision-folder-format"></a>
Revision folders under `output/prints/` MUST be named `print-YYYYMMDD-rNN-[scope]`. [Jump](#rule-revision-folder-format)

<a id="rule-revision-id-match"></a>
Revision IDs MUST follow `print-YYYYMMDD-rNN-[scope]` and MUST match their folder name. [Jump](#rule-revision-id-match)

<a id="rule-revision-folder-regex"></a>
Revision folder names MUST match regex `print-\d{8}-r\d+-[a-z]+`. [Jump](#rule-revision-folder-regex)

<a id="rule-revision-scope-values"></a>
The scope segment in revision folder names MUST be one of `prototype`, `physical`, `online`, or `production`. [Jump](#rule-revision-scope-values)

<a id="rule-prints-lowercase"></a>
All folder and file names under `output/prints/` MUST be strict lowercase. [Jump](#rule-prints-lowercase)

<a id="rule-revision-subfolders"></a>
The canonical revision structure MUST use lowercase subfolders named `source/` and `tests/` under each revision folder. [Jump](#rule-revision-subfolders)

<a id="rule-tests-subfolders"></a>
When present, test evidence subfolders MUST be named `tests/online/` and `tests/physical/`. [Jump](#rule-tests-subfolders)

<a id="rule-render-preview-names"></a>
Rendering and preview files under `output/prints/<revision>/source/` MUST be named `render_*.png` and `preview_*.png`. [Jump](#rule-render-preview-names)

<a id="rule-render-preview-views"></a>
Rendering and preview sets MUST include `_iso.png` and `_side.png` variants. [Jump](#rule-render-preview-views)

<a id="rule-online-test-results"></a>
Online test results MUST be named `tests/online/online-tests-results.json` and `tests/online/result-extract.zip`. [Jump](#rule-online-test-results)

<a id="rule-physical-test-results"></a>
Physical test results MUST include `tests/physical/physical-tests-results.json`. [Jump](#rule-physical-test-results)

<a id="rule-docs-assets-location"></a>
Documentation images MUST NOT be stored under `src/` or `output/prints/`. [Jump](#rule-docs-assets-location)

<a id="rule-docs-assets-subfolders"></a>
New subfolders under `docs/assets/` MUST NOT be added without explicit decision. [Jump](#rule-docs-assets-subfolders)

<a id="rule-vision-default-name"></a>
The default vision image in `docs/assets/vision/` MUST be named `tentacle-vision.png`. [Jump](#rule-vision-default-name)

<a id="rule-vision-v2-name"></a>
If the vision changes materially, the updated image MUST be named `tentacle-vision-v2.png`. [Jump](#rule-vision-v2-name)

<a id="rule-docs-renders-pattern"></a>
Files under `docs/assets/renders/` MUST follow `<variant>-<release>-<view>-<type>.xxx`. [Jump](#rule-docs-renders-pattern)

<a id="rule-docs-drawings-pattern"></a>
Files under `docs/assets/drawings/` MUST follow `<variant>-<release>-<view>-<type>.xxx`. [Jump](#rule-docs-drawings-pattern)

<a id="conflicts"></a>
## Conflicts

[Jump](#governance-rules)

No conflicts found across Markdown sources for naming or structure rules.
