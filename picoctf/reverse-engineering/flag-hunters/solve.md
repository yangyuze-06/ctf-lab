# Flag Hunters - Writeup

## 题目信息

* **题目名称**：Flag Hunters
* **题目类型**：Reverse Engineering
* **核心考点**：

  * 源码分析
  * 控制流分析
  * 用户输入注入
  * 简易解释器逻辑

---

## 题目描述

题目给出一段 Python 源码，实现了一个“歌词播放程序”。程序中包含 `flag.txt` 文件，并通过特定逻辑控制歌词的输出流程。需要分析代码逻辑，获取隐藏的 flag。

---

## 解题思路

### 1. 分析 flag 来源

```python
flag = open('flag.txt', 'r').read()
```

flag 直接从文件中读取，并拼接进字符串：

```python
secret_intro = ... + flag + '\n'
song_flag_hunters = secret_intro + ...
```

可以确定：

* flag 已经存在于程序内存中
* 位于 `secret_intro`（即整首歌词最前面）

---

### 2. 分析程序入口

```python
reader(song_flag_hunters, '[VERSE1]')
```

程序从 `[VERSE1]` 开始执行，而不是从开头。

结论：

* 包含 flag 的前言不会被正常输出
* 需要修改执行流程，回到开头

---

### 3. 分析核心函数 reader()

程序将歌词按行拆分：

```python
song_lines = song.splitlines()
```

并通过变量 `lip` 控制当前执行位置（类似程序计数器）。

---

### 4. 理解控制流逻辑

程序支持以下“指令”：

#### （1）REFRAIN

```python
if line == 'REFRAIN':
    song_lines[refrain_return] = 'RETURN ' + str(lip + 1)
    lip = refrain
```

作用：

* 跳转到 `[REFRAIN]`
* 并设置返回位置

---

#### （2）RETURN n

```python
elif re.match(r"RETURN [0-9]+", line):
    lip = int(line.split()[1])
```

作用：

* 跳转到指定行

---

#### （3）CROWD

```python
elif re.match(r"CROWD.*", line):
    crowd = input('Crowd: ')
    song_lines[lip] = 'Crowd: ' + crowd
    lip += 1
```

作用：

* 获取用户输入
* 并将输入写回当前歌词行

---

### 5. 发现关键执行机制

```python
for line in song_lines[lip].split(';'):
```

说明：

* 每一行会按 `;` 分割
* 分割后的内容会被逐个执行

---

### 6. 漏洞分析

关键点在于：

```python
song_lines[lip] = 'Crowd: ' + crowd
```

用户输入会被写入 `song_lines`，并在后续再次执行。

结合：

```python
split(';')
```

可以得出：

* 用户输入中的 `;` 会被解析为多条“指令”
* 存在指令注入

---

### 7. 利用思路

目标是跳回开头（输出包含 flag 的 `secret_intro`）。

构造输入：

```text
aaa;RETURN 0
```

执行过程：

1. 输入被写入：

   ```
   Crowd: aaa;RETURN 0
   ```

2. 程序后续再次执行该行时：

   ```python
   split(';')
   ```

   分解为：

   * `Crowd: aaa`
   * `RETURN 0`

3. 执行：

   ```python
   lip = 0
   ```

4. 程序跳转到第 0 行（开头）

5. 输出 `secret_intro`，从而泄露 flag

---

## 最终结果

在 `Crowd:` 提示处输入：

```text
aaa;RETURN 0
```

即可使程序跳回开头，打印出包含 flag 的内容。

---

## 总结

本题本质是一个简单的“解释器”程序：

* 使用 `lip` 控制执行流程
* 支持 `REFRAIN / RETURN` 跳转机制
* 用户输入会被写回并再次解析

漏洞点在于：

* 用户输入未过滤
* 且通过 `split(';')` 被当作指令执行

最终通过构造 `RETURN 0` 实现控制流劫持，成功获取 flag。

---

## 关键知识点

* flag flow 分析
* 控制流跳转（RETURN）
* 用户输入注入
* 二次解析（split(';')）
* 简易解释器逻辑

---