# Figures

The letterhead lives in `../assets/`; report figures live here. The example figure is
part of the template and is covered by the MIT licence (see `../NOTICE.md`).

`example-figure.pdf` is the pipeline figure used by the example report. Its source is
`example-figure.tex`; regenerate it with:

```bash
xelatex -output-directory=figures figures/example-figure.tex
```

Put your own figures here. Prefer PDF or PNG; reference them from a section with
`\includegraphics{figures/your-figure.pdf}` and add a caption, a label and a
`\figsource{...}` line. The main build does not need TikZ; only the example figure's
source does.
