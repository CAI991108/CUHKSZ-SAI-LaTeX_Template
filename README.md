<div align="center">

<img src="figs/cuhk-sai-logo01.png" alt="香港中文大学（深圳）· 理工学院" width="100%">

# CUHKSZ-SAI LaTeX 模板

**香港中文大学（深圳）人工智能学院 LaTeX 模板**

*中文 / English · XeLaTeX · 一键配置环境*

[![License: MIT](https://img.shields.io/badge/License-MIT-2ea44f?style=flat-square)](LICENSE)
[![Engine: XeLaTeX](https://img.shields.io/badge/engine-XeLaTeX-008080?style=flat-square&logo=latex&logoColor=white)](#-环境依赖)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4?style=flat-square)](#-快速开始)
[![Setup](https://img.shields.io/badge/setup-build.sh-ff6f00?style=flat-square)](#-快速开始)

[![Build](https://img.shields.io/badge/build-passing-3fb950?style=flat-square)](#-编译)
[![Docs](https://img.shields.io/badge/documents-%E4%B8%AD%E8%8B%B1%E5%8F%8C%E8%AF%AD-6e40c9?style=flat-square)](#-文档)
[![Fonts](https://img.shields.io/badge/fonts-Noto%20CJK%20%E5%86%85%E7%BD%AE-c2185b?style=flat-square)](fonts/LICENSE.txt)
[![Distribution](https://img.shields.io/badge/distribution-TeX%20Live%20%7C%20MiKTeX-3D6117?style=flat-square)](https://www.tug.org/texlive/)

**简体中文** · [English](README.en.md)

</div>

---

## 🚀 快速开始

**① 安装 TeX 发行版**

| 平台 | 命令 |
| --- | --- |
| Windows | `winget install --id MiKTeX.MiKTeX` |
| macOS | `brew install --cask mactex-no-gui` |
| Debian / Ubuntu | `sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra texlive-fonts-extra` |
| Fedora | `sudo dnf install texlive-scheme-full` |
| Arch | `sudo pacman -S texlive-most texlive-langchinese` |

**② 安装宏包**

```powershell
git clone https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template.git && cd CUHKSZ-SAI-LaTeX_Template
.\scripts\setup-miktex.ps1        # Windows
```

```bash
git clone https://github.com/CAI991108/CUHKSZ-SAI-LaTeX_Template.git && cd CUHKSZ-SAI-LaTeX_Template
chmod +x scripts/*.sh && ./scripts/setup-texlive.sh    # macOS / Linux
```

**③ 编译**

```powershell
.\scripts\build.ps1 -All          # Windows
```

```bash
./scripts/build.sh --all          # macOS / Linux
```

<div align="center">
<sub>PDF 输出到 <code>tmp/</code> —— <b>无需任何额外配置。</b></sub>
</div>

<details>
<summary><b>配置脚本执行内容</b></summary>

<br>

- 定位 `xelatex`，找不到时给出安装指引并明确报错。
- 安装两份文档需要的 22 个 LaTeX 宏包；先用 `miktex packages info` 探测，
  因为 MiKTeX 会把「重复安装已装包」当作错误。
- 检查 `pygmentize`，缺失时用 `pip` 安装 Pygments。
- 校验内置字体、抬头图与 `fonts/LICENSE.txt` 是否齐全。

两个脚本都是**幂等**的 —— 重复执行只会汇报「已就绪」，不会做任何破坏性操作。

</details>

XeLaTeX 会连跑**两遍**，让 `hyperref` 的书签与页码标签收敛。随后编译脚本从 `.log`
中统计错误数、过满/欠满盒子数与缺字数，不干净时返回非零退出码 ——
所以坏掉的编译结果不可能悄悄蒙混过关。

中文版以 `ctex` 的 `fontset=none` 搭配本项目内置的 Noto CJK **OpenType** 字体；
英文版则用 `fontspec` 与 `unicode-math` 调用 Latin Modern。这些都需要支持 OpenType
的 Unicode 引擎，所以仓库只提供 XeLaTeX 的 recipe。

</details>

---

### VS Code —— 开箱即用

`.vscode/settings.json` 已随仓库提交，recipe 已经配好。

| 操作 | 快捷键 |
| --- | --- |
| 编译 | <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>B</kbd> |
| 查看 PDF | <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>V</kbd> |

- 默认 recipe：**`xelatex x2 (CJK)`** · 输出目录：`tmp/` · SyncTeX 正反向搜索已启用。
- magic comment 被刻意**关闭**，因此 `% !TEX program = xelatex` 只是注释说明，不参与构建。

### 命令行

| Windows | macOS / Linux | 作用 |
| --- | --- | --- |
| `.\scripts\build.ps1` | `./scripts/build.sh` | 编译中文版 |
| `.\scripts\build.ps1 -All` | `./scripts/build.sh --all` | 编译两份 |
| `.\scripts\build.ps1 -Clean` | `./scripts/build.sh --clean` | 先清空 `tmp/` |
| `.\scripts\build.ps1 -Document <名称>` | `./scripts/build.sh <名称>` | 按文件名编译单份 |
| `.\scripts\build.cmd` | — | 同 `build.ps1`，参数一致（见下方说明） |

> 💡 Windows 上 PowerShell 可能以「未数字签名」为由拒绝执行仓库里的 `.ps1`。
> 此时改用 `scripts\setup.cmd` / `scripts\build.cmd`：它们只是以
> `-ExecutionPolicy Bypass` 调用同名脚本，参数完全相同，且不改动系统级策略。

<details>
<summary><b>手动编译</b></summary>

<br>

```powershell
xelatex -synctex=1 -shell-escape -interaction=nonstopmode -file-line-error `
        -output-directory=./tmp AIE3905_Week7_Milestone_Grading_Standard.tex
```

请**连跑两遍**，把 `-output-directory=./tmp` 保持为一个完整参数，并始终在仓库根目录执行 ——
文档以 `./figs/...`、`./fonts/...` 相对路径引用资源。

</details>

---

## 📦 宏包依赖

配置脚本安装的是下面这些发行版包名，而不是 `\usepackage` 的名字。

<details open>
<summary><b>共 22 个宏包</b></summary>

<br>

| `\usepackage` | MiKTeX / TeX Live 包名 | 提供内容 |
| --- | --- | --- |
| —（引擎） | `xetex` | `xelatex.exe` |
| —（引擎） | `l3kernel`、`l3packages` | LaTeX3 编程层 |
| `array`、`tabularx` | `latex-tools`（`tools`） | 标准工具包 |
| — | `latex-fonts`（`fix-cm`） | CM 字体修正 |
| `bookmark` | `bookmark` | PDF 书签驱动 |
| `fontspec` | `fontspec` | OpenType 字体选择 |
| `amsmath` | `amsmath` | 数学排版 |
| `unicode-math` | `unicode-math` | OpenType 数学 |
| `ctex` | `ctex` | 中文支持（`xeCJK`、`zhnumber`） |
| `xltabular` | `xltabular` | 跨页续排的表格（表头自动重复） |
| `needspace` | `needspace` | 分页控制 |
| `geometry` | `geometry` | 页面布局 |
| `minted` | `minted` | 代码块 |
| `xcolor` | `xcolor` | 颜色 |
| `graphicx` | `graphics` | `\includegraphics` |
| `titling` | `titling` | 标题块控制 |
| `enumitem` | `enumitem` | 列表定制 |
| `fancyhdr` | `fancyhdr` | 页眉页脚 |
| `hyperref` | `hyperref` | 超链接与 PDF 元数据 |
| —（字体） | `lm`、`lm-math` | Latin Modern OpenType |

</details>

> MiKTeX 会在编译时按需补齐缺失宏包，所以没跑配置脚本通常也能编过。脚本在于
> **更快、可离线预装、结果可复现**。

---

## 📁 目录结构

```
CUHKSZ-SAI-LaTeX_Template/
├── AIE3905_Week7_Milestone_Grading_Standard.tex      中文版  (CN)
├── AIE3905_Week7_Milestone_Grading_Standard_EN.tex   英文版  (EN)
├── docs/
│   └── xelatex-notes.md                           踩坑与验证清单
├── figs/
│   └── cuhk-sai-logo01.png                           通栏抬头 logo
├── fonts/                                            内置 Noto CJK + OFL 许可全文
├── scripts/
│   ├── setup-miktex.ps1  ·  setup-texlive.sh         装宏包 + Pygments
│   └── build.ps1         ·  build.sh                 编译并汇报结果
├── .vscode/settings.json                             LaTeX Workshop recipe
├── .gitattributes · .gitignore · LICENSE             仓库杂项
└── tmp/                                              构建产物（已忽略）
```

<details>
<summary><b>为什么要把字体内置进仓库？</b></summary>

<br>

为了让每台电脑上的排版结果完全一致 —— 包括没有网络的机器 —— 而不是回退到某台机器
上碰巧装了的某个中文字体。因此是 `fonts/` 会给仓库增加约 40 MB。

</details>

---

## 🎨 常见修改位置

| 想改什么 | 改哪里 | 备注 |
| --- | --- | --- |
| 抬头 logo | `\fancyhead[C]` | 铺满正文宽度 |
| 抬头与标题间距 | `\geometry{...}` 中的 `headsep=8mm` | 调大即可把标题往下推 |
| 抬头高度 | `headheight=18.5mm` | 必须 ≥ logo 高度（16.6 mm），否则 `fancyhdr` 报警告 |
| 中文字体 | `\setCJKmainfont`、`\setCJKsansfont`、`\newCJKfontfamily\zhhei` | 指向 `./fonts/` |
| 西文字体 | `\setmainfont{lmroman10-regular.otf}` | 来自 TeX 发行版自带文件 |
| 字号 | `\documentclass[11pt]{article}` | 每个文件顶部 |

> 💡 中英两份文档一一对应，内容改动通常**两边都要改**。

---

## 📜 许可

| 范围 | 许可 |
| --- | --- |
| 模板、脚本、文档 | **MIT** © 2026 Zijin CAI —— 见 [`LICENSE`](LICENSE) |
| Noto Serif SC / Noto Sans SC | **SIL OFL 1.1** —— 独立许可，MIT 不能覆盖它 —— 见 [`fonts/LICENSE.txt`](fonts/LICENSE.txt) |

字体上游：<https://github.com/notofonts/noto-cjk>

