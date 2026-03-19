# Rust fixme 3 - Writeup

## 题目信息

* **题目名称**：Rust fixme 3
* **题目类型**：General Skills
* **核心考点**：

  * Rust `unsafe` 机制
  * `unsafe fn` 调用规则（`E0133`）
  * 原始指针与切片构造 `std::slice::from_raw_parts`
  * 用安全写法替代不必要的 `unsafe`

---

## 题目描述

题目给了一个 Rust 工程，程序逻辑是解密一段字节并拼接提示文本输出。`src/main.rs` 中有故意留下的 `unsafe` 相关问题，导致无法通过编译。需要修复后运行拿到 flag。

---

## 解题思路

这题本质是：

1. 先用 `cargo check` 定位具体编译错误
2. 看懂报错 `E0133`（调用了 `unsafe fn` 但不在 `unsafe` 块中）
3. 选择修复策略：

   * 要么补 `unsafe {}`
   * 要么改成更 Rust 风格的安全写法（推荐）
4. 重新编译并运行程序获取 flag

---

## 第一步：观察代码

先查看源码：

```bash
cat src/main.rs
```

关键位置在 `decrypt` 函数中，原代码通过：

* `decrypted_buffer.as_ptr()` 取原始指针
* `std::slice::from_raw_parts(...)` 手动构造切片

来进行字符串拼接。

---

## 第二步：编译定位错误

执行：

```bash
cargo check
```

报错核心：

* `error[E0133]: call to unsafe function std::slice::from_raw_parts is unsafe and requires unsafe function or block`

含义是：`from_raw_parts` 本身是 `unsafe fn`，调用它必须显式写在 `unsafe {}` 里。

---

## 第三步：修复代码

### 方案 A（能过编译，但不推荐）

给 `from_raw_parts` 外面包一层：

```rust
let decrypted_slice = unsafe {
    std::slice::from_raw_parts(decrypted_ptr, decrypted_len)
};
```

### 方案 B（推荐，最终采用）

这里完全没必要走裸指针。`decrypted_buffer` 本来就是 `Vec<u8>`，可以直接借用成切片，避免 `unsafe`：

```rust
// Use a safe slice reference instead of raw pointers to avoid unsafe memory operations.
borrowed_string.push_str(&String::from_utf8_lossy(&decrypted_buffer));
```

也就是删掉以下几行：

```rust
let decrypted_ptr = decrypted_buffer.as_ptr();
let decrypted_len = decrypted_buffer.len();
let decrypted_slice = std::slice::from_raw_parts(decrypted_ptr, decrypted_len);
borrowed_string.push_str(&String::from_utf8_lossy(decrypted_slice));
```

改为直接对 `&decrypted_buffer` 调用 `from_utf8_lossy`。

---

## 第四步：编译与运行

修复后执行：

```bash
cargo check
cargo run
```

`cargo check` 通过后，`cargo run` 会输出解密内容与 flag。

---

## 最终答案

```text
picoCTF{n0w_y0uv3_f1x3d_1h3m_4ll}
```

---

## 这题学到了什么

### 1. `unsafe` 不是“可选语法”

调用 `unsafe fn` 时必须显式进入 `unsafe` 块，编译器会强制检查。

### 2. 能不用 `unsafe` 就不用

很多时候可以通过切片引用、标准库安全 API 完成同样逻辑，代码更稳。

### 3. 原始指针操作要非常谨慎

`from_raw_parts` 需要你手动保证指针有效、长度正确、生命周期合法，否则可能产生未定义行为。

### 4. Rust 排错流程很固定

`cargo check -> 定位报错码 -> 最小改动修复 -> cargo run` 是做这类题最稳的路径。

---

## 可写进笔记的命令总结

```bash
cat src/main.rs
cargo check
cargo run
```

---

## 一句话总结

这题通过修复 `E0133`（`unsafe fn` 调用约束），并将不必要的原始指针逻辑改为安全切片写法，成功完成编译并运行拿到 flag。
