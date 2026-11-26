#!/usr/bin/env bash
#
# Pre-release checks for the SAI report template.
#
# Runs the checks that the build script cannot do on its own:
#   * no course-specific / personal strings in the template sources;
#   * the ZH and EN structures agree;
#   * a clean build (unless --skip-build);
#   * both PDFs exist, are A4, have generic metadata and embedded fonts;
#   * no build output is tracked, and the vendored assets are present.
#
# Usage:
#   ./scripts/check-release.sh               # full check (needs XeLaTeX)
#   ./scripts/check-release.sh --skip-build  # inspect existing tmp/ PDFs
#
# Exits non-zero when any check fails.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}" || exit 1

SKIP_BUILD=0
while [ "$#" -gt 0 ]; do
    case "$1" in
        --skip-build) SKIP_BUILD=1 ;;
        -h|--help)
            awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "${BASH_SOURCE[0]}"
            exit 0
            ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

FAILURES=0
ok()   { printf '    \033[32mok\033[0m    %s\n' "$1"; }
fail() { printf '    \033[31mFAIL\033[0m  %s\n' "$1"; FAILURES=$((FAILURES + 1)); }
warn() { printf '    \033[33mnote\033[0m  %s\n' "$1"; }

FORBIDDEN='AIE3905|S03|S06|Zijin|理工学院|School of Science'

echo '==> Course / author leakage in template sources'
if grep -rniE "${FORBIDDEN}" \
    main-*.tex metadata.tex styles frontmatter sections tables code references.bib; then
    fail 'course-specific or personal text found in the template sources'
else
    ok 'no course-specific or personal text in the template sources'
fi

echo '==> Bilingual parity'
if python3 scripts/check-parity.py; then
    ok 'ZH/EN structure, labels, citations and references agree'
else
    fail 'bilingual parity check failed'
fi

echo '==> Build'
if [ "${SKIP_BUILD}" -eq 0 ]; then
    if ./scripts/build.sh --clean --all; then
        ok 'ZH and EN build cleanly'
    else
        fail 'build failed or the log gate was not clean'
    fi
else
    warn '--skip-build: using the PDFs already in tmp/'
fi

echo '==> PDF metadata, page size and fonts'
for pdf in tmp/main-zh.pdf tmp/main-en.pdf; do
    if [ ! -f "${pdf}" ]; then
        fail "missing ${pdf}"
        continue
    fi
    ok "${pdf} exists"

    if command -v pdfinfo >/dev/null 2>&1; then
        title="$(pdfinfo "${pdf}" 2>/dev/null | awk -F': *' '/^Title:/ {print $2}')"
        author="$(pdfinfo "${pdf}" 2>/dev/null | awk -F': *' '/^Author:/ {print $2}')"
        size="$(pdfinfo "${pdf}" 2>/dev/null | awk -F': *' '/^Page size:/ {print $2}')"
        if [ -z "${title}" ] || [ -z "${author}" ]; then
            fail "${pdf}: Title/Author metadata is empty"
        elif printf '%s %s' "${title}" "${author}" | grep -qiE "${FORBIDDEN}"; then
            fail "${pdf}: metadata still contains course/personal text"
        else
            ok "${pdf}: metadata is generic"
        fi
        if printf '%s' "${size}" | grep -q 'A4'; then
            ok "${pdf}: A4 page size"
        else
            fail "${pdf}: page size is not A4 (${size})"
        fi
    else
        warn 'pdfinfo not found; skipped metadata and page-size checks'
    fi

    if command -v pdffonts >/dev/null 2>&1; then
        if pdffonts "${pdf}" 2>/dev/null | tail -n +3 | awk 'NF >= 5 && $(NF-4) == "no" { found = 1 } END { exit found }'; then
            ok "${pdf}: fonts embedded"
        else
            fail "${pdf}: a font is not embedded"
        fi
    else
        warn 'pdffonts not found; skipped font-embedding check'
    fi
done

echo '==> Tracked build output and assets'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git -C "${ROOT}" ls-files | grep -E '(^|/)tmp/'; then
        fail 'build output under tmp/ is tracked by git'
    else
        ok 'no tracked tmp/ output'
    fi
else
    warn 'not a git worktree; skipped the tracked-output check'
fi

for asset in \
    fonts/NotoSerifSC-Regular.otf \
    fonts/NotoSerifSC-Bold.otf \
    fonts/NotoSansSC-Regular.otf \
    fonts/NotoSansSC-Bold.otf \
    fonts/LICENSE.txt \
    assets/sai-letterhead.png \
    figures/example-figure.pdf \
    references.bib
do
    if [ -f "${asset}" ]; then
        ok "${asset}"
    else
        fail "missing ${asset}"
    fi
done

echo
if [ "${FAILURES}" -eq 0 ]; then
    printf '\033[32mRelease checks passed.\033[0m\n'
    exit 0
fi
printf '\033[31mRelease checks failed: %d problem(s).\033[0m\n' "${FAILURES}"
exit 1
