#Requires -Version 5.1
<#
.SYNOPSIS
    Build the SAI report template with XeLaTeX on Windows.

.DESCRIPTION
    Entry points are discovered automatically: every main-*.tex in the template
    root is a document.  The Chinese entry needs ctex with the vendored Noto CJK
    fonts; the English entry only needs the Latin Modern OpenType fonts.  Both
    need XeLaTeX and minted (Pygments); documents with a bibliography also need
    biber.

    XeLaTeX runs twice so that cross references settle.  When a .bcf file
    appears, biber runs between the first and second pass and a third XeLaTeX
    pass is added so that the bibliography settles.

    A document is clean only when its log has zero real errors, zero
    overfull/underfull boxes and zero missing characters.  Any failure returns a
    non-zero exit code.

.PARAMETER Document
    Base name of one document, without the .tex extension.

.PARAMETER All
    Build every main-*.tex entry point (the default when -Document is omitted).

.PARAMETER Clean
    Empty the output directory before building.

.PARAMETER OutDir
    Output directory, relative to the template root.  Defaults to tmp.

.EXAMPLE
    .\scripts\build.ps1 -All
.EXAMPLE
    .\scripts\build.ps1 -Document main-en
.EXAMPLE
    .\scripts\build.ps1 -Clean -All
#>
[CmdletBinding()]
param(
    [string]$Document = '',
    [switch]$All,
    [switch]$Clean,
    [string]$OutDir = 'tmp'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

if ([System.IO.Path]::IsPathRooted($OutDir)) {
    $outDir = $OutDir
}
else {
    $outDir = Join-Path $repoRoot $OutDir
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

$searchDirs = @()
foreach ($base in @($env:LOCALAPPDATA, $env:ProgramFiles, ${env:ProgramFiles(x86)})) {
    if ($base) { $searchDirs += (Join-Path $base 'MiKTeX\miktex\bin\x64') }
}

$xelatex = Resolve-Tool 'xelatex.exe' $searchDirs
if (-not $xelatex) {
    Write-Host 'xelatex was not found.  Run .\scripts\setup-miktex.ps1 first.' -ForegroundColor Red
    exit 1
}

$biber = Resolve-Tool 'biber.exe' $searchDirs
$pygmentize = Resolve-Tool 'pygmentize.exe' $searchDirs
if (-not $pygmentize) {
    Write-Host 'warning: pygmentize was not found; minted code blocks will fail.' -ForegroundColor Yellow
}

$allDocs = @(Get-ChildItem -Path (Join-Path $repoRoot 'main-*.tex') -File | ForEach-Object { $_.BaseName } | Sort-Object)
if ($allDocs.Count -eq 0) {
    Write-Host "no main-*.tex entry points found in $repoRoot" -ForegroundColor Red
    exit 2
}

$documents = @()
if ($All -or -not $Document) {
    $documents = $allDocs
}
else {
    $documents = @($Document)
}

$outDirFull = [System.IO.Path]::GetFullPath($outDir)
$repoRootFull = [System.IO.Path]::GetFullPath($repoRoot)
if (-not $outDirFull.StartsWith($repoRootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    if ($Clean) {
        Write-Host "refusing to clean an output directory outside the template: $outDirFull" -ForegroundColor Red
        exit 2
    }
}

if ($Clean -and (Test-Path -LiteralPath $outDir)) {
    Get-ChildItem -LiteralPath $outDir -Force | Remove-Item -Recurse -Force
}
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$failures = 0
$built = 0

# xelatex resolves ./fonts, ./figures and \input paths relative to the working
# directory, so every build runs from the template root.
Push-Location $repoRoot
try {
    foreach ($doc in $documents) {
        $texFile = $doc + '.tex'
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $texFile))) {
            Write-Host "$texFile not found" -ForegroundColor Red
            $failures++
            continue
        }

        Write-Host "==> $texFile" -ForegroundColor Cyan
        $docFailures = 0

        $xelatexArgs = @(
            '-synctex=1',
            '-shell-escape',
            '-interaction=nonstopmode',
            '-file-line-error',
            "-output-directory=$outDirFull",
            $texFile
        )

        # Pass 1: write .aux/.bcf and the first .toc.
        & $xelatex @xelatexArgs | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host '    pass 1 failed' -ForegroundColor Red
            $docFailures++
        }

        $passes = 2
        if (Test-Path -LiteralPath (Join-Path $outDir ($doc + '.bcf'))) {
            $passes = 3
            if ($biber) {
                & $biber "--input-directory=$outDirFull" "--output-directory=$outDirFull" $doc | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host '    biber ok'
                }
                else {
                    Write-Host "    biber failed - see ${doc}.biber.log" -ForegroundColor Red
                    $docFailures++
                }
            }
            else {
                Write-Host '    biber was not found; bibliography will be empty' -ForegroundColor Red
                $docFailures++
            }
        }

        # Remaining passes: settle TOC, references and the bibliography.
        for ($pass = 2; $pass -le $passes; $pass++) {
            & $xelatex @xelatexArgs | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "    pass $pass failed" -ForegroundColor Red
                $docFailures++
            }
        }

        $log = Join-Path $outDir ($doc + '.log')
        $pdf = Join-Path $outDir ($doc + '.pdf')

        if (Test-Path -LiteralPath $log) {
            $logText = [System.IO.File]::ReadAllText($log, [System.Text.Encoding]::UTF8)
            # "ignored error:" marks a TeX error that LaTeX recovered from.  A
            # longtable page split emits one; the output is unaffected.
            $errors = ([regex]'\.tex:\d+:(?! ignored error:)').Matches($logText).Count
            $boxes = ([regex]'(Overfull|Underfull)').Matches($logText).Count
            $missing = ([regex]'Missing character').Matches($logText).Count

            Write-Host "    $passes pass(es), $errors error(s), $boxes box(es), $missing missing character(s)"

            if ($errors -gt 0 -or $boxes -gt 0 -or $missing -gt 0) {
                Write-Host "    not clean - see $doc.log" -ForegroundColor Red
                $docFailures++
            }
        }
        else {
            Write-Host '    no log was produced' -ForegroundColor Red
            $docFailures++
        }

        if (Test-Path -LiteralPath $pdf) {
            $kb = [math]::Round((Get-Item -LiteralPath $pdf).Length / 1KB)
            Write-Host "    $doc.pdf  ($kb KB)" -ForegroundColor Green
        }
        else {
            Write-Host '    no PDF was produced' -ForegroundColor Red
            $docFailures++
        }

        if ($docFailures -gt 0) {
            $failures++
        }
        else {
            $built++
        }
    }
}
finally {
    Pop-Location
}

Write-Host ''
if ($failures -eq 0) {
    Write-Host "Build finished: $built document(s) clean." -ForegroundColor Green
    exit 0
}
Write-Host "Build finished with $failures problem(s)." -ForegroundColor Red
exit 1
