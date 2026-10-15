# CUHKSZ-SAI LaTeX Template

A course-work LaTeX template for CUHK-Shenzhen, School of Science and Engineering
(the SAI logo and the AIE3905 grading-schema layout are already wired in). It ships
with both a Chinese and an English document, and both compile with **XeLaTeX**.

| Document | File | Pages |
| --- | --- | --- |
| Chinese | [`AIE3905_Week7_Milestone_Grading_Standard.tex`](./AIE3905_Week7_Milestone_Grading_Standard.tex) | 5 |
| English | [`AIE3905_Week7_Milestone_Grading_Standard_EN.tex`](./AIE3905_Week7_Milestone_Grading_Standard_EN.tex) | 6 |

Both currently build with **0 errors, 0 over/underfull boxes and 0 missing glyphs**.

---

## 1. Requirements

| Component | Notes |
| --- | --- |
| TeX distribution | MiKTeX (Windows) or TeX Live 2023+ (macOS / Linux) |
| Engine | **XeLaTeX** — pdfLaTeX cannot build either document |
| Python + Pygments | Only needed for the `minted` package. Both documents currently only configure `minted` in the preamble and contain no code listings, so a build succeeds without Pygments. Keep it installed so that adding a `minted` block later does not break the build. |

> **Why XeLaTeX?** The Chinese document loads `ctex` with `fontset=none` and binds the
> CJK fonts to the vendored Noto CJK OpenType files. That combination needs a Unicode
> engine with OpenType support. The English document additionally uses `fontspec` and
> `unicode-math` for Latin Modern. The repository is therefore configured for XeLaTeX
> only — do not switch the recipe to pdfLaTeX.

---

## 2. Quick start on a new machine

1. **Install the TeX distribution**

   | Platform | Command |
   | --- | --- |
   | Windows | `winget install --id MiKTeX.MiKTeX` |
   | macOS | `brew install --cask mactex-no-gui` |
   | Debian / Ubuntu | `sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra texlive-fonts-extra` |
   | Fedora | `sudo dnf install texlive-scheme-full` |
   | Arch | `sudo pacman -S texlive-most texlive-langchinese` |

2. **Clone and install the LaTeX packages + Pygments**

   ```powershell
   # Windows
   git clone <repository-url>
   cd CUHKSZ-SAI-LaTeX_Template
   .\scripts\setup-miktex.ps1
   ```

   ```bash
   # macOS / Linux
   git clone <repository-url>
   cd CUHKSZ-SAI-LaTeX_Template
   chmod +x scripts/*.sh
   ./scripts/setup-texlive.sh
   ```

   Both setup scripts are idempotent: packages that are already present are reported
   and skipped, so re-running them is always safe.

3. **Build**

   ```powershell
   .\scripts\build.ps1 -All            # Windows: both documents
   ```

   ```bash
   ./scripts/build.sh --all            # macOS / Linux: both documents
   ```

   The PDFs land in `tmp/`.

**What the setup scripts do**

- Locate `xelatex.exe` / `xelatex` and fail with install instructions when missing.
- Install every LaTeX package the two documents need (see the table in §4).
  The MiKTeX script probes `miktex packages info` first, because MiKTeX treats a
  re-install of an already-present package as an error.
- Check `pygmentize` and install Pygments through `pip` when it is absent.
- Verify that the vendored fonts, the logo and `fonts/LICENSE.txt` are present.

---

## 3. Building

### VS Code

`.vscode/settings.json` is committed and already contains the build recipe.

- Open either `.tex` file and press **Ctrl+Alt+B**, or run
  **LaTeX Workshop: Build LaTeX project** from the command palette.
- The default recipe is **`xelatex x2 (CJK)`** — XeLaTeX is run twice so that
  `hyperref` bookmarks and page labels settle.
- Output directory is `tmp/`; **Ctrl+Alt+V** opens the PDF in a tab, and SyncTeX
  (forward and inverse search) is enabled.

The recipe is chosen through `latex-workshop.latex.recipe.default`. Magic comments are
deliberately disabled, so the `% !TEX program = xelatex` line at the top of each file is
documentation rather than a setting.

### Command line

| Windows | macOS / Linux | Effect |
| --- | --- | --- |
| `.\scripts\build.ps1` | `./scripts/build.sh` | Build the Chinese document |
| `.\scripts\build.ps1 -All` | `./scripts/build.sh --all` | Build both documents |
| `.\scripts\build.ps1 -Clean` | `./scripts/build.sh --clean` | Empty `tmp/` first |
| `.\scripts\build.ps1 -Document AIE3905_Week7_Milestone_Grading_Standard_EN` | `./scripts/build.sh AIE3905_Week7_Milestone_Grading_Standard_EN` | Build one document by base name |

Both scripts run XeLaTeX twice, then report the error, over/underfull-box and
missing-character counts parsed from `tmp/<document>.log`, and finally print the
produced PDF, or a non-zero exit code when the build failed.

### Manually

```powershell
xelatex -synctex=1 -shell-escape -interaction=nonstopmode -file-line-error `
        -output-directory=./tmp AIE3905_Week7_Milestone_Grading_Standard.tex
