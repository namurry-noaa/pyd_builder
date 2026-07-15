# Changelog

All notable changes to this project are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/).
This project uses [Semantic Versioning](https://semver.org/).

## [2.1.0] - 2026-07-15
### Added
- `REQUIREMENTS.md` — full requirements spec, including the strict
  CPython 3.11.x version rule (build vs. runtime requirements).
- `CHANGELOG.md` — this file, and added a note in the README.
- Quick Start section and a "Distributing a C++ .pyd" section in README.

### Changed
- LICENSE corrected to the standard DOC/NOAA public-domain notice
  (U.S. Government work, 17 U.S.C. § 105); reformatted with line breaks
  for readability.
- README updated: license section reflects public-domain status; added
  environment-variable dependency notes and REQUIREMENTS reference.

## [2.0.0] - 2026-07-15
### Added
- Multi-module build: `setup.py` compiles all `.py` files in `src/` via
  glob (drop in any source; filename becomes the module name).
- `bundle_dlls.ps1` — bundles a C++ `.pyd`'s GNU runtime DLLs into `dist/`
  for use outside the build environment (validated standalone).
- `example_usage.py` — demonstrates importing a compiled module.
- Environment definitions (`env/`), guidance docs (`docs/`), and portable
  `.vscode` IntelliSense config (uses `${env:CONDA_PREFIX}`, no hardcoded paths).

### Changed
- Project restructured: `src/` (sources), `compiled/` (deliverable .pyd),
  `build/` (transient, gitignored), `env/`, `docs/`.
- Build output collection scoped to fresh artifacts only (`build.ps1`).

## [1.0.0] - Initial (unpublished)
- Basic proof-of-concept: GNU-toolchain `.pyd` build working under conda
  with no admin rights. C, C++, and Cython build paths validated.