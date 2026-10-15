# CUHKSZ-SAI LaTeX 模板

香港中文大学（深圳）理工学院课程作业 LaTeX 模板（已内置 SAI 抬头 logo 与 AIE3905 评分标准版式），
包含中文与英文两份文档，两者均使用 **XeLaTeX** 编译。

| 文档 | 文件 | 页数 |
| --- | --- | --- |
| 中文版 | [`AIE3905_Week7_Milestone_Grading_Standard.tex`](./AIE3905_Week7_Milestone_Grading_Standard.tex) | 5 |
| 英文版 | [`AIE3905_Week7_Milestone_Grading_Standard_EN.tex`](./AIE3905_Week7_Milestone_Grading_Standard_EN.tex) | 6 |

当前两份文档均可编译到 **0 错误、0 过满/欠满盒子、0 缺字**。

---

## 一、环境依赖

| 组件 | 说明 |
| --- | --- |
| TeX 发行版 | Windows 用 MiKTeX，macOS / Linux 用 TeX Live 2023 或更新 |
| 编译引擎 | **XeLaTeX** —— pdfLaTeX 无法编译这两份文档 |
| Python + Pygments | 仅 `minted` 宏包需要。目前两份文档只在导言区配置了 `minted`，正文没有代码块，所以没有 Pygments 也能编过；仍建议保留，以便日后添加代码块。 |

> **为什么必须用 XeLaTeX？** 中文版以 `ctex` 的 `fontset=none` 搭配本项目内置的
> Noto CJK OpenType 字体，需要支持 OpenType 的 Unicode 引擎；英文版另外使用
> `fontspec` 与 `unicode-math` 调用 Latin Modern。因此本仓库只配置了 XeLaTeX，
> 请勿把 recipe 改成 pdfLaTeX。

---

## 二、换一台新电脑后怎么快速跑起来

1. **安装 TeX 发行版**

   | 平台 | 命令 |
   | --- | --- |
   | Windows | `winget install --id MiKTeX.MiKTeX` |
   | macOS | `brew install --cask mactex-no-gui` |
   | Debian / Ubuntu | `sudo apt install texlive-xetex texlive-lang-chinese texlive-latex-extra texlive-fonts-extra` |
   | Fedora | `sudo dnf install texlive-scheme-full` |
   | Arch | `sudo pacman -S texlive-most texlive-langchinese` |

2. **克隆仓库并一键安装宏包 + Pygments**

   ```powershell
   # Windows
   git clone <仓库地址>
   cd CUHKSZ-SAI-LaTeX_Template
   .\scripts\setup-miktex.ps1
   ```

   ```bash
   # macOS / Linux
   git clone <仓库地址>
   cd CUHKSZ-SAI-LaTeX_Template
   chmod +x scripts/*.sh
   ./scripts/setup-texlive.sh
   ```

   两个脚本都是幂等的：已装好的宏包会被识别并跳过，重复执行不会有副作用。

3. **编译**

   ```powershell
   .\scripts\build.ps1 -All            # Windows：编译两份文档
   ```

   ```bash
   ./scripts/build.sh --all            # macOS / Linux：编译两份文档
   ```

   PDF 输出到 `tmp/`。

**配置脚本做了什么**

- 定位 `xelatex.exe` / `xelatex`，找不到时给出安装指引并明确报错。
- 安装两份文档需要的全部 LaTeX 宏包（见第四节表格）。MiKTeX 脚本会先用
  `miktex packages info` 探测，因为 MiKTeX 把「重复安装已装包」当作错误处理。
- 检查 `pygmentize`，缺失时用 `pip` 安装 Pygments。
- 校验内置字体、logo 与 `fonts/LICENSE.txt` 是否齐全。

---

## 三、编译方式

### VS Code

`.vscode/settings.json` 已纳入版本库，构建 recipe 也配好了。

- 打开任一 `.tex` 文件，按 **Ctrl+Alt+B**，或从命令面板执行
  **LaTeX Workshop: Build LaTeX project**。
- 默认 recipe 为 **`xelatex x2 (CJK)`** —— XeLaTeX 连跑两遍，保证 `hyperref` 的
  书签与页码标签正确。
- 输出目录为 `tmp/`；**Ctrl+Alt+V** 在标签页中打开 PDF，SyncTeX 正反向搜索已启用。

recipe 由 `latex-workshop.latex.recipe.default` 指定。magic comment 被刻意关闭，
因此文件首行的 `% !TEX program = xelatex` 只是注释说明，不参与构建。

### 命令行

| Windows | macOS / Linux | 作用 |
| --- | --- | --- |
| `.\scripts\build.ps1` | `./scripts/build.sh` | 编译中文版 |
| `.\scripts\build.ps1 -All` | `./scripts/build.sh --all` | 编译两份文档 |
| `.\scripts\build.ps1 -Clean` | `./scripts/build.sh --clean` | 先清空 `tmp/` |
| `.\scripts\build.ps1 -Document AIE3905_Week7_Milestone_Grading_Standard_EN` | `./scripts/build.sh AIE3905_Week7_Milestone_Grading_Standard_EN` | 按文件名编译单份文档 |

两个脚本都会连跑两遍 XeLaTeX，然后从 `tmp/<文档名>.log` 中统计错误数、过满/欠满盒子数、
缺字数并汇报；成功时打印生成的 PDF，失败时返回非零退出码。

### 手动编译

```powershell
xelatex -synctex=1 -shell-escape -interaction=nonstopmode -file-line-error `
        -output-directory=./tmp AIE3905_Week7_Milestone_Grading_Standard.tex
