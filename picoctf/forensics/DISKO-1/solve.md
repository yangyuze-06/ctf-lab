# DISKO-1 Writeup

## 题目信息

* **题目名称**：DISKO 1
* **题目类型**：Forensics（数字取证）
* **难度**：Easy

题目给出了一个压缩的磁盘镜像文件：

```text
disko-1.dd.gz
```

题目要求在这个磁盘镜像中找到 flag。

---

# 解题思路

这是一个典型的 **磁盘镜像取证题**。
`.dd` 文件是磁盘镜像文件，通常包含完整的磁盘数据，因此可以通过解压、字符串搜索等方式寻找隐藏的 flag。

---

# 第一步：解压文件

题目给出的文件是 `.gz` 压缩格式，因此首先需要解压：

```bash
gunzip disko-1.dd.gz
```

解压后得到：

```text
disko-1.dd
```

这是一个 **磁盘镜像文件**。

---

# 第二步：收集基本信息

首先尝试使用一些常见的取证工具查看文件信息：

```bash
exiftool disko-1.dd
```

但没有得到有价值的信息。

接着使用：

```bash
strings disko-1.dd
```

可以看到镜像中包含大量字符串数据，但信息比较杂乱。

---

# 第三步：搜索 flag

在 CTF 题目中，flag 通常包含特定格式，例如：

```text
picoCTF{...}
```

因此可以直接在字符串输出中搜索 `pico`：

```bash
strings disko-1.dd | grep pico
```

成功得到结果：

```text
picoCTF{1t5_ju5t_4_5tr1n9_be6031da}
```

---

# 最终 Flag

```text
picoCTF{1t5_ju5t_4_5tr1n9_be6031da}
```

---

# 知识点总结

本题主要考察 **磁盘镜像取证的基础操作**。

常见流程：

1. 解压镜像文件
2. 使用工具查看基本信息
3. 使用 `strings` 提取可读字符串
4. 搜索可能的 flag

常用命令：

```bash
gunzip file.gz
strings file
strings file | grep pico
```

对于简单的 Forensics 题，flag 有时会直接以字符串形式存储在镜像中，因此通过 `strings` 搜索即可快速找到。

---

# 一句话总结

该题通过解压 `.dd` 磁盘镜像文件，并使用 `strings` 提取可读字符串，最终通过 `grep` 搜索 `pico` 成功定位到 flag。