# bundle_dlls.ps1
# Copies the GNU runtime DLLs a .pyd depends on into a distributable folder,
# so a C++ .pyd can run OUTSIDE the conda environment.
#
# Usage:   .\bundle_dlls.ps1 compiled\your_module.cp311-win_amd64.pyd
# Output:  creates dist/ containing the .pyd + its required runtime DLLs
#
# Run from the project root with py_pyd_modern ACTIVE.
# NOTE: Pure-Cython/C .pyd files usually need NO bundling. This is mainly for
#       C++ modules that link libstdc++ / libgcc.

param(
    [Parameter(Mandatory=$true)]
    [string]$PydPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $PydPath)) {
    Write-Error "File not found: $PydPath"
    exit 1
}

# Where the env's runtime DLLs live
$envBin = Join-Path $env:CONDA_PREFIX "Library\bin"
if (-not (Test-Path $envBin)) {
    Write-Error "Cannot find env Library\bin. Is py_pyd_modern activated? (CONDA_PREFIX=$env:CONDA_PREFIX)"
    exit 1
}

# The GNU runtime DLLs a GCC/G++-built .pyd may depend on
$candidateDlls = @(
    "libstdc++-6.dll",
    "libgcc_s_seh-1.dll",
    "libwinpthread-1.dll"
)

Write-Host "=== Inspecting dependencies of $PydPath ===" -ForegroundColor Cyan

# Use objdump (from the GNU toolchain) to list the .pyd's DLL imports
$deps = & objdump -p $PydPath 2>$null | Select-String "DLL Name:" |
        ForEach-Object { ($_ -split "DLL Name:")[1].Trim() }

if (-not $deps) {
    Write-Warning "objdump returned no dependency info (or objdump not found). Falling back to copying all candidate runtime DLLs."
    $deps = $candidateDlls
}

Write-Host "Detected imports:" -ForegroundColor Gray
$deps | ForEach-Object { Write-Host "  $_" }

# Prepare dist/ output folder
if (-not (Test-Path "dist")) { New-Item -ItemType Directory -Path "dist" | Out-Null }

# Copy the .pyd itself
Copy-Item $PydPath -Destination "dist\" -Force
Write-Host "`nCopied .pyd -> dist\" -ForegroundColor Green

# Copy any required GNU runtime DLLs that exist in the env
$copiedCount = 0
foreach ($dll in $candidateDlls) {
    # Only copy if the .pyd actually imports it (or fallback said so)
    if ($deps -contains $dll) {
        $srcDll = Join-Path $envBin $dll
        if (Test-Path $srcDll) {
            Copy-Item $srcDll -Destination "dist\" -Force
            Write-Host "Bundled: $dll" -ForegroundColor Green
            $copiedCount++
        } else {
            Write-Warning "Dependency $dll not found in env bin — may already be on target system."
        }
    }
}

if ($copiedCount -eq 0) {
    Write-Host "`nNo GNU runtime DLLs needed bundling — this .pyd likely runs standalone" -ForegroundColor Yellow
    Write-Host "(pure Cython/C modules typically only need python3XX.dll, present wherever Python runs)." -ForegroundColor Yellow
}

Write-Host "`n=== dist/ contents ===" -ForegroundColor Cyan
Get-ChildItem "dist\" | Format-Table Name, Length