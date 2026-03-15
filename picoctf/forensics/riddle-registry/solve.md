# Riddle Registry

## 基本信息
- 平台：picoCTF
- 分类：Forensics
- 难度：easy
- 日期：2026年3月15日

## 题面关键信息
- "hidden text"
- "special hidden section"
- 红色字体提示：如果你还在看，那么答案可能在这里......

## 初步判断
这道题可能是隐写题，文本中可能包含隐藏的 flag 或者提示信息。

## 解题过程

### 1. 信息收集
- 使用 `exiftool` 查看 PDF 的元数据：
```bash
exiftool confidential.pdf
````

输出显示 `Author` 字段包含 Base64 编码的字符串。

* 使用 `grep` 筛选出相关信息：

```bash
exiftool confidential.pdf | grep -i "author\|title\|subject\|creator\|producer"
```

我们成功找到了 Base64 编码的字符串。

Author:cGljb0NURntwdXp6bDNkX20zdGFkYXRhX2YwdW5kIV9jYTc2YmJiMn0=

这极有可能就是flag！

### 2. 分析过程

* 使用 `base64` 解码 `Author` 字段中的内容：

```bash
echo "cGljb0NURntwdXp6bDNkX20zdGFkYXRhX2YwdW5kIV9jYTc2YmJiMn0=" | base64 --decode
```

解码结果为：`picoCTF{puzzl3d_m3tadata_f0und!_ca76bbb2}`

### 3. 关键命令

```bash
exiftool confidential.pdf
exiftool confidential.pdf | grep -i "author\|title\|subject\|creator\|producer"
echo "c2YmJiMn0=" | base64 --decode
```

## Flag

```text
picoCTF{puzzl3d_m3tadata_f0und!_ca76bbb2}
```

## 复盘

### 这题考了什么？

* 这题考察了隐写术，如何在文本和 PDF 文件的元数据中找出隐藏的提示。

### 题面最关键的提示是什么？

* "hidden text" 和 "special hidden section" 是解题关键。

### 我一开始为什么没想到？

* 开始时我没有立即想到需要查看 PDF 的元数据。
* 我不太清楚需要哪些工具来进行查询pdf的basicinfo
* 对于base64不太认得

### 哪一步是转折点？

* 使用 `strings` 和 `exiftool` 后，发现了隐藏文本和元数据中的提示信息。

### 下次再遇到类似题，第一步该做什么？

* 如果是隐写题，先查看文件元数据，再用 `strings` 检查文件中的隐蔽信息。

### 可以沉淀到 `notes/` 的通用方法

* 对于 PDF 或文件类型题，优先使用 `pdfinfo` 和 `exiftool` 查看元数据。
* 使用 `strings` 查找文件中的隐蔽信息。

````