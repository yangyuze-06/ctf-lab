# Flag in Flame - Writeup

## 题目信息

* **题目名称**：Flag in Flame
* **题目类型**：Forensics（数字取证）
* **难度**：Easy

题目给了一个 `logs.txt` 文件，但打开后发现内容是一大段看不懂的字符串，而不是正常的日志。

题目 Hint 提示：

> Use base64 to decode the data and generate the image file.

说明这个日志实际上是 **Base64 编码的数据**。

---

# 解题思路

这题其实是一个 **多层编码题**，整体结构如下：

```
logs.txt
   ↓
Base64
   ↓
PNG 图片
   ↓
Hex 字符串
   ↓
ASCII
   ↓
flag
```

---

# 第一步：Base64 解码日志文件

首先对 `logs.txt` 进行 Base64 解码：

```bash
base64 -d logs.txt > output
```

这一步的作用是将 Base64 编码的数据还原为原始文件。

---

# 第二步：判断文件类型

使用 `file` 命令查看解码后的文件类型：

```bash
file output
```

终端返回：

```
PNG image data, 896 x 1152, 8-bit/color RGB, non-interlaced
```

说明解码后的文件其实是一张 **PNG 图片**。

这是 CTF 中非常常见的一种套路：

```
Base64 → 图片
```

---

# CTF小技巧：如何快速判断 Base64 是图片

经验丰富的选手通常可以通过 **Base64开头特征**判断文件类型。

例如：

| 文件类型 | Base64常见开头    |
| ---- | ------------- |
| PNG  | `iVBORw0KGgo` |
| JPG  | `/9j/`        |
| ZIP  | `UEsDB`       |
| PDF  | `JVBER`       |

看到这些开头，基本可以判断解码后是什么文件。

---

# 第三步：打开图片

将解码后的文件改名为图片或直接打开：

```bash
xdg-open output
```

或者：

```bash
mv output output.png
eog output.png
```

打开图片后，可以看到图片中显示了一串数字：

```
7069636F4354467B666F72656E736963735F616E616C797369735F69735F616D617A696E675F63373564643038657D
```

---

# 第四步：识别编码类型

这串数字具有明显特征：

* 只包含 `0-9` 和 `a-f`
* 长度为偶数

这是 **十六进制编码（Hex）**。

在 CTF 中非常常见的一种结构是：

```
Hex → ASCII
```

---

# 第五步：Hex 解码

使用 `xxd` 进行 Hex 反解：

```bash
echo 7069636F4354467B666F72656E736963735F616E616C797369735F69735F616D617A696E675F63373564643038657D | xxd -r -p
```

得到结果：

```
picoCTF{forensics_analysis_is_amazing_c75dd08e}
```

---

# 最终 Flag

```
picoCTF{forensics_analysis_is_amazing_c75dd08e}
```

---

# 知识点总结

这题涉及的知识点：

### 1. Base64 解码

常用命令：

```bash
base64 -d file
```

---

### 2. 文件类型识别

```bash
file filename
```

---

### 3. Hex 解码

```bash
xxd -r -p
```

---

# 常见 CTF 编码套路

很多取证题都会使用类似的多层结构，例如：

```
Base64 → 图片 → Hex → ASCII → Flag
```

或者：

```
Base64 → ZIP → 文本 → Flag
```

掌握以下工具非常重要：

```
base64
file
strings
xxd
binwalk
exiftool
steghide
```

---

# 一句话总结

题目中的 `logs.txt` 实际上是 **Base64 编码的 PNG 图片**，解码后打开图片得到一串 **Hex 编码字符串**，再通过 Hex 转 ASCII 最终得到 flag。