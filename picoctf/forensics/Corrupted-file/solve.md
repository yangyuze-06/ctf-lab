# Corrupted File - Writeup

## 题目信息

* **题目名称**：Corrupted File
* **题目类型**：Forensics（数字取证）
* **难度**：Easy

题目给了一个损坏的二进制文件，提示这个文件也许并没有真的坏掉，只需要修改几个字节就能恢复正常。

Hints 给出三个关键信息：

1. 查看文件头
2. 文件类型与 **JPEG** 有关
3. 可以使用 `xxd` 或 `hexdump` 检查和编辑字节

因此，这题的核心思路就是：

* 检查文件头（magic bytes）
* 判断是否为 JPEG
* 修复错误的文件头字节
* 还原并打开图片获取 flag

---

# 解题思路

这类题通常是 **文件头损坏修复**。

文件本身虽然无法被正常识别，但如果内部结构大致完整，只是开头几个 magic bytes 被改坏，就可以通过手动修复文件头恢复图片。

---

# 第一步：检查文件内容

先尝试用一些常规工具收集信息：

```bash id="j6x0xa"
file file
strings file
exiftool file
```

结果都没有给出明显有效信息，因此说明文件头可能已经损坏，普通识别方式失效。

---

# 第二步：查看十六进制数据

根据 Hint，使用 `xxd` 或 `hexdump` 查看文件头：

```bash id="l3495v"
xxd file | head
```

得到前几行十六进制内容：

```text id="2a2l1n"
00000000: 5c78 ffe0 0010 4a46 4946 0001 0100 0001
00000010: 0001 0000 ffdb 0043 0008 0606 0706 0508
...
```

其中可以看到：

```text id="i3c9vx"
4a46 4946
```

对应 ASCII 是：

```text id="tr8vtm"
JFIF
```

`JFIF` 是 JPEG 文件常见的标识之一，这说明该文件大概率本来就是一张 JPEG 图片。

---

# 第三步：判断正确的 JPEG 文件头

JPEG 文件最常见的开头（magic bytes）是：

```text id="a40hm7"
FF D8 FF
```

而题目文件实际开头却是：

```text id="2yy32r"
5C 78 FF E0
```

显然前两个字节不对。

其中：

```text id="xldpj7"
5C 78
```

对应 ASCII 是：

```text id="wlpizv"
\x
```

这说明原本的二进制字节可能被错误地转义成了文本形式，因此把 JPEG 正确开头破坏了。

所以这题的关键就是把文件开头修复为正确的 JPEG 头部。

---

# 第四步：导出十六进制并修改

先将文件导出为可编辑的 hex 形式：

```bash id="zlm1jz"
xxd file > file.hex
```

然后使用编辑器打开：

```bash id="c4yjyc"
vim file.hex
```

找到第一行：

```text id="blb2o5"
00000000: 5c78 ffe0 0010 4a46 4946 ...
```

将开头的：

```text id="cbrwne"
5c78
```

修改为：

```text id="2bb483"
ffd8
```

修复后第一行应类似：

```text id="zj8kff"
00000000: ffd8 ffe0 0010 4a46 4946 ...
```

也就是把错误的文件头改回 JPEG 标准头部。

---

# 第五步：还原文件

修改完成后保存退出，然后将 hex 还原回二进制文件：

```bash id="6m8opj"
xxd -r file.hex > fixed.jpg
```

---

# 第六步：验证修复结果

使用 `file` 检查新文件：

```bash id="md69j8"
file fixed.jpg
```

如果修复成功，会看到类似输出：

```text id="55w2xn"
JPEG image data
```

说明文件已经恢复成可识别的 JPEG 图片。

---

# 第七步：打开图片获取 flag

打开图片：

```bash id="rtx0u0"
xdg-open fixed.jpg
```

图片中即可看到最终 flag：

```text id="shf42z"
picoCTF{r3st0r1ng_th3_byt3s_684e09bc}
```

---

# 最终答案

```text id="hj1z4m"
picoCTF{r3st0r1ng_th3_byt3s_684e09bc}
```

---

# 知识点总结

这题主要考察的是 **文件头修复（Magic Bytes Repair）**。

常见文件头如下：

| 文件类型 | Magic Bytes               |
| ---- | ------------------------- |
| JPEG | `FF D8 FF`                |
| PNG  | `89 50 4E 47 0D 0A 1A 0A` |
| GIF  | `47 49 46 38`             |
| ZIP  | `50 4B 03 04`             |
| PDF  | `25 50 44 46`             |

以后遇到“文件损坏”“无法识别类型”“提示修复几个字节”之类的题，优先考虑：

1. 用 `file` 看文件类型
2. 用 `strings` 看明文线索
3. 用 `xxd` / `hexdump` 看文件头
4. 对照常见 magic bytes 手动修复

---

# 一句话总结

题目文件虽然无法正常识别，但通过 `xxd` 查看文件头后发现内部仍保留 `JFIF` 结构，说明原本应是一张 JPEG 图片。进一步对照 JPEG 的标准 magic bytes `FF D8 FF`，将错误的开头字节修复后成功恢复图片，并从图片中获得 flag。