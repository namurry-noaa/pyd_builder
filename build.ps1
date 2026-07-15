# build.ps1 — Build the extension and place the deliverable .pyd in compiled/
# Run from the project root with the py_pyd_modern conda env ACTIVE.

$ErrorActionPreference = "Stop"

Write-Host "=== Verifying compiler ===" -ForegroundColor Cyan
$gccVersion = (gcc --version | Select-Object -First 1)
Write-Host $gccVersion
if ($gccVersion -notmatch "conda-forge") {
    Write-Warning "gcc does not appear to be the conda-forge compiler! Check env activation and shims."
}

# Record build start time so we only collect FRESHLY built .pyd files
$buildStart = Get-Date

Write-Host "`n=== Building extension ===" -ForegroundColor Cyan
python setup.py build_ext --inplace --compiler=mingw32

Write-Host "`n=== Collecting fresh .pyd into compiled/ ===" -ForegroundColor Cyan
if (-not (Test-Path "compiled")) { New-Item -ItemType Directory -Path "compiled" | Out-Null }

# Search ONLY the project root (NO recursion) for .pyd files created by THIS build.
# This avoids sweeping up archived .pyd files in Verified_Tests/, build/, etc.
$pyds = Get-ChildItem -Path "." -Filter "*.pyd" |          # no -Recurse!
        Where-Object { $_.LastWriteTime -ge $buildStart }   # only files from this build

if ($pyds.Count -eq 0) {
    Write-Warning "No freshly-built .pyd found in project root. Check build output above."
} else {
    foreach ($pyd in $pyds) {
        Move-Item $pyd.FullName -Destination "compiled\" -Force
        Write-Host ("Moved: {0} -> compiled\" -f $pyd.Name) -ForegroundColor Green
    }
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Get-ChildItem "compiled\*.pyd" | Format-Table Name, Length, LastWriteTime