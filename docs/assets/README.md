# Assets: Images

## Purpose
All images are documentation artifacts. They are separated by intent and trust level: vision is aspirational but aligned to current geometry, drawings are engineering truth, and renders are visual outputs derived from geometry.

## Folder Guide

### docs/assets/vision/
- Contains ONE conceptual image representing the final imagined product.
- Aspirational but aligned to current geometry.
- Not tied to <variant>-<release>.
- Default filename:
  tentacle-vision.png
- If the vision changes materially:
  tentacle-vision-v2.png

### docs/assets/renders/
- Photorealistic or visual outputs derived from a specific geometry state.
- Must follow:
  <variant>-<release>-<view>-<type>.xxx

### docs/assets/drawings/
- Technical drawings and geometry references.
- Includes dimensioned drawings and clean silhouette references.
- Must follow:
  <variant>-<release>-<view>-<type>.xxx

## Naming Convention

Pattern:

```
<variant>-<release>-<view>-<type>.xxx
```

- variant (example: s33)
- release (example: r01)
- view (iso, side, top, front, section, detail)
- type (render, dim, clean, wireframe, closeup)
- extension guidance (png/jpg/svg)

## Examples

```
tentacle-vision.png
s33-r01-iso-render.png
s33-r01-iso-dim.png
s33-r01-side-dim.png
s33-r01-side-clean.png
s33-r01-detail-closeup-render.png
s33-r01-section-dim.png
```

## Rules (Do / Don’t)

DO:
- Keep vision conceptual and stable.
- Bump release when geometry changes.
- Update drawings and renders when release changes.
- Keep filenames consistent.

DON’T:
- Add new subfolders under docs/assets/ without explicit decision.
- Put documentation images under src/ or output/prints/.
- Use ambiguous filenames like final.png.
