#Requires -Version 5.1
<#
.SYNOPSIS
    Install everything needed to build this template on Windows with MiKTeX.

.DESCRIPTION
    * locates the MiKTeX installation (PATH first, then the default install dirs)
    * installs the LaTeX packages that the two documents pull in
    * makes sure Pygments is available so that minted code blocks keep working
    * verifies that the CJK fonts vendored in fonts/ are still present

    The script is idempotent: re-running it only reports what is already in place.

.PARAMETER SkipPygments
    Leave Python and Pygments alone.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\setup-miktex.ps1
#>
[CmdletBinding()]
param(
    [switch]$SkipPygments
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

function Write-Step { param([string]$Text) Write-Host "==> $Text" -ForegroundColor Cyan }
function Write-Pass { param([string]$Text) Write-Host "    ok    $Text" -ForegroundColor Green }
function Write-Note { param([string]$Text) Write-Host "    note  $Text" -ForegroundColor Yellow }
function Write-Fail { param([string]$Text) Write-Host "    FAIL  $Text" -ForegroundColor Red }

# ---------------------------------------------------------------------------
#  MiKTeX package IDs.
#  MiKTeX resolves transitive dependencies on its own, so only the directly
#  \usepackage'd packages (plus the two font packages) are listed here.
#  latex-tools -> array.sty + tabularx.sty, xltabular -> longtable + tabularx
#  (tables that break across pages), graphics -> graphicx.sty,
#  lm / lm-math -> the OpenType Latin Modern fonts, ctex -> xeCJK + zhnumber.
# ---------------------------------------------------------------------------
$packages = @(
    'xetex',
    'l3kernel',
    'l3packages',
    'latex-tools',
    'xltabular',
    'latex-fonts',
    'bookmark',
    'fontspec',
    'amsmath',
    'unicode-math',
    'ctex',
    'needspace',
    'geometry',
    'minted',
    'xcolor',
    'graphics',
    'titling',
    'enumitem',
    'fancyhdr',
    'hyperref',
    'lm',
    'lm-math'
)

# ---------------------------------------------------------------------------
#  Locate the MiKTeX binaries
# ---------------------------------------------------------------------------
$searchDirs = @()
foreach ($base in @($env:LOCALAPPDATA, $env:ProgramFiles, ${env:ProgramFiles(x86)})) {
    if ($base) { $searchDirs += (Join-Path $base 'MiKTeX\miktex\bin\x64') }
}

function Resolve-Tool {
    param([string]$Name, [string[]]$Dirs)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($d in $Dirs) {
        $p = Join-Path $d $Name
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

Write-Step 'Locating MiKTeX'
$xelatex = Resolve-Tool 'xelatex.exe' $searchDirs
if (-not $xelatex) {
    Write-Fail 'xelatex was not found.'
    Write-Host ''
    Write-Host '    Install MiKTeX first, then re-run this script:' -ForegroundColor Yellow
    Write-Host '        winget install --id MiKTeX.MiKTeX'
    Write-Host '    or download it from https://miktex.org/download'
    exit 1
}
Write-Pass "xelatex : $xelatex"

$binDir = Split-Path -Parent $xelatex
$miktex = Join-Path $binDir 'miktex.exe'
$mpm    = Join-Path $binDir 'mpm.exe'

# ---------------------------------------------------------------------------
#  Install the LaTeX packages
# ---------------------------------------------------------------------------
Write-Step 'Installing LaTeX packages'

$newCli = Test-Path -LiteralPath $miktex
$oldCli = Test-Path -LiteralPath $mpm
if (-not ($newCli -or $oldCli)) {
    Write-Fail "neither miktex.exe nor mpm.exe was found in $binDir"
    exit 1
}
if (-not $newCli) { Write-Note 'old MiKTeX (mpm) detected; falling back to --install=<id>' }

foreach ($pkg in $packages) {
    if ($newCli) {
        $probe = & $miktex packages info $pkg 2>&1
        if ($probe -match 'isInstalled: true') {
            Write-Pass "$pkg (already installed)"
            continue
        }
        $output = & $miktex packages install $pkg 2>&1
    }
    else {
        $output = & $mpm "--install=$pkg" 2>&1
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Pass "$pkg installed"
    }
    elseif ($output -match 'already installed') {
        Write-Pass "$pkg (already installed)"
    }
    else {
        Write-Fail "$pkg -> $($output -join ' ')"
    }
}

# ---------------------------------------------------------------------------
#  Pygments, used by the minted package
# ---------------------------------------------------------------------------
if (-not $SkipPygments) {
    Write-Step 'Checking Pygments (minted code blocks)'

    $pygmentize = Resolve-Tool 'pygmentize.exe' @()
    if ($pygmentize) {
        Write-Pass "pygmentize : $pygmentize"
    }
    else {
        $python = Resolve-Tool 'python.exe' @()
        if ($python) {
            Write-Note 'pygmentize is not on PATH; trying python -m pip install --user Pygments'
            & $python -m pip install --user --upgrade Pygments
            $pygmentize = Resolve-Tool 'pygmentize.exe' @()
        }
        else {
            Write-Fail 'Python was not found.'
            Write-Host '    Install Python 3, then run:  python -m pip install --user Pygments' -ForegroundColor Yellow
        }

        if ($pygmentize) {
            Write-Pass "pygmentize : $pygmentize"
            if (-not (Get-Command 'pygmentize' -ErrorAction SilentlyContinue)) {
                Write-Note 'Add the folder above to PATH so that XeLaTeX can find pygmentize.'
            }
        }
        elseif ($python) {
            Write-Note 'Still not found. minted code blocks will fail until pygmentize is on PATH.'
        }
    }
}

# ---------------------------------------------------------------------------
#  Project assets that cannot be regenerated
# ---------------------------------------------------------------------------
Write-Step 'Checking vendored assets'

$assets = @(
    'fonts\NotoSerifSC-Regular.otf',
    'fonts\NotoSerifSC-Bold.otf',
    'fonts\NotoSansSC-Regular.otf',
    'fonts\NotoSansSC-Bold.otf',
    'fonts\LICENSE.txt',
    'figs\cuhk-sai-logo01.png'
)
$missingAssets = 0
foreach ($asset in $assets) {
    $full = Join-Path $repoRoot $asset
    if (Test-Path -LiteralPath $full) {
        Write-Pass $asset
    }
    else {
        Write-Fail "missing: $asset"
        $missingAssets++
    }
}

Write-Host ''
if ($missingAssets -eq 0) {
    Write-Host 'Setup finished.  Build the documents with:' -ForegroundColor Green
    Write-Host '    .\scripts\build.ps1 -All'
}
else {
    Write-Host "$missingAssets asset(s) are missing - restore them before building." -ForegroundColor Red
    exit 1
}
