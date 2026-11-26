# Tables

`zh/` and `en/` hold the table floats used by the example report:

- `components.tex` — a `table` with the formal (`\formaltable`) style;
- `test-cases.tex` — a `longtable` that repeats its header when it breaks across pages.

Keep the same `\label` in both languages so cross-references stay valid. A section
inputs the table with `\input{tables/zh/components}` (or `tables/en/...`).
