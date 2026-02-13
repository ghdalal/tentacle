# Source Layout

The OpenSCAD entrypoints live under `src/<variant>/`.

- `src/s33/` is the default 1/3 scale variant.
- `src/common/` contains shared modules and helpers and is not a standalone entrypoint.

If you add a new variant, create a new `src/<variant>/` folder and document its entry file.
