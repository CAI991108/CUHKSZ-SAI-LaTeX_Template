#!/usr/bin/env bash
#
# Build the template documents with XeLaTeX on macOS / Linux.
#
# Both documents must be built with XeLaTeX - the Chinese one needs ctex with
# the vendored Noto CJK fonts, and pdfLaTeX cannot handle either of them.
# XeLaTeX is run twice so that cross references settle.
#
# Output goes to tmp/ because that is what .vscode/settings.json tells the
# LaTeX Workshop PDF viewer to open.
#
# Usage:
#   ./scripts/build.sh                        # the Chinese document
#   ./scripts/build.sh --all                  # both documents
#   ./scripts/build.sh --clean <name> [...]   # empty tmp/ first
#   ./scripts/build.sh AIE3905_Week7_Milestone_Grading_Standard_EN

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTDIR="${ROOT}/tmp"

ALL_DOCS=(
  AIE3905_Week7_Milestone_Grading_Standard
  AIE3905_Week7_Milestone_Grading_Standard_EN
)

CLEAN=0
DOCS=()
for arg in "$@"; do
  case "${arg}" in
    --all)   DOCS+=("${ALL_DOCS[@]}") ;;
    --clean) CLEAN=1 ;;
    -h|--help)
      sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)       DOCS+=("${arg}") ;;
  esac
done
if [ "${#DOCS[@]}" -eq 0 ]; then
  DOCS=("${ALL_DOCS[0]}")
fi

if ! command -v xelatex >/dev/null 2>&1; then
  echo 'xelatex was not found.  Run ./scripts/setup-texlive.sh first.' >&2
  exit 1
fi

if [ "${CLEAN}" -eq 1 ] && [ -d "${OUTDIR}" ]; then
  rm -rf "${OUTDIR:?}"/*
fi
mkdir -p "${OUTDIR}"

FAILURES=0

# xelatex resolves ./figs and ./fonts relative to the working directory,
# so the build has to run from the repository root.
cd "${ROOT}" || exit 1

for doc in "${DOCS[@]}"; do
  if [ ! -f "${doc}.tex" ]; then
    printf '\033[33mskip: %s.tex not found\033[0m\n' "${doc}"
    FAILURES=$((FAILURES + 1))
    continue
  fi

  printf '\033[36m==> %s.tex\033[0m\n' "${doc}"

  for pass in 1 2; do
    xelatex \
      -synctex=1 \
      -shell-escape \
      -interaction=nonstopmode \
      -file-line-error \
      -output-directory=./tmp \
      "${doc}.tex" >/dev/null 2>&1
    printf '    pass %d (exit %d)\n' "${pass}" "$?"
  done

  LOG="${OUTDIR}/${doc}.log"
  PDF="${OUTDIR}/${doc}.pdf"

  if [ -f "${LOG}" ]; then
    ERRORS=$(grep -cE '\.tex:[0-9]+:' "${LOG}" || true)
    OVERFULL=$(grep -cE 'Overfull|Underfull' "${LOG}" || true)
    MISSING=$(grep -c 'Missing character' "${LOG}" || true)
    if [ "${ERRORS}" -gt 0 ]; then
      printf '    \033[31m%d error(s) - see tmp/%s.log\033[0m\n' "${ERRORS}" "${doc}"
      FAILURES=$((FAILURES + 1))
    else
      printf '    clean: 0 errors, %s over/underfull box(es), %s missing character(s)\n' \
        "${OVERFULL}" "${MISSING}"
    fi
  fi

  if [ -f "${PDF}" ]; then
    printf '    \033[32mtmp/%s.pdf  (%s)\033[0m\n' "${doc}" "$(du -h "${PDF}" | cut -f1)"
  else
    printf '    \033[31mno PDF was produced - see tmp/%s.log\033[0m\n' "${doc}"
    FAILURES=$((FAILURES + 1))
  fi
done

echo
if [ "${FAILURES}" -eq 0 ]; then
  printf '\033[32mBuild finished.\033[0m\n'
  exit 0
fi
printf '\033[31mBuild finished with %d problem(s).\033[0m\n' "${FAILURES}"
exit 1
