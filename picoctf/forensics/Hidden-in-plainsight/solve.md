# Hidden in Plain Sight - Writeup

## 题目信息

* **题目名称**：Hidden in Plain Sight
* **题目类型**：Forensics（取证）
* **难度**：Easy
* **题目描述**：
  给定一张看似普通的 JPG 图片，题目提示图片内部隐藏了一些数据，需要找出其中隐藏的 flag。

---

# 解题思路

这是一道典型的 **图片隐写 / 文件取证题**。
常见的分析流程是：

1. 查看图片元数据（metadata）
2. 搜索可能隐藏的信息
3. 解码可疑字符串
4. 使用隐写工具提取隐藏内容

---

# 第一步：查看图片元数据

首先使用 `exiftool` 查看图片的元数据：

```bash
exiftool img.jpg
```

在输出信息中发现 **Comment 字段存在异常内容**：

```
comment: c3RLZ2hpZGU6Y0VGNmVuZHZjbVE9
```

这是一串 **Base64 编码的字符串**。

---

# 第二步：Base64 解码

对该字符串进行 Base64 解码：

```bash
echo "c3RLZ2hpZGU6Y0VGNmVuZHZjbVE9" | base64 --decode
```

得到结果：

```
steghide:cEF6endvcmQ=
```

可以看出：

* `steghide` 是一个 **隐写工具**
* 后面的字符串很可能是密码

继续对 `cEF6endvcmQ=` 进行 Base64 解码：

```bash
echo "cEF6endvcmQ=" | base64 --decode
```

得到：

```
pAzzword
```

由此可以推测：

* 隐写工具：**steghide**
* 密码：**pAzzword**

---

# 第三步：使用 steghide 提取隐藏数据

安装 steghide：

```bash
sudo apt install steghide
```

使用提取命令：

```bash
steghide extract -sf img.jpg
```

输入密码：

```
pAzzword
```

终端返回：

```
wrote extracted data to "flag.txt"
```

说明隐藏数据已经成功提取。

---

# 第四步：查看 flag

查看生成的文件：

```bash
cat flag.txt
```

得到 flag：

```
picoCTF{h1dd3n_1n_1m4g3_54e31417}
```

---

# 最终答案

```
picoCTF{h1dd3n_1n_1m4g3_54e31417}
```

---

# 知识点总结

这题主要考察 **图片隐写取证的基本流程**：

### 1️⃣ 查看元数据

常用工具：

```
exiftool
```

---

### 2️⃣ 识别编码

常见编码：

* Base64
* Hex
* URL编码

---

### 3️⃣ 隐写工具

常见工具：

```
steghide
binwalk
zsteg
strings
```

---

# 一句话总结

通过 `exiftool` 发现图片 metadata 中存在 Base64 编码的提示信息，解码得到 **steghide 和密码 pAzzword**，随后使用 `steghide extract` 成功提取隐藏文件 `flag.txt`，最终获得 flag。