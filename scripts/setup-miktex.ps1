#Requires -Version 5.1
<#
.SYNOPSIS
    Install everything needed to build this template on Windows with MiKTeX.

.DESCRIPTION
    * locates the MiKTeX installation (PATH first, then the default install dirs)
    * installs the LaTeX packages that the report entry points use
    * makes sure Pygments is available so that minted code blocks keep working
    * verifies that the CJK fonts vendored in fonts/ are still present
    * reports a missing letterhead without failing (nologo is supported)

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

# MiKTeX writes progress, warnings and "unknown package" notices to stderr.
# This script runs with $ErrorActionPreference = 'Stop', and Windows PowerShell
# 5.1 turns redirected native stderr into a terminating NativeCommandError, so a
# single unknown package id would abort the whole setup instead of being
# reported.  Run native commands with 'Continue' and keep their exit code.
function Invoke-MiktexCommand {
    param([string]$Exe, [string[]]$Arguments)
    $saved = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $Exe @Arguments 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $saved
    }
    return [pscustomobject]@{
        Output   = ($output -join ' ')
        ExitCode = $code
    }
}

# ---------------------------------------------------------------------------
#  MiKTeX package IDs.
#  MiKTeX resolves transitive dependencies on its own, so only the directly
#  used packages are listed here.
#  latex-tools -> array.sty + tabularx.sty + longtable.sty,
#  graphics -> graphicx.sty, lm / lm-math -> Latin Modern OpenType fonts,
#  ctex -> xeCJK + zhnumber, biblatex -> bibliography (biber is resolved
#  separately below, because its package id is architecture specific),
#  latexmk -> the VS Code recipe.
# ---------------------------------------------------------------------------
$packages = @(
    'xetex',
    'l3kernel',
    'l3packages',
    'fontspec',
    'amsmath',
    'unicode-math',
    'lm',
    'lm-math',
    'ctex',
    'geometry',
    'fancyhdr',
    'graphics',
    'latex-tools',
    'booktabs',
    'float',
    'caption',
    'enumitem',
    'needspace',
    'etoolbox',
    'xcolor',
    'minted',
    'listings',
    'csquotes',
    'biblatex',
    'biber',
    'hyperref',
    'bookmark',
    'latexmk'
)

# ---------------------------------------------------------------------------
#  Locate the MiKTeX binaries
# ---------------------------------------------------------------------------
$searchDirs = @()
foreach ($base in @($env:LOCALAPPDATA, $env:ProgramFiles, ${env:ProgramFiles(x86)})) {
    if ($base) {
        # A user-scope MiKTeX installs under %LOCALAPPDATA%\Programs; a
        # machine-wide one under %ProgramFiles%.
        $searchDirs += (Join-Path $base 'Programs\MiKTeX\miktex\bin\x64')
        $searchDirs += (Join-Path $base 'MiKTeX\miktex\bin\x64')
    }
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
$binDir = Split-Path -Parent $xelatex
Write-Pass "xelatex : $xelatex"

# Put the MiKTeX bin directory on PATH for the rest of the session.  TeX itself
# invokes helpers through the shell (minted calls latexminted), and a freshly
# installed MiKTeX has not necessarily updated the caller's PATH yet.
if ($env:PATH -notlike "*$binDir*") {
    $env:PATH = "$binDir;$env:PATH"
}

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

$packageFailures = 0
foreach ($pkg in $packages) {
    # Recent MiKTeX releases publish biber per architecture; there is no plain
    # "biber" package id any more, so probe the known ids instead of assuming
    # one name that a given MiKTeX version may not know.
    $candidates = if ($pkg -eq 'biber') {
        @('biber-windows-x64', 'biber-ms-windows-x64', 'biber')
    }
    else {
        @($pkg)
    }

    $installed = $false
    $detail = ''
    foreach ($id in $candidates) {
        if ($newCli) {
            $probe = Invoke-MiktexCommand $miktex @('packages', 'info', $id)
            if ($probe.Output -match 'isInstalled: true') {
                Write-Pass "$id (already installed)"
                $installed = $true
                break
            }
            if ($probe.ExitCode -ne 0) {
                # Unknown package id for this MiKTeX version: try the next one.
                $detail = "$id -> $($probe.Output)"
                continue
            }
            $result = Invoke-MiktexCommand $miktex @('packages', 'install', $id)
        }
        else {
            $result = Invoke-MiktexCommand $mpm @("--install=$id")
        }

        if ($result.ExitCode -eq 0) {
            Write-Pass "$id installed"
            $installed = $true
            break
        }
        if ($result.Output -match 'already installed') {
            Write-Pass "$id (already installed)"
            $installed = $true
            break
        }
        $detail = "$id -> $($result.Output)"
    }

    if (-not $installed) {
        Write-Fail "$pkg -> $detail"
        $packageFailures++
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
    'fonts\LICENSE.txt'
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

if (Test-Path -LiteralPath (Join-Path $repoRoot 'assets\sai-letterhead.png')) {
    Write-Pass 'assets\sai-letterhead.png'
}
else {
    Write-Note 'assets\sai-letterhead.png is missing.'
    Write-Note 'Add the letterhead back, or set \SAIReportLogo{} and load the style with [nologo].'
}

Write-Host ''
$failed = $false
if ($missingAssets -gt 0) {
    Write-Host "$missingAssets asset(s) are missing - restore them before building." -ForegroundColor Red
    $failed = $true
}
if ($packageFailures -gt 0) {
    Write-Host "$packageFailures LaTeX package(s) could not be installed - the build will probably fail." -ForegroundColor Red
    $failed = $true
}

if ($failed) {
    exit 1
}

Write-Host 'Setup finished.  Build the documents with:' -ForegroundColor Green
Write-Host '    .\scripts\build.ps1 -All'
