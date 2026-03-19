# Cookie Monster Secret Recipe - Writeup

## 题目信息

* **题目名称**：Cookie Monster Secret Recipe
* **题目类型**：Web Exploitation
* **难度**：Easy
* **比赛**：picoCTF 2025

---

## 题目描述

Cookie Monster 将他的秘密饼干配方隐藏在网站中。
需要通过分析网页，找出隐藏的 flag。

提示：

> Sometimes, the most important information is hidden in plain sight.
> Have you checked all parts of the webpage?

---

## 解题思路

### 1. 初步分析

进入题目页面后，可以看到一个登录界面。

随意输入：

```
user: admin
password: 123
```

返回提示：

```
monster need cookie
```

👉 说明关键点在 **cookie**

---

### 2. 抓包分析（Burp Suite）

使用 Burp Suite：

1. 开启代理，拦截请求
2. 提交登录请求
3. 在 **HTTP Request** 中查看 Header

发现存在Cookie,并且找到秘密菜单：

```
Cookie: secret_recipe=cGljb0NURntjMDBrMWVfbTBuc3Rlcl9sMHZlc19jMDBraWVzX0E2RkEwN0Q4fQ%3D%3D
```

👉 重点关注 Cookie 字段

---

### 3. 识别编码

观察 Cookie 的值，发现：

* 字符串形式类似 `Y29va2ll...`
* 具有典型 Base64 特征（A-Za-z0-9+/=）

👉 判断为 **Base64 编码**

---

### 4. 解码 Cookie

使用 Burp 自带 Decoder 或命令行：

```bash
echo <cookie_value> | base64 -d
```

解码后得到：

```
picoCTF{c00k1e_m0nster_l0ves_c00kies_A6FA07D8}
```

---

## Flag

```
picoCTF{c00k1e_m0nster_l0ves_c00kies_A6FA07D8}
```

---

## 知识点总结

### 🔹 1. Cookie 基础

* Cookie 存储在浏览器端
* 会随 HTTP 请求发送给服务器
* 常用于身份认证 / 状态管理

---

### 🔹 2. Base64 识别技巧

常见特征：

* 只包含：`A-Z a-z 0-9 + / =`
* 末尾可能有 `=` 或 `==`
* 长度通常是 4 的倍数

---

### 🔹 3. Web题常见突破口

本题核心思路：

```
提示 → cookie → 抓包 → 发现编码 → 解码 → flag
```

---

## 经验总结（很重要）

这题属于典型：

> **信息就在眼前，但需要你“看懂”**

Web题要养成习惯：

* 看 **HTML（Elements）**
* 看 **JS（Sources）**
* 看 **请求（Network / Burp）**
* 看 **Cookie / LocalStorage**

---

## 一句话总结