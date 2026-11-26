#!/usr/bin/env python3
"""Check that the ZH and EN report sources stay structurally aligned.

Compares the two languages on the things that must match even though the prose
differs:

  * the sequence of section / subsection / subsubsection levels;
  * the order of ``\\label{...}`` keys;
  * the multiset of ``\\cite{...}`` keys;
  * the multiset of ``\\ref{...}`` keys;
  * the counts of figure, table and longtable environments.

Usage:
    python3 scripts/check-parity.py

Exits non-zero and prints the differences when the two sides drift apart.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def render(lang: str) -> str:
    chunks: list[str] = []
    for subdir in ("sections", "tables"):
        directory = ROOT / subdir / lang
        if not directory.is_dir():
            raise SystemExit(f"{directory}: directory not found")
        files = sorted(directory.glob("*.tex"))
        if not files:
            raise SystemExit(f"{directory}: no .tex files found")
        chunks.append("\n".join(path.read_text(encoding="utf-8") for path in files))
    return "\n".join(chunks)


def collect(lang: str) -> dict[str, object]:
    text = render(lang)
    return {
        "levels": re.findall(r"\\(section|subsection|subsubsection)\{", text),
        "labels": re.findall(r"\\label\{([^}]*)\}", text),
        "cites": sorted(re.findall(r"\\cite\{([^}]*)\}", text)),
        "refs": sorted(re.findall(r"\\ref\{([^}]*)\}", text)),
        "figures": len(re.findall(r"\\begin\{figure\}", text)),
        "tables": len(re.findall(r"\\begin\{table\}", text)),
        "longtables": len(re.findall(r"\\begin\{longtable\}", text)),
    }


def main() -> int:
    zh = collect("zh")
    en = collect("en")
    problems: list[str] = []

    if zh["levels"] != en["levels"]:
        problems.append(
            f"heading level sequence differs:\n  zh={zh['levels']}\n  en={en['levels']}"
        )
    if zh["labels"] != en["labels"]:
        problems.append(
            f"label order differs:\n  zh={zh['labels']}\n  en={en['labels']}"
        )
    for key in ("cites", "refs"):
        if zh[key] != en[key]:
            problems.append(f"{key} differ:\n  zh={zh[key]}\n  en={en[key]}")
    for key, name in (("figures", "figure"), ("tables", "table"), ("longtables", "longtable")):
        if zh[key] != en[key]:
            problems.append(f"{name} count differs: zh={zh[key]} en={en[key]}")

    if problems:
        print("Bilingual parity check failed:")
        for problem in problems:
            print(" -", problem)
        return 1

    print(
        "Bilingual parity OK: "
        f"{len(zh['levels'])} headings, {len(zh['labels'])} labels, "
        f"{len(zh['cites'])} citations, {len(zh['refs'])} references, "
        f"{zh['figures']} figure(s), {zh['tables'] + zh['longtables']} table(s)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
