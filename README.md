# Tentacle

This is a compact, vertical organizer designed for the **Gridfinity** ecosystem. By utilizing a high-density mixed loading pattern, it maximizes your workspace—bringing tools off the desk and into reach.
![Tentacle vision](docs/assets/vision/tentacle-vision.png)

## Get Started
- Documentation portal: [docs/README.md](docs/README.md)
- Source layout: [src/README.md](src/README.md)
- Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)

## Releases
- Published releases live under `output/prints/` and are immutable.
- Do not modify or move any files under `output/prints/`.

## Tagging Convention
- Future release tags use `sXX-rNN` (for example, `s33-r01`, `s50-r01`).
- Tags reference specific commits per variant and are immutable pointers into history.
- Legacy tags may use `T-rNN` and remain valid for existing releases.

## Repository Layout (High Level)
- `docs/` - product, manufacturing, release, assets and automation documentation
- `src/` - OpenSCAD sources organized by variant
- `templates/` - JSON schemas and checklists
- `output/prints/` - immutable published revisions
