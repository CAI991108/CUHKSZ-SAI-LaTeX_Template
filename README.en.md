<div align="center">

<img src="assets/sai-letterhead.png" alt="CUHK-Shenzhen · School of Artificial Intelligence" width="100%">

# SAI Report LaTeX Template

**CUHK-Shenzhen School of Artificial Intelligence · Bilingual report template**

*中文 / English · XeLaTeX · reproducible build · figure / table / code / citation / appendix examples*

[![License: MIT](https://img.shields.io/badge/License-MIT-2ea44f?style=flat-square)](LICENSE)
[![Engine: XeLaTeX](https://img.shields.io/badge/engine-XeLaTeX-008080?style=flat-square&logo=latex&logoColor=white)](#-quick-start)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square)](#-quick-start)
[![Fonts](https://img.shields.io/badge/fonts-Noto%20CJK%20vendored-c2185b?style=flat-square)](fonts/LICENSE.txt)
[![Distribution](https://img.shields.io/badge/distribution-TeX%20Live%20%7C%20MiKTeX-3D6117?style=flat-square)](https://www.tug.org/texlive/)
[![template](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template/actions/workflows/template.yml/badge.svg)](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template/actions/workflows/template.yml)
[![windows-miktex](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template/actions/workflows/windows-miktex.yml/badge.svg)](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template/actions/workflows/windows-miktex.yml)

[简体中文](README.md) · **English**

</div>

---

## What this is

A bilingual LaTeX template for **SAI reports**. It provides:

- two entry points, `main-zh.tex` (Chinese) and `main-en.tex` (English), sharing one
  `styles/sai-report.sty`;
- one `metadata.tex` for the title, subtitle, author, student ID, course, instructor,
  date, logo and keywords;
- a compilable example report: abstract, table of contents, seven sections, a figure,
  tables, a long table, code, citations and an appendix;
- build tooling: environment setup, entry-point discovery, biber, a log gate and a
  bilingual parity check;
- vendored Noto CJK fonts, so a clean clone builds offline.

**What it is not:**

- not the AIE3905 rubric, grading policy or course material;
- not a thesis or dissertation class;
- not a submit-as-is report: replace the example prose with your own.

## Quick start

### 1 · Get the template

Course members (**source repository**, template lives in a subdirectory):

```bash
# private; course members only
git clone https://github.com/CAI991108/AIE3905-Criteria.git
cd AIE3905-Criteria/templates/sai-report
```

External users (**release mirror**, from v1.0):

```bash
git clone https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template.git
cd CUHKSZ-SAI-LaTeX_Template
```

> The source lives at `AIE3905-Criteria/templates/sai-report/`; the public repository
> is a release mirror pushed from the source (see [`PROVENANCE.md`](PROVENANCE.md)).

### 2 · Install a TeX distribution

| Platform | Command |
| --- | --- |
| Windows | `winget install --id MiKTeX.MiKTeX` |
| macOS | `brew install --cask mactex-no-gui` |
| Debian / Ubuntu | `sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra texlive-fonts-extra` |
| Fedora | `sudo dnf install texlive-scheme-full` |
| Arch | `sudo pacman -S texlive-most texlive-langchinese` |

### 3 · Install packages and Pygments

Windows:

```powershell
.\scripts\setup-miktex.ps1
# or, when the execution policy blocks .ps1 files:
.\scripts\setup.cmd
```

macOS / Linux:

```bash
chmod +x scripts/*.sh
./scripts/setup-texlive.sh
```

> Skip this step if your distribution already has `xelatex`, `ctex`, `minted` (or the
> `listings` fallback), `biblatex` and `biber`. Both scripts are idempotent and only add
> what is missing.

### 4 · Build

```bash
./scripts/build.sh --all          # macOS / Linux
.\scripts\build.ps1 -All          # Windows
```

The PDFs are written to `tmp/main-zh.pdf` and `tmp/main-en.pdf`.

- The default builds every `main-*.tex`; `--doc main-en` builds one; `--clean` empties
  the output directory first; `--outdir build` writes elsewhere.
- When a document has a bibliography, the script runs `biber` after the first pass and
  then adds two XeLaTeX passes.
- Log gate: any non-zero count of errors, `Overfull`/`Underfull` boxes or
  `Missing character` fails the build. `ignored error:` lines (the known longtable
  page-split recovery message) are excluded.

VS Code: open **`templates/sai-report`** as the workspace. The default recipe is
`latexmk (xelatex + biber)` and writes to `tmp/`. If you open the repository root, the
template's `.vscode/settings.json` does not apply.

## What to edit first

| Change | File |
| --- | --- |
| Title, subtitle, author, student ID, course, instructor, date, logo, keywords | [`metadata.tex`](metadata.tex) (ZH/EN blocks) |
| Abstract | `frontmatter/zh/abstract.tex` / `frontmatter/en/abstract.tex` |
| Section prose | `sections/zh/*.tex` / `sections/en/*.tex` |
| Add or remove sections | the `\input` lines in `main-zh.tex` / `main-en.tex` |
| Tables | `tables/zh/*.tex` / `tables/en/*.tex` |
| Code | `code/*.py`, included with `\inputminted` |
| Figures | `figures/`, included with `\includegraphics` |
| References | [`references.bib`](references.bib) |
| Page, header, footer, fonts | [`styles/sai-report.sty`](styles/sai-report.sty) (advanced; most reports never touch it) |

For a first report, usually only the fields in `metadata.tex` and the example prose in
`sections/` need to change. **Do not** edit the title, author or course inside
`styles/sai-report.sty`; those belong to `metadata.tex`.

## Directory layout

```
templates/sai-report/                   # the repository root in the public mirror
├── main-zh.tex · main-en.tex           # ZH/EN entry points: \input sections, bibliography, appendix
├── metadata.tex                        # the one metadata file to edit
├── styles/sai-report.sty               # shared style: fonts, page, header/footer, title page, table/code helpers
├── frontmatter/{zh,en}/abstract.tex    # abstract and keywords
├── sections/{zh,en}/                   # seven sections + appendix, structurally identical
│   ├── 01-introduction.tex
│   ├── 02-related-work.tex
│   ├── 03-method.tex
│   ├── 04-implementation.tex
│   ├── 05-evaluation.tex
│   ├── 06-discussion.tex
│   ├── 07-conclusion.tex
│   └── appendix.tex
├── tables/{zh,en}/                     # formal table + longtable
├── code/example.py                     # code example (minted / listings)
├── figures/                            # example figure (with regenerable TikZ source)
├── references.bib                      # biblatex / biber
├── docs/xelatex-notes.md               # XeLaTeX pitfalls and verification checklist
├── assets/sai-letterhead.png           # SAI letterhead
├── fonts/                              # vendored Noto CJK + the OFL licence
├── scripts/
│   ├── setup-miktex.ps1 · setup-texlive.sh    # packages + Pygments
│   ├── build.ps1 · build.sh                   # build + log gate + biber
│   └── check-parity.py                        # ZH/EN structural comparison
├── .github/                            # public-mirror CI (template.yml, windows-miktex.yml) + dependabot
├── .vscode/settings.json               # LaTeX Workshop recipe
├── CONTRIBUTING.md · NOTICE.md         # release checklist + licence notices
├── .gitattributes · .gitignore · LICENSE
└── tmp/                                # build output (ignored)
```

## Keeping the two languages in sync

- The two entry points share `metadata.tex`, `styles/`, `references.bib`, `figures/`
  and `tables/`; language-specific prose lives in `sections/zh/` and `sections/en/`.
- Keep the same `section` / `subsection` order, the same `\label` keys and the same
  `\cite` / `\ref` keys on both sides. The prose may differ; the structure must not.
- Before committing, run:

  ```bash
  python3 scripts/check-parity.py
  ```

  It compares heading levels, label order, the cite/ref multisets and the number of
  figures, tables and longtables. CI runs it too.
- If you change one language first, keep the other side structurally complete;
  otherwise the parity check fails.
- Figure/table numbers, section order and citation keys must match in both languages.

## Typography conventions

- **Figures.** Use `figure` + `\includegraphics` + `\caption` + `\label`, then
  `\figsource{...}` after the caption. Reference with `图~\ref{...}` in Chinese and
  `Figure~\ref{...}` in English.
- **Tables.** Use `table` + `\formaltable` + `tabularx` (the `Y` column wraps) for
  formal tables; `booktabs` for results; `longtable` with `\endhead` for tables that
  break across pages. Do not put only an `\hline` in `\endfoot`.
- **Code.** The default is `minted`, which needs `-shell-escape` and Pygments; the build
  scripts handle both. If the environment blocks shell-escape (some Overleaf plans), add
  `plaincode` to the style options: `\usepackage[plaincode]{styles/sai-report}`; code
  blocks then use `listings` and Pygments is not needed. See `code/example.py` and
  `sections/*/04-implementation.tex`.
- **Citations.** `biblatex` numeric + `biber`; write `\cite{key}`; the entry points call
  `\printbibliography`.
- **Appendix.** Use `\section{...}` after `\appendix`; the example is "Supplementary
  Material".
- **Page.** A4, 170mm × 241mm text block, 11pt; title page + header logo + footer with
  date, page number and course.
- **Build output.** `tmp/` is disposable; do not commit it. `--clean` empties it.

## Fonts, licence and logo

| Scope | Licence |
| --- | --- |
| Template, scripts, documentation | **MIT** © 2026 Zijin CAI and contributors, see [`LICENSE`](LICENSE) |
| Noto Serif SC / Noto Sans SC | **SIL OFL 1.1**, see [`fonts/LICENSE.txt`](fonts/LICENSE.txt) |
| Latin Modern | shipped with TeX Live, GUST font licence |
| SAI letterhead | **not** covered by MIT; for SAI course/member documents only, see [`assets/README.md`](assets/README.md) |

Font upstream: <https://github.com/notofonts/noto-cjk>.

**Replacing the logo:** point `\SAIReportLogo` in `metadata.tex` at your own letterhead,
or set `\SAIReportLogo{}` and load the style with `\usepackage[nologo]{styles/sai-report}`.
Do not put an unauthorised partner logo, real student data or internal course policy in
a public copy of the template.

## Where course-specific material lives

Course rubrics, cohort policy and make-up/absence rules belong to the course repository,
not to the template. AIE3905 LaTeX handouts live under
`docs/guidance/latex/week7-milestone/` in the source repository; this template keeps only
the generic skeleton, examples and tooling. Do not copy course grading policy into
`templates/sai-report/`.

To use the template for a course report, either:

1. copy the whole `templates/sai-report/` directory and edit `metadata.tex` and
   `sections/`; or
2. keep your own document and point `\SAIAssetRoot` at the template's `fonts/` and
   `assets/`, then `\usepackage[...]{.../styles/sai-report}`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `xelatex was not found` | Install TeX Live / MiKTeX, or run the setup script |
| `fontspec` / `ctex` cannot find a font | Check the four OTFs in `fonts/`; point `\SAIAssetRoot` at the directory containing `fonts/` |
| `minted` reports `pygmentize` | Install Pygments; the build scripts already pass `-shell-escape` |
| `biber was not found` / empty bibliography | Install biber; `build.sh` / `build.ps1` run it automatically |
| `ignored error:` in the log | Known longtable page-split recovery message; the build gate excludes it |
| `headheight is too small` | The letterhead is taller than 18.5mm; adjust geometry in `styles/sai-report.sty` or use `[nologo]` |
| `Overfull` / `Underfull` | The build fails; check narrow columns, long URLs, unbreakable words or column widths |
| Windows refuses to run `.ps1` | Use `scripts\build.cmd` / `scripts\setup.cmd` |
| Overleaf | Needs XeLaTeX + the vendored fonts; if minted/shell-escape is blocked, add `plaincode` to the style options (`\usepackage[plaincode]{styles/sai-report}`) and code blocks use `listings` |

## Release and versions

- **Source:** `templates/sai-report/` in the `AIE3905-Criteria` repository.
- **Release mirror:** <https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template>.
  Release flow: tag the source, `git subtree split --prefix=templates/sai-report`, push
  to the mirror, then tag the mirror. See [`PROVENANCE.md`](PROVENANCE.md) and
  [`CONTRIBUTING.md`](CONTRIBUTING.md).
- **Version:** The v1.0.x series is the first release of the generic report template.
  Future template changes start in the source repository and are released to the mirror.
- **Pre-release check:** run `./scripts/check-release.sh` in the template root (needs
  XeLaTeX); use `--skip-build` to inspect existing PDFs only.
- **Windows check:** the `windows-miktex` workflow builds on a real Windows + MiKTeX
  runner on `v*` tags and on demand (about 8 minutes); everyday pushes only run the
  TeX Live job in `template.yml`.
- The old public issues #5–#10 (from the course-rubric era) are superseded by map #1 in
  the source repository and are closed at release with pointers.

## Licence

The template code and documentation are MIT; the vendored fonts are under SIL OFL 1.1;
the SAI letterhead is outside the MIT grant. See [`LICENSE`](LICENSE),
[`fonts/LICENSE.txt`](fonts/LICENSE.txt), [`NOTICE.md`](NOTICE.md) and
[`assets/README.md`](assets/README.md).

## Related documents

- [`PROVENANCE.md`](PROVENANCE.md) — where the template came from and how it is maintained
- [`NOTICE.md`](NOTICE.md) — fonts, logo and third-party asset licences
- [`assets/README.md`](assets/README.md) — letterhead usage boundary and replacement
- [`docs/xelatex-notes.md`](docs/xelatex-notes.md) — XeLaTeX pitfalls and verification checklist
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — pre-release checklist
