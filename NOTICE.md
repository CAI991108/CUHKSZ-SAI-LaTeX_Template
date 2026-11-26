# Notices

This file collects the licences and attribution for assets that are **not** covered by
the MIT licence in [`LICENSE`](LICENSE).

## Template code and documentation

MIT © 2026 Zijin CAI and contributors. See [`LICENSE`](LICENSE).

## Fonts

- **Noto Serif SC / Noto Sans SC** (the four static OTFs in `fonts/`): Copyright
  2014–2021 Adobe (<http://www.adobe.com/>) and Google Inc. Licensed under the
  **SIL Open Font License 1.1**. The full licence text is in
  [`fonts/LICENSE.txt`](fonts/LICENSE.txt); upstream is
  <https://github.com/notofonts/noto-cjk>.
- **Latin Modern** (loaded from the TeX distribution, not vendored here): GUST Font
  Licence; see the `lm` package documentation in your TeX distribution.

The fonts are vendored so that a clean clone produces the same output offline. If you
replace them, keep the licence terms of the replacement fonts.

## Letterhead

`assets/sai-letterhead.png` is the CUHK-Shenzhen School of Artificial Intelligence
letterhead. It is a university identifier and is **not** licensed under MIT. It is
included so that SAI course and member documents can use the official header. Do not use
it for unrelated projects, and do not redistribute it as a standalone asset. Replace it
with your own image or remove it (`\SAIReportLogo{}` plus the `[nologo]` option). See
[`assets/README.md`](assets/README.md).

## Example report content

`figures/example-figure.pdf` and `.tex`, the sample report prose, the tables under
`tables/`, and `code/example.py` are part of the template and are covered by the MIT
licence. `references.bib` contains bibliographic metadata for published works; the works
themselves remain under their own copyright.

## Third-party packages

The LaTeX packages used by the template (`ctex`, `fontspec`, `minted`, `biblatex`,
`hyperref`, and so on) are distributed with TeX Live / MiKTeX under their own licences;
they are not vendored in this repository except for the Noto CJK fonts listed above.
