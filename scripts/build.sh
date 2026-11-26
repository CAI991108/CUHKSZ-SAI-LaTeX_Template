#!/usr/bin/env bash
#
# Build the SAI report template with XeLaTeX on macOS / Linux.
#
# Entry points are discovered automatically: every main-*.tex in the template
# root is a document.  The Chinese entry needs ctex with the vendored Noto CJK
# fonts; the English entry only needs the Latin Modern OpenType fonts.  Both
# need XeLaTeX, minted (Pygments) and, when a bibliography is present, biber.
#
# XeLaTeX runs twice so that cross references and the table of contents settle.
# When a .bcf file appears, biber runs between the first and second pass and a
# third XeLaTeX pass is added so that the bibliography and its citations settle.
#
# Usage:
#   ./scripts/build.sh                    # all main-*.tex
#   ./scripts/build.sh --all              # explicit form of the above
#   ./scripts/build.sh --doc main-en      # one document
#   ./scripts/build.sh --clean --all      # empty the output directory first
#   ./scripts/build.sh --outdir build     # write somewhere other than tmp/
#
# A document is "clean" only when its log has zero real errors, zero
# overfull/underfull boxes and zero missing characters.  Any failure returns a
# non-zero exit code.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTDIR="${ROOT}/tmp"

CLEAN=0
ALL=0
DOCS=()

usage() {
    awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "${BASH_SOURCE[0]}"
}

die() {
    printf '\033[31m%s\033[0m\n' "$1" >&2
    exit 2
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --all)
            ALL=1
            ;;
        --clean)
            CLEAN=1
            ;;
        --doc)
            [ "$#" -ge 2 ] || die "--doc needs a document name"
            DOCS+=("$2")
            shift
            ;;
        --doc=*)
            DOCS+=("${1#*=}")
            ;;
        --outdir)
            [ "$#" -ge 2 ] || die "--outdir needs a path"
            OUTDIR="$2"
            shift
            ;;
        --outdir=*)
            OUTDIR="${1#*=}"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            die "unknown option: $1 (try --help)"
            ;;
        *)
            DOCS+=("$1")
            ;;
    esac
    shift
done

# Resolve a relative output directory against the template root, never against
# the caller's working directory.
case "${OUTDIR}" in
    /*) ;;
    *) OUTDIR="${ROOT}/${OUTDIR}" ;;
esac

# Make xelatex/biber discoverable in the common TeX Live container layout,
# where the binaries live under /opt/texlive/... but PATH is not exported.
if ! command -v xelatex >/dev/null 2>&1; then
    for candidate in /opt/texlive/texdir/bin/*/xelatex; do
        [ -x "${candidate}" ] || continue
        PATH="$(dirname "${candidate}"):${PATH}"
        export PATH
        break
    done
fi
if ! command -v xelatex >/dev/null 2>&1; then
    die "xelatex was not found. Run ./scripts/setup-texlive.sh first."
fi
if ! command -v pygmentize >/dev/null 2>&1; then
    printf '\033[33mwarning: pygmentize was not found; minted code blocks will fail.\033[0m\n'
fi

# Discover entry points.  Do not use find -printf: macOS ships BSD find.
ALL_DOCS=()
for f in "${ROOT}"/main-*.tex; do
    [ -f "${f}" ] || continue
    ALL_DOCS+=("$(basename "${f}" .tex)")
done
if [ "${#ALL_DOCS[@]}" -eq 0 ]; then
    die "no main-*.tex entry points found in ${ROOT}"
fi

if [ "${ALL}" -eq 1 ] || [ "${#DOCS[@]}" -eq 0 ]; then
    DOCS=("${ALL_DOCS[@]}")
fi

