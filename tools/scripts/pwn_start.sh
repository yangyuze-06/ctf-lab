#!/usr/bin/env bash

# pwn_start.sh
# 用法: ./pwn_start.sh <binary>

set -e

if [ $# -ne 1 ]; then
    echo "用法: $0 <binary>"
    exit 1
fi

BIN="$1"

if [ ! -f "$BIN" ]; then
    echo "[!] 文件不存在: $BIN"
    exit 1
fi

echo "=============================="
echo "[1] 基本文件信息"
echo "=============================="
file "$BIN"
echo

echo "=============================="
echo "[2] checksec 保护信息"
echo "=============================="
if command -v checksec >/dev/null 2>&1; then
    checksec --file="$BIN"
elif command -v pwn >/dev/null 2>&1; then
    pwn checksec "$BIN"
else
    echo "[!] 未找到 checksec 或 pwntools(pwn)"
fi
echo

echo "=============================="
echo "[3] 动态链接库"
echo "=============================="
ldd "$BIN" || true
echo

echo "=============================="
echo "[4] 符号表（函数）"
echo "=============================="
# 使用 nm -C 提取全局文本符号，只显示 T 类型函数的相对地址
nm -C "$BIN" 2>/dev/null | awk '
  $2 == "T" {
    symbol = $3
    for (i = 4; i <= NF; i++) {
      symbol = symbol " " $i
    }
    addr = $1
    sub(/^0+/, "", addr)
    if (addr == "") {
      addr = "0"
    }
    printf "%s = 0x%s\n", symbol, addr
  }
'
echo

echo "=============================="
echo "[5] 可疑/关键字符串"
echo "=============================="
strings "$BIN" | grep -Ei 'flag|win|main|system|sh|bin/sh|printf|puts|gets|read|write|malloc|free' || true
echo

echo "=============================="
echo "[6] main 附近反汇编"
echo "=============================="
objdump -d "$BIN" | grep -A 30 '<main>:' || echo "[!] 没找到 main 符号"
echo

echo "=============================="
echo "[7] 程序入口点"
echo "=============================="
readelf -h "$BIN" | grep 'Entry' || true
echo

echo "=============================="
echo "[8] 段信息"
echo "=============================="
readelf -S "$BIN" | head -n 40 || true
echo

echo "=============================="
echo "[9] 建议下一步"
echo "=============================="
echo "1. 看源码: cat *.c"
echo "2. 跑程序: ./$BIN"
echo "3. 进 gdb: gdb ./$BIN"
echo "4. 查函数地址: p main / p win"
echo "5. 如果开了 PIE，关注函数偏移，不要迷信绝对地址"
