# Provenance

This directory was imported from the standalone
[`CUHKSZ-SAI-LaTeX_Template`](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template)
repository so that the template and the course that uses it can be maintained together.

| Field | Value |
| --- | --- |
| Upstream repository | <https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template> |
| Imported ref | `main` |
| Imported commit | `2282541dadcbdca29ccb4d86181cac26d06c5b77` |
| Imported on | 2026-11-26 |
| Import method | `git subtree add --prefix=templates/sai-report <upstream> main` |

## Where the source of truth lives

The **source of truth is the course repository `AIE3905-Criteria`**, under
`templates/sai-report/` (private). This directory is the template itself. The public
repository is a **release mirror**: it is updated from the source with
`git subtree split --prefix=templates/sai-report` and a tag. See ADR-0004 in the course
repository.

## What this means for changes

- Change the template in the course repository, not in the public mirror. The mirror is
  replaced on release.
- Keep course-specific content out of this directory. AIE3905 material lives in the
  course repository's `docs/guidance/latex/`, not in the template.
- The import preserves the upstream commit history in this repository; the imported files
  were then reorganised into the generic template layout.

## Licence

- Template code and documentation: MIT, see [`LICENSE`](LICENSE).
- Noto Serif SC / Noto Sans SC fonts: SIL Open Font License 1.1, see
  [`fonts/LICENSE.txt`](fonts/LICENSE.txt).
- The university letterhead image is **not** covered by the MIT licence; see
  [`assets/README.md`](assets/README.md) for its usage boundary and how to replace it.
