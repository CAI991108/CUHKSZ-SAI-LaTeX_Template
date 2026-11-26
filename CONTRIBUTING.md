# Contributing to the SAI report template

## Where the source lives

The source of truth is `AIE3905-Criteria/templates/sai-report/`. The public repository
[`CUHKSZ-SAI-LaTeX_Template`](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template) is a
**release mirror**. Do not edit the mirror directly: make the change here, run the checks,
then release with a subtree split (see below).

Course-specific material (rubrics, cohort policy, attendance/make-up rules) does not belong
in this directory. It lives under `docs/guidance/latex/` in the course repository.

## Make a change

1. Edit the relevant file: `metadata.tex`, `sections/{zh,en}/`, `tables/{zh,en}/`,
   `styles/sai-report.sty`, `scripts/`, `README*.md`, `NOTICE.md`, or the assets.
2. From the course repository root, run:

   ```bash
   make template-check     # bilingual parity + ZH/EN build
   ```

   Or, from this directory:

   ```bash
   python3 scripts/check-parity.py
   ./scripts/build.sh --clean --all
   ```

3. Keep the gate green: 0 errors, 0 overfull/underfull boxes, 0 missing characters. The
   only tolerated log line is `ignored error:` from a `longtable` page split; the build
   script excludes it.
4. If you add a LaTeX package, add it to **both** `scripts/setup-texlive.sh` and
   `scripts/setup-miktex.ps1`, and to the package table in `README.md` / `README.en.md`.
5. If you add an asset, put report figures in `figures/` and branding in `assets/`, and
   update [`NOTICE.md`](NOTICE.md) when its licence is not MIT.
6. Keep the Chinese and English sections structurally identical: same heading levels,
   labels, citation keys and cross-references. `check-parity.py` enforces this.

## Pre-release checklist

- [ ] Clean tree; no `tmp/`, no `*.aux`, no local PDFs committed.
- [ ] `make template-check` passes (parity + 0/0/0 for `main-zh` and `main-en`).
- [ ] `./scripts/check-release.sh` passes (grep, PDF metadata, A4, fonts).
- [ ] A clean copy of the template builds with only the repository scripts:
      `git archive` the template to a temporary directory, then run
      `./scripts/build.sh --clean --all` there.
- [ ] `grep -rniE 'AIE3905|S03|S06|Zijin|理工学院|School of Science'` finds only intentional
      provenance/README/NOTICE mentions; the template sources are clean.
- [ ] PDF metadata is generic (example title/author), A4, fonts embedded.
- [ ] The public mirror's workflows (`.github/workflows/template.yml` and
      `windows-miktex.yml` in this directory) build the same files and upload the PDFs.
      `windows-miktex` runs on the release tag; check it before announcing the release.
- [ ] Update `README.md`, `README.en.md` and `NOTICE.md` if the user-facing surface changed.
- [ ] Tag `vX.Y.Z`; split the subtree; push the mirror; tag the mirror; attach the PDFs.
- [ ] Close the superseded public issues (#5–#10) with pointers to the new map/tag.

## Release commands

Run these from the **course repository root** with a clean tree:

```bash
make template-check
./templates/sai-report/scripts/check-release.sh

git tag -a v1.0.0 -m "SAI report template v1.0.0"
git push origin main
git push origin v1.0.0

# Mirror: the split branch should be a descendant of the public main.
git subtree split --prefix=templates/sai-report -b template-v1
git push https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template.git template-v1:main

# Tag the mirror commit as v1.0.0 without clashing with the source tag.
git tag -a public-v1.0.0 -m "SAI report template v1.0.0" template-v1
git push https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template.git \
  refs/tags/public-v1.0.0:refs/tags/v1.0.0
git tag -d public-v1.0.0

rm -rf .git/subtree-cache
```

If the mirror push is not a fast-forward, stop and inspect the mirror history; do not
force-push without an explicit decision.
