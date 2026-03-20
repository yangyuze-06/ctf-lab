# RED - Writeup

## 题目信息

* **题目名称**：RED
* **题目类型**：Forensics（取证）
* **难度**：Easy
* **题目描述**：
  给定一张红色图片 `red.png`，需要分析图片中是否隐藏了信息并找出 flag。

---

# 解题思路

这题是典型的 **PNG 隐写取证题**。  
根据图片和提示方向，优先怀疑 **LSB（最低有效位）隐写**，用取证工具进行自动枚举。

整体流程：

1. 确认文件类型并查看基础元数据
2. 尝试 LSB 隐写检测
3. 提取可疑编码字符串并解码
4. 得到 flag

---

# 第一步：初步检查

题目给的是一张纯红色视觉效果的图片，先确认类型并看元数据：

```bash
exiftool red.png
```

元数据里出现了可疑文本（`Poem` 字段）：

```text
Crimson heart, vibrant and bold,.Hearts flutter at your sight..Evenings glow softly red,.Cherries burst with sweet life..Kisses linger with your warmth..Love deep as merlot..Scarlet leaves falling softly,.Bold in every stroke.
```

这类题里，异常文本通常是提示，结合图片题型，继续往 LSB 方向分析。

---

# 第二步：使用 zsteg 检测 LSB

安装并使用 `zsteg` 对 PNG 进行隐写扫描：

```bash
zsteg -a red.png
```

在输出中发现了一段重复出现的可疑 Base64 字符串：

```text
cGljb0NURntyM2RfMXNfdGgzX3VsdDFtNHQzX2N1cjNfZjByXzU0ZG4zNTVffQ==
```

---

# 第三步：Base64 解码

对提取到的字符串解码：

```bash
echo "cGljb0NURntyM2RfMXNfdGgzX3VsdDFtNHQzX2N1cjNfZjByXzU0ZG4zNTVffQ==" | base64 -d
```

得到：

```text
picoCTF{r3d_1s_th3_ult1m4t3_cur3_f0r_54dn355_}
```

---

# 最终答案

```text
picoCTF{r3d_1s_th3_ult1m4t3_cur3_f0r_54dn355_}
```

---

# 知识点总结

### 1️⃣ PNG 隐写常见方向

* LSB（最低有效位）
* 附加数据（文件尾拼接）
* 通道异常（RGB/Alpha 单独藏数据）

### 2️⃣ 常用工具

```text
exiftool
zsteg
strings
binwalk
```

### 3️⃣ 实战要点

* 图片看起来“过于简单”（如纯色图）时，优先考虑隐写
* 元数据中的异常文本常是提示信息
* 扫描结果中重复编码串要先去重再解码

---

# 一句话总结

先用 `exiftool` 发现可疑提示，再用 `zsteg -a red.png` 进行 LSB 扫描，提取并解码 Base64 字符串，最终得到 flag：`picoCTF{r3d_1s_th3_ult1m4t3_cur3_f0r_54dn355_}`。
