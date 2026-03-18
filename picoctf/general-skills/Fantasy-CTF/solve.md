# Fantasy CTF - Writeup

## 题目类型
General Skills

## 考点
- nc（netcat）远程连接
- 基础交互操作
- CTF 比赛规则认知

## 解题过程

1. 使用 nc 连接远程服务：

   nc verbal-sleep.picoctf.net 49483

2. 按提示不断 Enter 进入剧情

3. 按要求选择选项（a/b/c 任意）

4. 最终在剧情中直接给出 flag：

   picoCTF{m1113n1um_3d1710n_8d7ec7f5}

## 总结

本题为 sanity check 题目，主要作用是：

- 熟悉 CTF 比赛流程
- 学习基本交互方式（nc）
- 强调比赛规则（禁止共享 flag 等）

技术难度极低，属于入门引导题。