```

Run it **twice**, and keep `-output-directory=./tmp` as a single token. The documents
reference `./figs/...` and `./fonts/...` with paths relative to the build directory,
so always invoke XeLaTeX from the repository root.

---

## 4. LaTeX package dependencies

`scripts/setup-miktex.ps1` and `scripts/setup-texlive.sh` install the MiKTeX /
TeX Live package names below. They are the distributions' bundle names, not the
`\usepackage` names.

| `\usepackage` | MiKTeX / TeX Live package | Provided by |
| --- | --- | --- |
| — (engine) | `xetex` | `xelatex.exe` |
| — (engine) | `l3kernel`, `l3packages` | LaTeX3 programming layer |
| `array`, `tabularx` | `latex-tools` (`tools` on TeX Live) | Standard tools bundle |
| — | `latex-fonts` (`fix-cm` on TeX Live) | CM font fixes |
| `bookmark` | `bookmark` | PDF bookmark driver |
| `fontspec` | `fontspec` | OpenType font selection |
| `amsmath` | `amsmath` | Math typesetting |
| `unicode-math` | `unicode-math` | OpenType math |
| `ctex` | `ctex` | CJK support (`xeCJK`, `zhnumber`) |
| `needspace` | `needspace` | Page-break control |
| `geometry` | `geometry` | Page layout |
| `minted` | `minted` | Code listings (needs Pygments) |
| `xcolor` | `xcolor` | Colour |
| `graphicx` | `graphics` | `\includegraphics` |
| `titling` | `titling` | Title-block control |
| `enumitem` | `enumitem` | List customisation |
| `fancyhdr` | `fancyhdr` | Header / footer |
| `hyperref` | `hyperref` | Hyperlinks, PDF metadata |
| — (fonts) | `lm`, `lm-math` | Latin Modern OpenType |

MiKTeX installs missing packages on demand, so a plain build often works even before
the setup script runs. The scripts exist to make the process fast, offline-capable and
reproducible.

---

## 5. Repository layout

```
CUHKSZ-SAI-LaTeX_Template/
├── .gitattributes                                line endings, binary assets
├── .gitignore                                    build output and editor junk
├── LICENSE                                       MIT
├── README.md                                     this file
├── README.zh-CN.md                               Chinese translation
├── .vscode/
│   └── settings.json                             LaTeX Workshop recipe (xelatex x2)
├── AIE3905_Week7_Milestone_Grading_Standard.tex      Chinese document
├── AIE3905_Week7_Milestone_Grading_Standard_EN.tex   English document
├── figs/
│   └── cuhk-sai-logo01.png                       header logo (used by \fancyhead)
├── fonts/                                        vendored Noto CJK OpenType fonts
│   ├── LICENSE.txt                               SIL Open Font License 1.1
│   ├── NotoSerifSC-Regular.otf
│   ├── NotoSerifSC-Bold.otf
│   ├── NotoSansSC-Regular.otf
│   └── NotoSansSC-Bold.otf
├── scripts/
│   ├── setup-miktex.ps1                          Windows: install packages + Pygments
│   ├── setup-texlive.sh                          macOS / Linux: same, via tlmgr
│   ├── build.ps1                                 Windows: build
│   └── build.sh                                  macOS / Linux: build
└── tmp/                                          build output (git-ignored)
```

The fonts are vendored rather than downloaded at build time so that the documents
look identical on every machine, including on a machine with no network access.

---

## 6. Editing

- **Page header** — `\fancyhead[C]` in the preamble of each file draws the SAI logo
  from `figs/cuhk-sai-logo01.png` across the full text width. The gap between the header
  rule and the main title is `headsep=8mm` inside the `\geometry{...}` block; raise it to
  push the title further down. `headheight` must stay at least as tall as the logo
  (currently 18.5 mm for a 16.6 mm logo), otherwise `fancyhdr` issues a warning.
- **Chinese fonts** — `\setCJKmainfont` (body), `\setCJKsansfont` (headings) and
  `\newCJKfontfamily\zhhei` (bold CJK), all pointing at `./fonts/`.
- **Latin fonts** — `\setmainfont{lmroman10-regular.otf}` uses the Latin Modern files
  shipped with MiKTeX / TeX Live, not files in this repository.
- **Point size** — `\documentclass[11pt]{article}` at the top of each file.

Keep the two documents in sync: the English file mirrors the Chinese one section by
section, so a content change normally belongs in both.

---

## 7. Licence

- **Template, scripts and documents** — MIT, © 2026 Zijin CAI. The full text is in
  [`LICENSE`](./LICENSE).
- **Noto Serif SC / Noto Sans SC** (`fonts/`) — SIL Open Font License 1.1, a separate
  licence that the MIT licence does not override. The full text is in
  [`fonts/LICENSE.txt`](./fonts/LICENSE.txt). The OFL permits redistribution together
  with this repository, including the four font files, as long as the licence travels
  with them and the reserved font names are not used by modified versions.
  Upstream: <https://github.com/notofonts/noto-cjk>.
- **CUHK-Shenzhen logo** (`figs/cuhk-sai-logo01.png`) — the university's trademark. It is
  included for use in course material only; it is not covered by the MIT licence, and the
  MIT licence does not grant any right to reuse it.
