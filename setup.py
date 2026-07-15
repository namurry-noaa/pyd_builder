from setuptools import setup
from Cython.Build import cythonize

setup(
    name="cy_module",
    ext_modules=cythonize(
        "src/cython_module.py",
        build_dir="build",                        # generated .c → build/, keeps src/ clean
        compiler_directives={"language_level": "3"},
    ),
)