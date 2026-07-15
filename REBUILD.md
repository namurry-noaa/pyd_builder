REBUILD: py_pyd_modern (.pyd build environment)
================================================

1. Create env:
   conda create -n py_pyd_modern -c conda-forge python=3.11 libpython gcc_win-64 gxx_win-64 cython
   conda config --set channel_priority strict

2. Shim compilers to plain names (REQUIRED - not captured by conda):
   conda activate py_pyd_modern
   cd $env:CONDA_PREFIX\Library\bin
   copy x86_64-w64-mingw32-gcc.exe gcc.exe
   copy x86_64-w64-mingw32-g++.exe g++.exe

3. Verify:
   gcc --version   -> conda-forge 15.2.0
   g++ --version   -> conda-forge 15.2.0
   where.exe gcc   -> conda env path FIRST

4. Re-run shims if gcc_win-64/gxx_win-64 are ever updated.