```

请**连跑两遍**，并把 `-output-directory=./tmp` 保持为一个完整参数。文档中以
`./figs/...`、`./fonts/...` 相对路径引用资源，所以要始终在仓库根目录下调用 XeLaTeX。

---

## 四、宏包依赖清单

`scripts/setup-miktex.ps1` 与 `scripts/setup-texlive.sh` 安装的就是下表中的包名
（发行版的打包名，不是 `\usepackage` 的名字）。

| `\usepackage` | MiKTeX / TeX Live 包名 | 提供内容 |
| --- | --- | --- |
| —（引擎） | `xetex` | `xelatex.exe` |
| —（引擎） | `l3kernel`、`l3packages` | LaTeX3 编程层 |
| `array`、`tabularx` | `latex-tools`（TeX Live 为 `tools`） | 标准工具包 |
| — | `latex-fonts`（TeX Live 为 `fix-cm`） | CM 字体修正 |
| `bookmark` | `bookmark` | PDF 书签驱动 |
| `fontspec` | `fontspec` | OpenType 字体选择 |
| `amsmath` | `amsmath` | 数学排版 |
| `unicode-math` | `unicode-math` | OpenType 数学 |
| `ctex` | `ctex` | 中文支持（含 `xeCJK`、`zhnumber`） |
| `needspace` | `needspace` | 分页控制 |
| `geometry` | `geometry` | 页面布局 |
| `minted` | `minted` | 代码块（依赖 Pygments） |
| `xcolor` | `xcolor` | 颜色 |
| `graphicx` | `graphics` | `\includegraphics` |
| `titling` | `titling` | 标题块控制 |
| `enumitem` | `enumitem` | 列表定制 |
| `fancyhdr` | `fancyhdr` | 页眉页脚 |
| `hyperref` | `hyperref` | 超链接与 PDF 元数据 |
| —（字体） | `lm`、`lm-math` | Latin Modern OpenType |

MiKTeX 会在编译时自动补齐缺失宏包，所以即使没跑配置脚本通常也能编过；脚本的意义在于
更快、可离线预装、结果可复现。

---

## 五、目录结构

```
CUHKSZ-SAI-LaTeX_Template/
├── .gitattributes                                行尾与二进制文件规则
├── .gitignore                                    忽略构建产物与编辑器垃圾
├── LICENSE                                       MIT 许可全文
├── README.md                                     英文说明
├── README.zh-CN.md                               本文件
├── .vscode/
│   └── settings.json                             LaTeX Workshop recipe（xelatex x2）
├── AIE3905_Week7_Milestone_Grading_Standard.tex      中文版
├── AIE3905_Week7_Milestone_Grading_Standard_EN.tex   英文版
├── figs/
│   └── cuhk-sai-logo01.png                       抬头 logo（`\fancyhead` 使用）
├── fonts/                                        内置 Noto CJK OpenType 字体
│   ├── LICENSE.txt                               SIL Open Font License 1.1 全文
│   ├── NotoSerifSC-Regular.otf
│   ├── NotoSerifSC-Bold.otf
│   ├── NotoSansSC-Regular.otf
│   └── NotoSansSC-Bold.otf
├── scripts/
│   ├── setup-miktex.ps1                          Windows：装宏包 + Pygments
│   ├── setup-texlive.sh                          macOS / Linux：同上，走 tlmgr
│   ├── build.ps1                                 Windows：编译
│   └── build.sh                                  macOS / Linux：编译
└── tmp/                                          构建产物（已被 git 忽略）
```

字体之所以内置而不在构建时下载，是为了让每台机器上的排版结果完全一致，也便于在无网络
环境下编译。

---

## 六、常见修改位置

- **页眉** —— 每个文件导言区的 `\fancyhead[C]` 会用整幅 `figs/cuhk-sai-logo01.png`
  铺满正文宽度。抬头分割线与主标题之间的间距是 `\geometry{...}` 里的 `headsep=8mm`，
  调大即可把标题往下推。`headheight` 必须不小于 logo 高度（当前 logo 16.6 mm、
  配置 18.5 mm），否则 `fancyhdr` 会报警告。
- **中文字体** —— `\setCJKmainfont`（正文）、`\setCJKsansfont`（标题）、
  `\newCJKfontfamily\zhhei`（中文粗体），均指向 `./fonts/`。
- **西文字体** —— `\setmainfont{lmroman10-regular.otf}` 使用 MiKTeX / TeX Live
  自带的 Latin Modern 文件，不来自本仓库。
- **字号** —— 每个文件顶部的 `\documentclass[11pt]{article}`。

请保持中英两份文档同步：英文版逐节对应中文版，内容改动通常两边都要改。

---

## 七、许可

- **模板、脚本与文档** —— MIT 许可，© 2026 Zijin CAI，全文见 [`LICENSE`](./LICENSE)。
- **Noto Serif SC / Noto Sans SC**（`fonts/`）—— SIL Open Font License 1.1，
  是独立于 MIT 的另一套许可，MIT 不能覆盖它。全文见
  [`fonts/LICENSE.txt`](./fonts/LICENSE.txt)。OFL 允许随本仓库一起再分发这 4 个字体
  文件，前提是许可文本随附、且修改版不得使用保留字体名。
  上游：<https://github.com/notofonts/noto-cjk>。
- **香港中文大学（深圳）logo**（`figs/cuhk-sai-logo01.png`）—— 属于校方商标，
  仅为课程材料用途收录，不受 MIT 许可覆盖；MIT 许可也不授予任何再使用该图片的权利。
