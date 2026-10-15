#!/usr/bin/env bash
#
# Install everything needed to build this template on macOS / Linux with TeX Live.
#
#   * TeX Live (or MacTeX) must already be installed.
#   * Missing LaTeX packages are installed with tlmgr, elevated with sudo when
#     the TeX Live tree is not writable by the current user.
#   * Pygments is installed so that minted code blocks keep working.
#
# The script is idempotent - re-running it only reports what is already in place.
#
# Usage:
#   ./scripts/setup-texlive.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cyan()  { printf '\033[36m==> %s\033[0m\n' "$1"; }
ok()    { printf '    \033[32mok\033[0m    %s\n' "$1"; }
note()  { printf '    \033[33mnote\033[0m  %s\n' "$1"; }
fail()  { printf '    \033[31mFAIL\033[0m  %s\n' "$1"; }

# ---------------------------------------------------------------------------
#  TeX Live package names.  tlmgr resolves dependencies itself, so only the
#  directly \usepackage'd packages (plus the font packages) are listed.
#  tools -> array.sty + tabularx.sty, graphics -> graphicx.sty,
#  lm / lm-math -> the OpenType Latin Modern fonts, ctex -> xeCJK + zhnumber.
# ---------------------------------------------------------------------------
PACKAGES=(
  xetex
  l3kernel
  l3packages
  tools
  fix-cm
  bookmark
  fontspec
  amsmath
  unicode-math
  ctex
  needspace
  geometry
  minted
  xcolor
  graphics
  titling
  enumitem
  fancyhdr
  hyperref
  lm
  lm-math
)

# ---------------------------------------------------------------------------
#  Check that XeLaTeX is present
# ---------------------------------------------------------------------------
cyan 'Locating XeLaTeX'
if ! command -v xelatex >/dev/null 2>&1; then
  fail 'xelatex was not found.'
  echo '    Install TeX Live or MacTeX first, then re-run this script:'
  echo '        macOS      brew install --cask mactex-no-gui'
  echo '        Debian     sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra texlive-fonts-extra'
  echo '        Fedora     sudo dnf install texlive-scheme-full'
  echo '        Arch       sudo pacman -S texlive-most texlive-langchinese'
  exit 1
fi
ok "xelatex : $(command -v xelatex)"

# ---------------------------------------------------------------------------
#  Install the LaTeX packages
# ---------------------------------------------------------------------------
cyan 'Installing LaTeX packages'
if ! command -v tlmgr >/dev/null 2>&1; then
  note 'tlmgr was not found (a distro TeX Live package was probably used).'
  note 'Skipping package installation - use your distro packages if a build fails.'
else
  TLMGR=(tlmgr)
  TEXMFROOT="$(kpsewhich -var-value TEXMFROOT 2>/dev/null || true)"
  if [ -n "${TEXMFROOT}" ] && [ ! -w "${TEXMFROOT}" ]; then
    if command -v sudo >/dev/null 2>&1; then
      TLMGR=(sudo tlmgr)
      note 'TeX Live tree is not writable; tlmgr will run through sudo.'
    else
      note 'TeX Live tree is not writable and sudo is unavailable.'
    fi
  fi

  for pkg in "${PACKAGES[@]}"; do
    if "${TLMGR[@]}" info "$pkg" >/dev/null 2>&1; then
      ok "$pkg (already installed)"
      continue
    fi
    if "${TLMGR[@]}" install "$pkg" >/dev/null 2>&1; then
      ok "$pkg installed"
    else
      fail "$pkg could not be installed"
    fi
  done
fi

# ---------------------------------------------------------------------------
#  Pygments, used by the minted package
# ---------------------------------------------------------------------------
cyan 'Checking Pygments (minted code blocks)'
if command -v pygmentize >/dev/null 2>&1; then
  ok "pygmentize : $(command -v pygmentize)"
elif command -v python3 >/dev/null 2>&1; then
  note 'Installing Pygments with python3 -m pip'
  if python3 -m pip install --user --upgrade Pygments >/dev/null 2>&1; then
    if command -v pygmentize >/dev/null 2>&1; then
      ok "pygmentize : $(command -v pygmentize)"
    else
      note 'Pygments was installed but pygmentize is not on PATH.'
      note 'Add the pip --user bin directory to PATH so XeLaTeX can find it.'
    fi
  else
    fail 'python3 -m pip failed. Install Pygments with your package manager, e.g.'
    echo '        Debian     sudo apt install python3-pygments'
    echo '        Fedora     sudo dnf install python3-pygments'
    echo '        Arch       sudo pacman -S python-pygments'
    echo '        macOS      brew install pygments'
  fi
else
  fail 'Neither pygmentize nor python3 was found.'
  echo '    minted code blocks will fail until Pygments is installed.'
fi

# ---------------------------------------------------------------------------
#  Project assets that cannot be regenerated
# ---------------------------------------------------------------------------
cyan 'Checking vendored assets'
MISSING=0
for asset in \
  fonts/NotoSerifSC-Regular.otf \
  fonts/NotoSerifSC-Bold.otf \
  fonts/NotoSansSC-Regular.otf \
  fonts/NotoSansSC-Bold.otf \
  fonts/LICENSE.txt \
  figs/cuhk-sai-logo01.png
do
  if [ -f "${ROOT}/${asset}" ]; then
    ok "$asset"
  else
    fail "missing: $asset"
    MISSING=$((MISSING + 1))
  fi
done

echo
if [ "${MISSING}" -eq 0 ]; then
  printf '\033[32mSetup finished.  Build the documents with:\033[0m\n'
  echo '    ./scripts/build.sh --all'
  exit 0
fi
printf '\033[31m%d asset(s) are missing - restore them before building.\033[0m\n' "${MISSING}"
exit 1