if [ "${CLEAN}" -eq 1 ]; then
    case "${OUTDIR}" in
        "${ROOT}"/*) ;;
        *) die "refusing to clean an output directory outside the template: ${OUTDIR}" ;;
    esac
    if [ -d "${OUTDIR}" ]; then
        find "${OUTDIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    fi
fi
mkdir -p "${OUTDIR}"

FAILURES=0
BUILT=0

# xelatex resolves ./fonts, ./figures and \input paths relative to the working
# directory, so every build runs from the template root.
cd "${ROOT}" || exit 1

run_xelatex() {
    local doc="$1"
    xelatex \
        -synctex=1 \
        -shell-escape \
        -interaction=nonstopmode \
        -file-line-error \
        -output-directory="${OUTDIR}" \
        "${doc}.tex" >/dev/null 2>&1
}

for doc in "${DOCS[@]}"; do
    if [ ! -f "${doc}.tex" ]; then
        printf '\033[31m%s.tex not found\033[0m\n' "${doc}"
        FAILURES=$((FAILURES + 1))
        continue
    fi

    printf '\033[36m==> %s.tex\033[0m\n' "${doc}"
    doc_failures=0

    # Pass 1: write .aux/.bcf and the first .toc.
    if ! run_xelatex "${doc}"; then
        printf '    \033[31mpass 1 failed\033[0m\n'
        doc_failures=$((doc_failures + 1))
    fi

    passes=2
    if [ -f "${OUTDIR}/${doc}.bcf" ]; then
        passes=3
        if command -v biber >/dev/null 2>&1; then
            if biber --input-directory="${OUTDIR}" --output-directory="${OUTDIR}" \
                "${doc}" >"${OUTDIR}/${doc}.biber.log" 2>&1; then
                printf '    biber ok\n'
            else
                printf '    \033[31mbiber failed - see %s.biber.log\033[0m\n' "${OUTDIR}/${doc}"
                doc_failures=$((doc_failures + 1))
            fi
        else
            printf '    \033[31mbiber was not found; bibliography will be empty\033[0m\n'
            doc_failures=$((doc_failures + 1))
        fi
    fi

    # Remaining passes: settle TOC, references and the bibliography.
    pass=2
    while [ "${pass}" -le "${passes}" ]; do
        if ! run_xelatex "${doc}"; then
            printf '    \033[31mpass %d failed\033[0m\n' "${pass}"
            doc_failures=$((doc_failures + 1))
        fi
        pass=$((pass + 1))
    done

    LOG="${OUTDIR}/${doc}.log"
    PDF="${OUTDIR}/${doc}.pdf"

    if [ -f "${LOG}" ]; then
        # "ignored error:" marks a TeX error that LaTeX recovered from (for
        # example a longtable page split).  It does not affect the output.
        errors=$(awk '/\.tex:[0-9]+:/ && !/ignored error:/ {n++} END {print n + 0}' "${LOG}")
        boxes=$(awk '/Overfull|Underfull/ {n++} END {print n + 0}' "${LOG}")
        missing=$(awk '/Missing character/ {n++} END {print n + 0}' "${LOG}")

        printf '    %d pass(es), %d error(s), %d box(es), %d missing character(s)\n' \
            "${passes}" "${errors}" "${boxes}" "${missing}"

        if [ "${errors}" -gt 0 ] || [ "${boxes}" -gt 0 ] || [ "${missing}" -gt 0 ]; then
            printf '    \033[31mnot clean - see %s\033[0m\n' "${LOG#"${ROOT}/"}"
            doc_failures=$((doc_failures + 1))
        fi
    else
        printf '    \033[31mno log was produced\033[0m\n'
        doc_failures=$((doc_failures + 1))
    fi

    if [ -f "${PDF}" ]; then
        printf '    \033[32m%s  (%s)\033[0m\n' "${PDF#"${ROOT}/"}" "$(du -h "${PDF}" | cut -f1)"
    else
        printf '    \033[31mno PDF was produced\033[0m\n'
        doc_failures=$((doc_failures + 1))
    fi

    if [ "${doc_failures}" -gt 0 ]; then
        FAILURES=$((FAILURES + 1))
    else
        BUILT=$((BUILT + 1))
    fi
done

echo
if [ "${FAILURES}" -eq 0 ]; then
    printf '\033[32mBuild finished: %d document(s) clean.\033[0m\n' "${BUILT}"
    exit 0
fi
printf '\033[31mBuild finished with %d problem(s).\033[0m\n' "${FAILURES}"
exit 1
