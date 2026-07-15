# pyd_building

**A reusable template for building Windows Python extension modules (`.pyd`)
using GNU tools (MinGW/GCC) inside conda — no administrator rights required.**

Compile Python (via Cython), C, or C++ sources into importable `.pyd` modules,
entirely on one machine, without needing admin to install a toolchain.

---

## Why This Exists

On Windows, Python normally expects the MSVC toolchain to build extensions —
which typically requires admin rights to install. This template uses **conda**
to provide a complete, modern **GNU toolchain (GCC 15.2, UCRT)** plus the Python
import library, all installed at the user level. No admin needed.

---

## Requirements

- **conda** (Miniconda or Anaconda)
- **Windows x64**
- **No administrator rights**
- **PowerShell** (for the build script)

The actual package requirements are captured in the conda environment
definitions in **[env/](env/)** — see Environment Setup below.

---

## Environment Setup

Full setup — including the **required compiler shim** — is documented in
**[REBUILD.md](REBUILD.md)**. Read that first.

Quick version:

```powershell
# Create the build environment
conda create -n py_pyd_modern -c conda-forge python=3.11 libpython gcc_win-64 gxx_win-64 cython
conda activate py_pyd_modern

# REQUIRED one-time step: shim the prefixed compilers to plain names
# (see REBUILD.md for the full explanation of why)
cd $env:CONDA_PREFIX\Library\bin
copy x86_64-w64-mingw32-gcc.exe gcc.exe
copy x86_64-w64-mingw32-g++.exe g++.exe
```

Environment definitions live in **[env/](env/)**:
- `env/environment.yml` — portable recipe (`--from-history`)
- `env/py_pyd_modern_lock.yml` — exact lockfile (all resolved versions)

---

## How the Build Config Finds Your Compiler

The build and IntelliSense configuration is **portable by design** — it uses
the `CONDA_PREFIX` environment variable rather than hardcoded paths, so it
works on any machine without editing.

**This means the following MUST be true for it to work:**

1. You have created the conda environment (see [REBUILD.md](REBUILD.md) and
   [env/](env/)) with the GNU toolchain packages.
2. **That environment is ACTIVATED** before you build or open the project —
   activation is what sets `CONDA_PREFIX`:
   ```powershell
   conda activate py_pyd_modern
   ```
3. The compiler shims (`gcc.exe` / `g++.exe`) have been applied inside the
   environment (one-time step — see [REBUILD.md](REBUILD.md)).

If IntelliSense can't find `Python.h`, or the build can't find `gcc`, the most
common cause is **the conda environment is not activated** (so `CONDA_PREFIX`
is unset or points at the wrong environment).

> **VS Code note:** If IntelliSense doesn't resolve after activating the env,
> select the conda interpreter (*Python: Select Interpreter*) and reload the
> window (*Developer: Reload Window*) so VS Code picks up `CONDA_PREFIX`.

> **In short:** activate the environment first. The config resolves paths from
> the active conda environment automatically.

---

## Build Workflow

1. **Add your source** to `src/`. The **filename becomes the module name**, so
   name it what you want to `import` (must be a valid Python identifier).
   ```
   src\my_module.py   →   import my_module
   ```

2. **Build:**
   ```powershell
   conda activate py_pyd_modern
   .\build.ps1
   ```

3. **Collect** the compiled `.pyd` from **`compiled/`**.

---

## Try the Included Example

The repo ships with a pre-built example module. Run:

```powershell
python example_usage.py
```

This imports `compiled/cython_module.cp311-win_amd64.pyd` and calls its
functions — demonstrating the full flow from source to importable module.

---

## Project Structure

```
src/          Sources to compile (filename = module name)
compiled/     Deliverable .pyd output (the example .pyd is committed here)
build/        Transient build artifacts — regenerated each build (gitignored)
env/          conda environment definitions (recipe + lockfile)
docs/         Guidance documents
.vscode/      IntelliSense + build-task configuration
build.ps1     Build script (compiles, then moves .pyd to compiled/)
setup.py      Build recipe (Cython + setuptools)
example_usage.py   Demonstrates importing the compiled module
REBUILD.md    How to recreate the environment (READ THIS FIRST)
```

---

## Documentation

- **[REBUILD.md](REBUILD.md)** — Recreate the build environment, including the
  critical compiler shim step. **Start here.**
- **[docs/PYD_Workflow_Guide.md](docs/PYD_Workflow_Guide.md)** — What you can and
  cannot change (filenames, module names, etc.) and common gotchas.
- **[docs/Compiling_Guidance.md](docs/Compiling_Guidance.md)** — When compiling
  to `.pyd` is worthwhile, and when it isn't.

---

## Key Things to Know

- **A `.pyd` is locked to the Python minor version that built it.** These are
  built for **Python 3.11**; they will only import into Python 3.11.
- **Never rename a compiled `.pyd`** to change its module name — the name is
  baked into the binary. Rename the **source** file and rebuild instead.
- **Keep all work inside the conda env.** Do not build in an MSYS2 shell or
  against system Python — it causes ABI mismatches.
- **This is Windows x64 specific.** A `.pyd` built here won't run on Linux/macOS.

---

## Toolchain (verified working)

| Component | Version |
|-----------|---------|
| Python    | 3.11 (conda-forge) |
| Compiler  | GCC / G++ 15.2 (conda-forge, UCRT) |
| Cython    | 3.x |
| Platform  | Windows x64 |

---

## License

See [LICENSE](LICENSE). This is a work of the U.S. Government and is in the
public domain — free to use, modify, distribute, and fork without restriction.