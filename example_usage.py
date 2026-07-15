# example_usage.py
# Demonstrates importing and using the compiled .pyd module.
# Run from the repo root:  python example_usage.py

import sys
import os

# Add the compiled/ folder to Python's path so it can find the .pyd
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "compiled"))

import cython_module  # loads compiled/cython_module.cp311-win_amd64.pyd

print(cython_module.greet("World"))
print("add(2, 3)      =", cython_module.add(2, 3))
print("compute(1000)  =", cython_module.compute(1000))