# XeLaTeX 双语文档：踩坑与验证清单

> 在 Windows + MiKTeX + XeLaTeX 环境下维护本模板、撰写十页以上中英双语正式文档时踩过的坑，以及一套可复现的验证流程。
>
> 每条都写成「现象 → 原因 → 处理」，可以直接当检查表用。为了让笔记可公开，`§6` 之前的示例一律抽象化，不含任何具体文档内容。
>
> 适用版本：XeLaTeX (TeX Live 2025 / MiKTeX 24+)、`ctex` 2.5+、`xltabular` 0.5+。

---

## 0. 一句话总结

最容易出错的不是 LaTeX 语法，而是三件事：**宏包之间的隐式冲突**、**表格跨页**、**构建门禁的误报**。

---

## 1. 导言区

### 1.1 `titling` 已经定义了 `\theauthor` / `\thedate`

**现象**

```
LaTeX Error: Command \theauthor already defined.
```

改用 `\renewcommand` 之后又变成：

```
LaTeX Error: Command \thedate undefined.
```

**原因** `titling` 提供的宏集合随版本变化，不能假定哪一个已经存在。

**处理** 两个都先 `\providecommand` 再 `\renewcommand`，两种情况都覆盖。

```latex
\providecommand{\theauthor}{}
\renewcommand{\theauthor}{...}
\providecommand{\thedate}{}
\renewcommand{\thedate}{...}
```

### 1.2 `\ctexset{section={format=...}}` 不生效

**现象** 改了 `format`，标题字形没有任何变化，也不报错。

**原因** `ctex` 的标题模块只在 `heading=true` 时加载，否则 `\ctexset{section=...}` 是空操作。

**处理** `\usepackage[UTF8, fontset=none, heading=true]{ctex}`。

### 1.3 少数字符在 CJK 字体里没有

**现象** 日志出现 `Missing character: There is no ... in font ...`，PDF 里对应位置是空白。

**处理**

- `≥`、`≤`、`×` 走数学模式（`$\geq$`、`$\leq$`、`$\times$`），不要直接打字符；
- 勾选框用 `unicode-math` 的 `$\mdlgwhtsquare$`，不要用 U+2610；
- 每次编译后统计日志里 `Missing character` 的条数，非零就逐个查。

### 1.4 PDF 元数据

`\hypersetup{pdftitle=..., pdfauthor=...}`。不设的话阅读器标题栏是空白的，做归档时也不好检索。

---

## 2. 表格

### 2.1 长表跨页用 `xltabular`

`tabularx` 不能跨页；`longtable` 不能自动算列宽；`xltabular` 两者兼得（需要单独安装，MiKTeX / TeX Live 包名都是 `xltabular`）。

```latex
\usepackage{xltabular}
\newcolumntype{Y}{>{\raggedright\arraybackslash}X}

\begin{xltabular}{\textwidth}{|p{3cm}|Y|}
\hline
\textbf{表头} & \textbf{说明} \\ \hline
\endhead          % 换页后自动重复这一段
行 & ... \\ \hline
\end{xltabular}
```

三条注意：

1. **不要放进 `\begin{center}`**——分页计算会出问题；
2. 表头块以 `\endhead` 结束，其后才是表体；
3. **`\endfoot` 里只放一个 `\hline` 会报错**，宁可整块不写 footer。

### 2.2 longtable 分页时报 `ignored error: Infinite glue shrink`

**现象** 表格一旦跨页，日志出现

```
document.tex:123: ignored error: Infinite glue shrinkage found in box being split
```

**原因** 这是 TeX 层 `\vsplit` 的报错，LaTeX 立即恢复，**输出不受任何影响**。试过 `\flushbottom`、`\raggedbottom`、补 `\endlastfoot`、退回纯 `longtable` + `p{}` 列，都不能消除。

**处理** **改门禁，不改表格**——把 `ignored error:` 行从"错误计数"里排除。否则只要文档里有跨页长表，CI 就一直红着，真错误反而被淹没。

