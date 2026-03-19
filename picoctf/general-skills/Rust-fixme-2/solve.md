# Rust fixme 2 - Writeup

## 题目信息

* **题目名称**：Rust fixme 2
* **题目类型**：General Skills
* **核心考点**：

  * Rust 所有权与借用
  * 可变借用 `&mut` 的使用
  * 编译报错定位（`E0596`）
  * 运行程序获取 flag

---

## 题目描述

题目给了一个 Rust 工程，`src/main.rs` 中有故意留下的借用与可变性问题。我们需要修复代码，让程序通过编译并输出 flag。

---

## 解题思路

这题的本质是：

1. **先编译，定位报错位置**
2. **理解 `&String` 与 `&mut String` 的区别**
3. **把函数参数和调用处的可变性统一修复**
4. **重新编译运行拿到 flag**

Rust 编译器提示通常很直接，关键是看懂“不可变引用不能做可变操作”这类所有权/借用错误。

---

## 第一步：观察文件

先看项目结构：

```bash
ls
```

关键文件：

* `Cargo.toml`：项目配置与依赖
* `src/main.rs`：主程序

可看到依赖：

```toml
[dependencies]
xor_cryptor = "1.2.3"
```

---

## 第二步：编译定位错误

执行：

```bash
cargo check
```

报错为 `E0596`，核心信息：

* `cannot borrow *borrowed_string as mutable, as it is behind a & reference`

定位到 `src/main.rs` 两处 `push_str` 调用。说明代码尝试修改字符串，但函数参数类型是不可变借用 `&String`。

---

## 第三步：修复代码

原始问题点：

1. `decrypt` 函数参数写成了 `borrowed_string: &String`
2. `main` 里 `party_foul` 不是可变变量
3. 调用时传的是 `&party_foul`，不是 `&mut party_foul`

修复后关键代码如下：

```rust
fn decrypt(encrypted_buffer:Vec<u8>, borrowed_string: &mut String){
    // ...
}

fn main() {
    // ...
    let mut party_foul = String::from("Using memory unsafe languages is a: ");
    decrypt(encrypted_buffer, &mut party_foul);
}
```

---

## 第四步：编译与运行

修复完成后执行：

```bash
cargo check
cargo run
```

程序成功运行并输出解密结果（flag）。

---

## 最终答案

```text
picoCTF{4r3_y0u_h4v1n5_fun_y31?}
```

---

## 这题学到了什么

这题是 Rust 借用机制的入门练习，核心收获：

### 1. `&T` 与 `&mut T` 的区别

* `&T`：只读借用，不能修改
* `&mut T`：可变借用，允许修改

### 2. 可变性要“前后一致”

要在函数里修改字符串，必须同时满足：

* 变量定义为 `mut`
* 参数类型为 `&mut String`
* 调用时传入 `&mut` 引用

### 3. 看懂 `E0596`

遇到“behind a `&` reference”基本就是：你拿的是不可变引用，却在做可变操作。

### 4. Cargo 的标准流程

Rust 题目排错通常按 `cargo check -> 修复 -> cargo run` 走最稳。

---

## 可写进笔记的命令总结

```bash
cat src/main.rs
cargo check
cargo run
```

---

## 一句话总结

这题通过修复 `main.rs` 里的可变借用问题（`&String` 改为 `&mut String`，并在调用侧补齐 `mut` 和 `&mut`），成功编译运行并拿到 flag：

```text
picoCTF{4r3_y0u_h4v1n5_fun_y31?}
```
