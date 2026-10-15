#Requires -Version 5.1
<#
.SYNOPSIS
    Build the template documents with XeLaTeX.

.DESCRIPTION
    Both documents must be built with XeLaTeX - the Chinese one needs ctex with
    the vendored Noto CJK fonts, and pdfLaTeX cannot handle either of them.
    XeLaTeX is run twice so that cross references settle.

    Output goes to tmp\ because that is what .vscode/settings.json tells the
    LaTeX Workshop PDF viewer to open.

.PARAMETER Document
    Base name of a single document, without the .tex extension.
    Defaults to the Chinese version.

.PARAMETER All
    Build both the Chinese and the English document.

.PARAMETER Clean
    Empty tmp\ before building.

.EXAMPLE
    .\scripts\build.ps1 -All
.EXAMPLE
    .\scripts\build.ps1 -Document AIE3905_Week7_Milestone_Grading_Standard_EN -Clean
#>
[CmdletBinding()]
param(
    [string]$Document = 'AIE3905_Week7_Milestone_Grading_Standard',
    [switch]$All,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$outDir   = Join-Path $repoRoot 'tmp'

$allDocs = @(
    'AIE3905_Week7_Milestone_Grading_Standard',
    'AIE3905_Week7_Milestone_Grading_Standard_EN'
)

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

$xelatex = Resolve-Tool 'xelatex.exe' $searchDirs
if (-not $xelatex) {
    Write-Host 'xelatex was not found.  Run .\scripts\setup-miktex.ps1 first.' -ForegroundColor Red
    exit 1
}

$documents = @()
if ($All) { $documents = $allDocs } else { $documents = @($Document) }

if ($Clean -and (Test-Path -LiteralPath $outDir)) {
    Get-ChildItem -LiteralPath $outDir -Force | Remove-Item -Recurse -Force
}
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$failures = 0

# xelatex resolves ./figs and ./fonts relative to the working directory,
# so the build has to run from the repository root.
Push-Location $repoRoot
try {
    foreach ($doc in $documents) {
        $texFile = $doc + '.tex'
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $texFile))) {
            Write-Host "skip: $texFile not found" -ForegroundColor Yellow
            $failures++
            continue
        }

        Write-Host "==> $texFile" -ForegroundColor Cyan

        # Keep every option as its own array element; splatting the array with
        # @xelatexArgs hands the arguments to the process untouched.
        $xelatexArgs = @(
            '-synctex=1',
            '-shell-escape',
            '-interaction=nonstopmode',
            '-file-line-error',
            '-output-directory=./tmp',
            $texFile
        )

        for ($pass = 1; $pass -le 2; $pass++) {
            & $xelatex @xelatexArgs | Out-Null
            Write-Host "    pass $pass (exit $LASTEXITCODE)"
        }

        $log = Join-Path $outDir ($doc + '.log')
        $pdf = Join-Path $outDir ($doc + '.pdf')

        if (Test-Path -LiteralPath $log) {
            $logText = [System.IO.File]::ReadAllText($log, [System.Text.Encoding]::UTF8)
            $errors   = ([regex]'\.tex:\d+:').Matches($logText).Count
            $overfull = ([regex]'(Overfull|Underfull)').Matches($logText).Count
            $missing  = ([regex]'Missing character').Matches($logText).Count

            if ($errors -gt 0) {
                Write-Host "    $errors error(s) - see tmp\$doc.log" -ForegroundColor Red
                $failures++
            }
            else {
                Write-Host "    clean: 0 errors, $overfull over/underfull box(es), $missing missing character(s)"
            }
        }

        if (Test-Path -LiteralPath $pdf) {
            $kb = [math]::Round((Get-Item -LiteralPath $pdf).Length / 1KB)
            Write-Host "    tmp\$doc.pdf  ($kb KB)" -ForegroundColor Green
        }
        else {
            Write-Host "    no PDF was produced - see tmp\$doc.log" -ForegroundColor Red
            $failures++
        }
    }
}
finally {
    Pop-Location
}

Write-Host ''
if ($failures -eq 0) {
    Write-Host 'Build finished.' -ForegroundColor Green
    exit 0
}
Write-Host "Build finished with $failures problem(s)." -ForegroundColor Red
exit 1