```powershell
$errors = ([regex]'\.tex:\d+:(?! ignored error:)').Matches($logText).Count
```

排除之后仍要保证 `Overfull` / `Underfull` / `Missing character` 三项是零——那三项才是真问题。

### 2.3 `\\[3ex]` 撑不高表格行

**现象** 想给手工填写的表格留空白，写 `& & \\[3ex] \hline`，行高完全没变。

**原因** `\\[len]` 紧贴 `\hline` 时，多出来的竖直间距被行规则吃掉了。

**处理** 在单元格里放一根零宽支柱。

```latex
\newcommand{\vstrut}[1]{\rule{0pt}{#1}}
...
D1 & & \vstrut{6ex} \\ \hline
```

### 2.4 中英混排的「等级列」

需求：等级单元格里中文占一行、英文小一号字另起一行，且列宽不抖动。

```latex
\newcommand{\band}[2]{#1\par\vspace{1pt}{\footnotesize #2}}
\newcolumntype{B}{>{\raggedright\arraybackslash}p{3.2cm}}
```

列宽要按**最长的那个英文词**定，不能按中文定——`Unsatisfactory` 比两个汉字宽得多。列宽不够时它会自己折成两行，表格看起来像坏了一样。

### 2.5 `p{}` 与 `X` 混用

定宽列管标签，弹性列管正文：

```latex
\newcolumntype{B}{>{\raggedright\arraybackslash}p{3.2cm}} % 标签
\newcolumntype{N}{>{\centering\arraybackslash}p{1.5cm}}   % 数字
\newcolumntype{Y}{>{\raggedright\arraybackslash}X}        % 正文
```

### 2.6 锁住不该断开的短串

`\mbox{（附录 A）}` 这类要把括号与编号绑在一起，否则会出现「（附录」换行「A）」的断法。同理适用于「第 6.1 节 D1」这种引用。

---

## 3. 分页与留白

### 3.1 `\needspace` 比你想的更爱断页

**现象** 明明还有大半页，却在标题前断页了。

**原因** `\needspace{N\baselineskip}` 比的是**当前页剩余空间**，不是"看起来够不够"。一个 `14\baselineskip` 的守护值在 11pt 正文下就已经是 60mm 以上。

**处理** 先算清目标块的真实高度再定守护值；**能在页面中部正常排下的小表，就别加守护**。

### 3.2 可跨页的表格前面不要加 `\needspace`

表格自己能断，就不需要"整块留够空间"的逻辑；加了只会凭空制造一页空白。

### 3.3 别用肉眼判断「这一页很空」

用 PDF 库量一遍，客观得多：

```python
blocks = [b for b in page.get_text("blocks")
          if b[1] > HEADER_BAND and b[3] < PAGE_H - FOOTER_BAND]
fill = (max(b[3] for b in blocks) - TOP) / (BOTTOM - TOP)
```

把 `fill < 0.85` 的页列出来，只处理真正的异常页。经验值：正文页留白 20% 以内属正常；表单一页（要留手写空间）、文末一页（收尾块）可以单独判断。

**改动后一定要重算一次**——加一个 bullet 就可能引起整篇分页级联，页数从 18 变 19 而你毫无察觉。

---

## 4. Windows 工具链

### 4.1 PowerShell 传参会被吃掉

**现象**

```
xelatex -output-directory=./tmp document.tex
! I can't find file `./tmp'.
```

**原因** `-output-directory=./tmp` 被拆成了两个参数，`./tmp` 变成输入文件名。

**处理** 整个选项加引号，或用数组 splatting：

```powershell
& $xelatex "-output-directory=./tmp" "document.tex"
# 或
$xelatexArgs = @('-synctex=1', '-output-directory=./tmp', 'document.tex')
& $xelatex @xelatexArgs
```

### 4.2 `pwsh` 不一定在 PATH

老环境只有 Windows PowerShell 5.1：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\build.ps1" -All
```

### 4.3 `Set-Content -Encoding UTF8` 会写 BOM

