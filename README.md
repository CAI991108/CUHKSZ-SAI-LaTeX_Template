<div align="center">

<img src="assets/sai-letterhead.png" alt="香港中文大学（深圳）· 人工智能学院" width="100%">

# SAI 报告 LaTeX 模板

**香港中文大学（深圳）人工智能学院 · 中英双语报告模板**

*中文 / English · XeLaTeX · 可复现构建 · 图 / 表 / 代码 / 引用 / 附录示例*

[![License: MIT](https://img.shields.io/badge/License-MIT-2ea44f?style=flat-square)](LICENSE)
[![Engine: XeLaTeX](https://img.shields.io/badge/engine-XeLaTeX-008080?style=flat-square&logo=latex&logoColor=white)](#-快速开始)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square)](#-快速开始)
[![Fonts](https://img.shields.io/badge/fonts-Noto%20CJK%20%E5%86%85%E7%BD%AE-c2185b?style=flat-square)](fonts/LICENSE.txt)
[![Distribution](https://img.shields.io/badge/distribution-TeX%20Live%20%7C%20MiKTeX-3D6117?style=flat-square)](https://www.tug.org/texlive/)
[![template](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template/actions/workflows/template.yml/badge.svg)](https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template/actions/workflows/template.yml)

**简体中文** · [English](README.en.md)

</div>

---

## 这是什么

一个面向 **SAI 报告**的中英双语 LaTeX 模板。它提供：

- 两个入口：`main-zh.tex`（中文）与 `main-en.tex`（英文），共享同一套
  `styles/sai-report.sty`；
- 一个 `metadata.tex`：题目、副标题、作者、学号、课程、教师、日期、logo、关键词；
- 一个可编译的示例报告：摘要、目录、7 个正文章节、图、表、长表、代码、引用、附录；
- 一套构建工具：环境安装、自动发现入口、biber、日志门禁、双语结构检查；
- 内置 Noto CJK 字体，干净 clone 后离线可复现。

**它不是什么：**

- 不是 AIE3905 的评分细则、评分政策或课程材料；
- 不是学位论文 / thesis class；
- 不是“填完就能交”的成品：示例正文需要替换成你自己的报告。

## 快速开始

### 1 · 拿到模板

课程成员（**源仓库**，模板在子目录里）：

```bash
# 私有仓库，仅课程成员
git clone https://github.com/CAI991108/AIE3905-Criteria.git
cd AIE3905-Criteria/templates/sai-report
```

外部用户（**发布镜像**，v1.0 起）：

```bash
git clone https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template.git
cd CUHKSZ-SAI-LaTeX_Template
```

> 模板的源在 `AIE3905-Criteria/templates/sai-report/`；公开仓库是发布镜像，发布时从源
> 推送（见 [`PROVENANCE.md`](PROVENANCE.md)）。

### 2 · 安装 TeX 发行版

| 平台 | 命令 |
| --- | --- |
| Windows | `winget install --id MiKTeX.MiKTeX` |
| macOS | `brew install --cask mactex-no-gui` |
| Debian / Ubuntu | `sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra texlive-fonts-extra` |
| Fedora | `sudo dnf install texlive-scheme-full` |
| Arch | `sudo pacman -S texlive-most texlive-langchinese` |

### 3 · 安装宏包与 Pygments

Windows：

```powershell
.\scripts\setup-miktex.ps1
# 或者，遇到 PowerShell 执行策略限制时：
.\scripts\setup.cmd
```

macOS / Linux：

```bash
chmod +x scripts/*.sh
./scripts/setup-texlive.sh
```

> 如果发行版已经装好 `xelatex`、`ctex`、`minted`（或 `listings` fallback）、`biblatex`、`biber`，可以跳过这一步。
> 两个脚本都是幂等的，只补缺失项。

### 4 · 编译

```bash
./scripts/build.sh --all          # macOS / Linux
.\scripts\build.ps1 -All          # Windows
```

PDF 输出到 `tmp/main-zh.pdf` 与 `tmp/main-en.pdf`。

- 默认构建全部 `main-*.tex`；`--doc main-en` 只编一份；`--clean` 先清空输出目录；
  `--outdir build` 换输出目录。
- 文档有参考文献时，脚本会在第一遍后自动运行 `biber`，再补两遍 XeLaTeX。
- 日志门禁：`errors`、`Overfull/Underfull`、`Missing character` 三项任一非零，构建
  返回非零。`ignored error:`（longtable 分页的已知重载报错）不计入错误。

VS Code：把 **`templates/sai-report`** 作为工作区打开，默认 recipe 是
`latexmk (xelatex + biber)`，输出到 `tmp/`。如果打开的是仓库根目录，模板自带的
`.vscode/settings.json` 不会自动生效。

## 第一次使用改哪里

| 想改什么 | 改哪里 |
| --- | --- |
| 题目、副标题、作者、学号、课程、教师、日期、logo、关键词 | [`metadata.tex`](metadata.tex)（中英分块） |
| 摘要 | `frontmatter/zh/abstract.tex` / `frontmatter/en/abstract.tex` |
| 正文章节 | `sections/zh/*.tex` / `sections/en/*.tex` |
| 增加或删除章节 | `main-zh.tex` / `main-en.tex` 里的 `\input` 行 |
| 表格 | `tables/zh/*.tex` / `tables/en/*.tex` |
| 代码 | `code/*.py`，在章节里用 `\inputminted` 引入 |
| 图 | `figures/`，用 `\includegraphics` 引入 |
| 参考文献 | [`references.bib`](references.bib) |
| 页面、页眉页脚、字体 | [`styles/sai-report.sty`](styles/sai-report.sty)（高级；多数人不用改） |

第一次使用时，通常只需要改 `metadata.tex` 的字段，再把 `sections/` 里的示例正文替换掉。
**不要**在 `styles/sai-report.sty` 里改题目、作者或课程——它们只属于 `metadata.tex`。

## 目录结构

```
templates/sai-report/                   # 公开镜像里就是仓库根目录
├── main-zh.tex · main-en.tex           # 中英入口：\input 章节、打印参考文献与附录
├── metadata.tex                        # 唯一需要改的元数据文件
├── styles/sai-report.sty               # 共享样式：字体、页面、页眉页脚、标题页、表格/代码辅助
├── frontmatter/{zh,en}/abstract.tex    # 摘要与关键词
├── sections/{zh,en}/                   # 7 个正文章节 + 附录，中英同构
│   ├── 01-introduction.tex
│   ├── 02-related-work.tex
│   ├── 03-method.tex
│   ├── 04-implementation.tex
│   ├── 05-evaluation.tex
│   ├── 06-discussion.tex
│   ├── 07-conclusion.tex
│   └── appendix.tex
├── tables/{zh,en}/                     # formal table + longtable
├── code/example.py                     # 代码示例（minted / listings）
├── figures/                            # 示例图（含可重生成的 TikZ 源）
├── references.bib                      # biblatex / biber
├── docs/xelatex-notes.md               # XeLaTeX 踩坑与验证清单
├── assets/sai-letterhead.png           # 学院抬头 logo
├── fonts/                              # 内置 Noto CJK + OFL 许可全文
├── scripts/
│   ├── setup-miktex.ps1 · setup-texlive.sh    # 装宏包 + Pygments
│   ├── build.ps1 · build.sh                   # 编译 + 日志门禁 + biber
│   └── check-parity.py                        # 中英结构比对
├── .github/                            # 公开镜像 CI（workflows/template.yml）+ dependabot
├── .vscode/settings.json               # LaTeX Workshop recipe
├── CONTRIBUTING.md · NOTICE.md         # 发布检查清单 + 许可说明
├── .gitattributes · .gitignore · LICENSE
└── tmp/                                # 构建产物（已忽略）
```

## 中英双版如何同步

- 两个入口共享 `metadata.tex`、`styles/`、`references.bib`、`figures/` 和 `tables/`；
  语言相关的正文分别在 `sections/zh/` 与 `sections/en/`。
- 两边保持相同的 `section` / `subsection` 顺序、相同的 `\label`、相同的 `\cite`
  与 `\ref`；文字可以不同，结构必须一致。
- 提交前运行：

  ```bash
  python3 scripts/check-parity.py
  ```

  它会比对标题层级、label 顺序、cite/ref 多重集、图/表/长表数量。CI 也会跑。
- 只改一种语言时，另一边至少保留同样的结构；否则 parity 检查会失败。
- 图表编号、章节顺序与引用键在两边必须相同；不要一边加图、另一边忘了加。

## 排版约定

- **图。** 用 `figure` + `\includegraphics` + `\caption` + `\label`，并在 caption 后
  用 `\figsource{...}` 写来源。中文引用写 `图~\ref{...}`，英文写
  `Figure~\ref{...}`。
- **表。** 普通表用 `table` + `\formaltable` + `tabularx`（`Y` 列自动换行）；结果表
  可以用 `booktabs`；跨页表用 `longtable`，用 `\endhead` 重复表头，不要给
  `\endfoot` 只放一个 `\hline`。
- **代码。** 默认用 `minted`，需要 `-shell-escape` 与 Pygments；构建脚本已经传好参数。如果环境不允许 shell-escape（例如部分 Overleaf 套餐），加载样式时加 `plaincode`，改用 `listings`，不需要 Pygments：`\usepackage[cjk,plaincode]{styles/sai-report}`。
  示例见 `code/example.py` 与 `sections/*/04-implementation.tex`。
- **引用。** `biblatex` numeric + `biber`；正文写 `\cite{key}`，入口里已经调用
  `\printbibliography`。
- **附录。** 在 `\appendix` 之后写 `\section{...}`；示例是“补充材料”。
- **页面。** A4，版心 170mm × 241mm，11pt；标题页 + 页眉 logo + 页脚日期/页码/课程。
- **构建产物。** `tmp/` 是临时目录，不要提交；`make clean` 或 `--clean` 会清掉。

## 字体、许可与 logo

| 范围 | 许可 |
| --- | --- |
| 模板、脚本、文档 | **MIT** © 2026 Zijin CAI and contributors，见 [`LICENSE`](LICENSE) |
| Noto Serif SC / Noto Sans SC | **SIL OFL 1.1**，见 [`fonts/LICENSE.txt`](fonts/LICENSE.txt) |
| Latin Modern | TeX 发行版自带，GUST 字体许可 |
| 学院抬头 logo | **不覆盖** MIT；仅用于 SAI 课程/成员文档，见 [`assets/README.md`](assets/README.md) |

字体上游：<https://github.com/notofonts/noto-cjk>。

**替换 logo：** 把 `assets/sai-letterhead.png` 换成自己的抬头图，保持
`metadata.tex` 的 `\SAIReportLogo` 指向它；如果不想用抬头图，设置
`\SAIReportLogo{}`，并用 `\usepackage[nologo]{styles/sai-report}` 加载样式。
公开模板里不要放未授权的合作方 logo、真实学生数据或课程内部政策。

## 课程专用内容放哪

课程评分细则、cohort policy、补评/缺席规则等属于课程仓库，不属于模板。AIE3905 的
LaTeX 课程材料放在源仓库的 `docs/guidance/latex/week7-milestone/`；模板里只保留通用
骨架、示例与工具。不要在 `templates/sai-report/` 里复制课程评分政策。

课程报告要用模板时，有两个做法：

1. 复制整个 `templates/sai-report/` 到自己的目录，再改 `metadata.tex` 与 `sections/`；
2. 在自己的文档里把 `\SAIAssetRoot` 指向模板的 `fonts/` 与 `assets/`，并
   `\usepackage[...]{.../styles/sai-report}`，只维护自己的正文。

## 故障排查

| 现象 | 处理 |
| --- | --- |
| `xelatex was not found` | 安装 TeX Live / MiKTeX，或先跑 setup 脚本 |
| `fontspec` / `ctex` 找不到字体 | 确认 `fonts/` 下四个 OTF 存在；`\SAIAssetRoot` 指向包含 `fonts/` 的目录 |
| `minted` 报 `pygmentize` | 安装 Pygments；`-shell-escape` 已由构建脚本传入 |
| `biber was not found` / 引用为空 | 安装 biber；`build.sh` / `build.ps1` 会自动运行 |
| 日志有 `ignored error:` | longtable 分页的已知重载报错，构建脚本已排除，不算失败 |
| `headheight is too small` | 抬头图高于 18.5mm；改 `styles/sai-report.sty` 的 geometry 或用 `[nologo]` |
| `Overfull` / `Underfull` | 构建会失败；检查窄列、长 URL、不可断词或表格列宽 |
| Windows 不能运行 `.ps1` | 用 `scripts\build.cmd` / `scripts\setup.cmd` |
| Overleaf | 需要 XeLaTeX + 仓库内字体；如果 minted/shell-escape 受限，加载样式时加 `plaincode`（`\usepackage[cjk,plaincode]{styles/sai-report}`），代码块改用 `listings` |

## 发布与版本

- **源**：`AIE3905-Criteria` 仓库的 `templates/sai-report/`。
- **发布镜像**：<https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template>。发布流程：
  在源仓库打 tag，`git subtree split --prefix=templates/sai-report`，推送到镜像仓库，
  再在镜像仓库打同名 tag。见 [`PROVENANCE.md`](PROVENANCE.md) 与
  [`CONTRIBUTING.md`](CONTRIBUTING.md)。
- **版本**：v1.0.x 是通用报告模板的首个系列；之后的模板改动先改源仓库，再发布镜像。
- **发布前检查**：在模板目录运行 `./scripts/check-release.sh`（需要 XeLaTeX）；只想检查已有 PDF 时用 `--skip-build`。
- 公开仓库旧 issue #5–#10（课程细则时代）由源仓库 map #1 接管，发布时逐条关闭并附指针。

## 许可

模板代码与文档使用 MIT；内置字体的许可是独立的 SIL OFL 1.1；学院 logo 不在 MIT 范围内。
完整说明见 [`LICENSE`](LICENSE)、[`fonts/LICENSE.txt`](fonts/LICENSE.txt)、
[`NOTICE.md`](NOTICE.md) 与 [`assets/README.md`](assets/README.md)。

## 相关文档

- [`PROVENANCE.md`](PROVENANCE.md) — 从独立模板仓库迁入的来源与维护关系
- [`NOTICE.md`](NOTICE.md) — 字体、logo 与第三方资源的许可说明
- [`assets/README.md`](assets/README.md) — 抬头图的使用边界与替换方式
- [`docs/xelatex-notes.md`](docs/xelatex-notes.md) — XeLaTeX 踩坑与验证清单
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — 发布前检查清单
