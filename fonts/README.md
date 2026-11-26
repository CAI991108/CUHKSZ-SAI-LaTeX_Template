# Fonts

Four static Noto CJK OpenType fonts are vendored here so that the Chinese report builds
without asking the system for a Chinese font:

- `NotoSerifSC-Regular.otf`, `NotoSerifSC-Bold.otf` — body text;
- `NotoSansSC-Regular.otf`, `NotoSansSC-Bold.otf` — headings and `\zhhei`.

Noto Serif SC is Copyright 2017–2024 Adobe; Noto Sans SC is Copyright 2014–2021
Adobe. Noto is a trademark of Google Inc. Both families are licensed under the
**SIL Open Font License 1.1**; the full text is in `LICENSE.txt`. Upstream:
<https://github.com/notofonts/noto-cjk>.

`styles/sai-report.sty` loads them with `Path=\SAIAssetRoot fonts/`, so keep the file
names if you replace them. Replacing them with system fonts gives up reproducibility.
