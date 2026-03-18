# head-dump - Writeup

## 题目信息

* **题目名称**：head-dump
* **题目类型**：Web Exploitation
* **难度**：Easy
* **作者**：Prince NiyonsHuti N.

---

## 描述

题目提供了一个博客网站，要求我们找到一个隐藏的 API endpoint，该接口可以导出服务器内存（heap dump），并从中提取隐藏的 flag。

---

## 解题思路

本题主要考察：

* Web 信息收集能力
* API 文档识别（Swagger）
* 内存泄露（heapdump）分析

---

### 1. 页面分析

进入网站后，可以看到一个博客页面，其中一篇文章包含如下关键词：

```
#nodejs #swagger UI #API Documentation
```

这些信息表明：

* 后端使用 Node.js
* 存在 Swagger API 文档

因此可以推测网站存在 API 文档入口。

---

### 2. 定位 API 文档

尝试访问常见路径：

```
/swagger
/api-docs
/docs
/swagger-ui
```

成功找到 Swagger UI 页面。

---

### 3. 分析接口

在 Swagger UI 中可以看到多个 API endpoint。

结合题目描述：

> generates files holding the server’s memory

重点关注如下类型接口：

* debug
* dump
* memory

最终发现：

```
/heapdump
```

访问该接口后，下载得到文件：

```
heapdump-xxxxx.heapsnapshot
```

---

### 4. 文件分析

该文件为 Node.js 的内存快照（V8 heap snapshot），特点如下：

* 非纯文本（包含二进制数据）
* 数据量大
* 包含运行时内存中的字符串

尝试常规方法：

```
grep picoCTF heapdump.heapsnapshot
strings heapdump.heapsnapshot
```

结果不理想，原因包括：

* 字符串可能被拆分
* 存在不可见字符
* 数据结构复杂

---

### 5. 使用 less 手动检索

采用更底层的方法进行分析。

打开文件：

```
less heapdump.heapsnapshot
```

搜索关键词：

```
/picoCTF
```

使用：

* `n` 跳转到下一个匹配
* `N` 跳转到上一个匹配

最终在文件中定位到 flag。

---

## 获取 Flag

```
picoCTF{Pat!3nt_15_Th3_K3y_a485f162}
```

---

## 知识点总结

1. Swagger API 泄露

   * 常见路径：`/swagger`、`/api-docs`

2. heapdump 内存泄露

   * Node.js 调试接口暴露
   * 可直接获取运行时敏感信息

3. 大文件分析方法

   * grep：可能失效
   * strings：噪声较多
   * less：最稳定

---

## 总结

本题通过 API 文档暴露了 heapdump 接口，导致服务器内存被直接导出。
通过对内存快照的分析，可以提取出 flag。

该题属于典型的内存泄露问题，在实际环境中具有一定的安全风险。

---