# Rust fixme 1 - Writeup

## 题目信息

* **题目名称**：Rust fixme 1
* **题目类型**：General Skills
* **核心考点**：

  * Rust 基础语法修复
  * Cargo 依赖管理
  * 编译报错定位
  * 运行程序获取 flag

---

## 题目描述

题目给了一个 Rust 工程，`src/main.rs` 里有几处故意留的语法错误和提示注释。我们需要修复代码，让程序正常编译运行，最后输出 flag。

---

## 解题思路

这题的本质是：

1. **先检查工程结构与依赖**
2. **编译一次，观察报错信息**
3. **根据注释修复 Rust 语法点**
4. **重新运行程序拿到 flag**

Rust 题和 C/Python 不同点在于：编译器报错非常明确，按提示逐个修正通常就能过。

---

## 第一步：观察文件

先看项目结构：

```bash
ls
```

可以看到关键文件：

* `Cargo.toml`：项目配置与依赖
* `Cargo.lock`：锁定依赖版本
* `src/main.rs`：主程序

然后检查依赖是否存在：

```bash
cat Cargo.toml
```

这里可以看到依赖：

```toml
[dependencies]
xor_cryptor = "1.2.3"
```

---

## 第二步：定位需要修复的语法点

`main.rs` 中的注释已经给了提示，主要有 3 个点：

1. 语句结尾要加分号 `;`
2. Rust 里返回应使用 `return;`
3. `println!` 的格式化占位符要写成 `{}` 或 `{:?}`

对应修复后关键代码如下：

```rust
let key = String::from("CSUCKS");

if res.is_err() {
    return;
}

println!(
    "{}",
    String::from_utf8_lossy(&decrypted_buffer)
);
```

---

## 第三步：编译与运行

修复完成后执行：

```bash
cargo check
cargo run
```

运行后程序会输出解密结果，也就是 flag。

---

## 最终答案

```text
picoCTF{4r3_y0u_4_ru$t4c30n_n0w?}
```

---

## 这题学到了什么

这题非常适合 Rust 入门，核心收获：

### 1. Rust 语句结束符

大多数普通语句需要 `;` 结尾。

### 2. Result 错误处理思路

像 `XORCryptor::new(&key)` 这类调用会返回 `Result`，需要判断成功或失败。

### 3. `println!` 格式化输出

打印变量时要使用格式字符串，如 `"{}"`。

### 4. Cargo 是 Rust 工程入口

Rust 项目通常通过 `cargo check / run / build` 进行编译和运行。

---

## 可写进笔记的命令总结

```bash
cat Cargo.toml
cat src/main.rs
cargo check
cargo run
```

---

## 一句话总结

这题通过修复 `main.rs` 中的几个 Rust 基础语法错误（分号、return、println 格式化），成功让程序编译运行，并输出 flag：

```text
picoCTF{4r3_y0u_4_ru$t4c30n_n0w?}
```