Windows PowerShell 5.1 的 `UTF8` 是带 BOM 的。对 `.tex` 无害（XeLaTeX 会忽略），但对 git diff 和部分 Markdown 渲染器有害——第一条 diff 会变成 `+\ufeff#Requires`，看起来像改了第一行。

**处理** 用无 BOM 的写法：

```powershell
[System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))
```

写完后可以用字节确认：`$bytes[0..2]` 不应是 `0xEF,0xBB,0xBF`。

### 4.4 行尾：仓库统一 LF，但 here-string 是 CRLF

`@' ... '@` 里写进来的是 CRLF。拿它去 `Replace` 一个 LF 文件里的多行片段，会**静默不匹配**——不报错，也不生效。

**处理** 多行替换放进 Python 做，或用 `(?m)` 正则逐行匹配，或先把文件统一换行。改完用字节统计确认没有混排：

```
CRLF=0    bareLF=866   ← 正常（纯 LF）
CRLF=5    bareLF=870   ← 混排，要修
```

### 4.5 Python 脚本名不能和要 import 的包同名

把脚本存成 `pptx.py`，`from pptx import Presentation` 会 import 自己：

```
ImportError: cannot import name 'Presentation' from partially initialized module 'pptx'
```

**处理** 换个文件名（`dump_slides.py`），或者把脚本放到 `sys.path[0]` 之外的目录。

### 4.6 控制台默认是 GBK

`print()` 中文、`•`、`—` 会抛：

```
UnicodeEncodeError: 'gbk' codec can't encode character '\u2022'
```

**处理** 结果写进 UTF-8 文件再用编辑器看，不要依赖控制台输出。

---

## 5. 一套可复现的验证流程

每次改完按这五步走，比肉眼翻 PDF 可靠得多。

### ① 连编两遍

`hyperref` 的书签、页码标签与交叉引用要第二遍才收敛。只编一遍就断言"没问题"是不可靠的。

### ② 三项日志检查

```powershell
$errors   = ([regex]'\.tex:\d+:(?! ignored error:)').Matches($log).Count
$overfull = ([regex]'(Overfull|Underfull)').Matches($log).Count
$missing  = ([regex]'Missing character').Matches($log).Count
```

三项全零才算干净。`Overfull` 最常见的成因是窄列里放了长不可断词。

### ③ 量页面填充率

见 §3.3。只看异常页，不要试图把每一页都填满。

### ④ 渲染一张联系表

整份 PDF 缩略成 5×N 网格存成一张图，一屏就能看出有没有表格爆格、标题孤行、整页空白。

```python
pix = page.get_pixmap(dpi=110)
pix.save(f"page{i:02d}.png")
```

### ⑤ 双语版本一致性比对

同一份文档有中英两版时，**用程序比对结构**，不要靠记忆：

- 抽出 `\section` / `\subsection` 的标题序列，比较**层级序列是否完全一致**、数量是否相等；
- 抽出所有「第 N 节」/「Section N」引用，统计每个编号的出现次数，两边的频次表应当完全相同——不同就说明有一边的引用漏改了。

一个坑：正则扫 `\section` 时要**从 `\begin{document}` 开始**，否则导言区里 `\@startsection{section}{1}` 这样的重定义会被误匹配，导致两边数量对不上、后面全部错位。

---

## 6. 检查清单

改完照着勾一遍：

- [ ] 连编两遍；`errors` / `overfull` / `missing character` 三项为零
- [ ] 日志里没有 `ignored error:` 之外的 `.tex:N:` 行
- [ ] 无 BOM、无 CR/LF 混排
- [ ] 表格没有爆格；窄列里没有长不可断词；等级列宽度够放最长英文词
- [ ] 长表跨页处表头重复，且没有孤立表头压在页脚
- [ ] 填充率异常页（< 70%）逐页确认：是表格整体下移，还是真漏了内容
- [ ] 中文版与英文版结构一致、交叉引用编号一致
- [ ] PDF 元数据（标题、作者）已设置
- [ ] 新增宏包已同时写入两套 setup 脚本与 README 的宏包表
