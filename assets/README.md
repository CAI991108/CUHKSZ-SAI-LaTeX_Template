# Letterhead

`sai-letterhead.png` is the SAI letterhead used by the template. `metadata.tex` points
`\SAIReportLogo` at it, and `styles/sai-report.sty` places it on the title page and in
the page header.

## Usage boundary

The letterhead is a university identifier, **not** an MIT-licensed asset. It is included
for SAI course and member documents. Do not use it in unrelated projects or redistribute
it as a standalone image. See [`../NOTICE.md`](../NOTICE.md).

## Replace it

1. Put your own image here (PNG or PDF).
2. Set `\SAIReportLogo{assets/your-image.png}` in [`../metadata.tex`](../metadata.tex).
3. If you do not have a letterhead, set `\SAIReportLogo{}` and load the style with
   `\usepackage[nologo]{styles/sai-report}`.

## Source

The official SAI letterhead. If you need a vector or updated version, get it from the
school rather than redrawing it.
