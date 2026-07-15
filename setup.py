"""
setup.py — Compiles all Python sources in src/ into .pyd extension modules.

Drop any number of .py files in src/ — each becomes its own .pyd.
The source filename becomes the module name (must be a valid Python identifier).
"""
from setuptools import setup
from Cython.Build import cythonize
import glob

# Find every .py in src/ and compile each into its own extension module
sources = glob.glob("src/*.py")

if not sources:
    raise SystemExit("No .py files found in src/ — nothing to compile.")

setup(
    ext_modules=cythonize(
        sources,
        build_dir="build",                        # generated .c → build/, keeps src/ clean
        compiler_directives={"language_level": "3"},
    ),
)