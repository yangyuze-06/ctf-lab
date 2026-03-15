# Log Hunt - Writeup

## 题目信息

* **题目名称**：Log Hunt
* **题目类型**：General Skills
* **核心考点**：

  * Linux 基础命令
  * 日志分析
  * `grep` 关键词检索
  * 碎片提取与拼接

---

## 题目描述

题目给了一个日志文件 `server.log`，提示服务器日志中泄露了 secret flag 的一些碎片，这些碎片分散在日志中，并且有些会重复出现。要求我们从日志中恢复出完整的 flag。

---

## 解题思路

这题的本质是：

1. **先观察日志文件**
2. **用关键词搜索可疑内容**
3. **找到 flag 的碎片**
4. **按规律拼接出完整 flag**

日志题一般不会一上来就把完整 flag 明文摆出来，而是会藏在很多行里面，所以最重要的工具就是 `grep`。

---

## 第一步：观察文件

先对日志文件做基础检查：

```bash
file server.log
wc -l server.log
head server.log
tail server.log
```

这些命令的作用分别是：

* `file server.log`：查看文件类型
* `wc -l server.log`：统计日志总行数
* `head server.log`：查看前几行内容
* `tail server.log`：查看后几行内容

这一步的目的是先熟悉日志结构，确认它是普通文本日志，方便后面搜索。

---

## 第二步：尝试搜索 flag 痕迹

因为 picoCTF 的 flag 一般格式是：

```text
picoCTF{...}
```

所以可以先从 flag 的典型内容入手搜索。

在题目中，先搜索到了一部分内容：

```text
picoCTF{us3_}
```

这说明日志里确实存在 flag 碎片，而且不是一次性完整给出，而是分段泄露的。

---

## 第三步：发现规律

继续观察后发现，每个碎片前面似乎都带有相同的标记，比如：

```text
flagpart
```

这说明这些日志行是专门记录 flag 片段的。
所以接下来最直接的办法，就是用 `grep` 把所有带有这个关键词的行全部筛出来。

例如：

```bash
grep "flagpart" server.log
```

这样就能把所有相关碎片提取出来。

---

## 第四步：提取并拼接碎片

从日志中找到的若干 flag 片段为：

```text
picoCTF{us3_
y0urLinux_
sk1lls_
cedfa5fb}
```

把它们按顺序拼接起来，得到完整 flag：

```text
picoCTF{us3_y0urLinux_sk1lls_cedfa5fb}
```

---

## 最终答案

```text
picoCTF{us3_y0urLinux_sk1lls_cedfa5fb}
```

---

## 这题学到了什么

这题虽然简单，但很适合练习日志分析的基本流程：

### 1. 先观察，再搜索

不要一上来就乱翻文件，先用：

```bash
file
wc -l
head
tail
```

了解文件结构。

### 2. `grep` 是日志题核心工具

只要题目和日志、字符串、配置文件有关，第一反应通常都应该是：

```bash
grep "关键词" 文件名
```

### 3. 学会寻找“规律”

这题里不是直接搜到完整 flag，而是先找到一部分，再发现所有片段都有共同标记 `flagpart`，然后批量提取出来。
这就是做 CTF 时很重要的能力：**先找到线索，再总结规律**。

---

## 可写进笔记的命令总结

```bash
file server.log
wc -l server.log
head server.log
tail server.log
grep "flagpart" server.log
```

---

## 一句话总结

这题通过分析 `server.log`，先找到一部分 flag，再发现所有碎片前都有 `flagpart` 标记，最终使用 `grep` 提取所有片段并拼接，得到完整 flag：

```text
picoCTF{us3_y0urLinux_sk1lls_cedfa5fb}
```