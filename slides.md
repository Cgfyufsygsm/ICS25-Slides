---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: bg.jpg
# some information about your slides (markdown enabled)
title: "01-Data-Representation"
highlighter: shiki
info: |
  ICS 2025 Fall Slides
# apply unocss classes to the current slide
presenter: true
class: text-center
# https://sli.dev/features/drawing
titleTemplate: '%s'
drawings:
  persist: false
# slide transition: https://sli.dev/guide/animations.html#slide-transitions
transition: fade-out
# enable MDC Syntax: https://sli.dev/features/mdc
mdc: true
fonts:
  sans: '"", "华文中宋", "宋体"'
  serif: '"Consolas", "华文中宋", "宋体"'
  mono: '"Consolas", "华文中宋", "宋体"'

lineNumbers: true

layout: cover
coverBackgroundUrl: /01-Data-Representation/cover.jpg
---

# 数据表示

Taoyu Yang, EECS, PKU

<style>
  div{
   @apply text-gray-2;
  }
</style>

---
layout: center
class: text-center
---

# 研讨题分享

---
layout: center
class: text-center
---

# 关于 Datalab

<!--
给还没开始做/不知道怎么做的同学解释
再次强调 ddl 和学术诚信问题
-->

---

# 基本概念

basic concepts

**位（bit）**：数据存储的最小单位

**字节（Byte）**：最小的可寻址的存储器单位，1 Byte = 8 bits

### 十六进制{.mt-8.mb-4}

- `0x` 开头
- `0~9，A~F`，不区分大小写
- 一个字节的值域是 $\text{00}_{16}$ ~ $\text{FF}_{16}$

```asm
0xA = 10 = 1010
0xC = 12 = 1100
0xE = 14 = 1110
```

\*需要熟练掌握进制转换{.text-sm}

<!--
下标代表进制
-->

---

# 基本概念

basic concepts

**字长（word size）**：决定虚拟地址空间的最大大小

- 对于一个字长为 $w$ 位的机器而言，虚拟地址的范围为 $0\sim2^{w-1}$， 程序最多访问 $2^w$ 个字节
- 为什么？我们需要计算机去寻址，从而需要用 $w$ 位二进制数去表示地址，所以地址的个数就是 $2^w$，所以程序最多访问 $2^w$ 个字节

### 字节顺序{.mt-8.mb-4}

- 小端序（little endian）：最低有效字节在最前面
- 大端序（big endian）：最高有效字节在最前面

**一定要先想清楚字节是怎么排序的（哪边是小地址哪边是高地址），再去辨析大端/小端序**

**字节是一个整体，不会说字节内部是按照小端序还是大端序排列**

<!--
记忆：小 - 低字节

或许可以画个箱子图
-->

---

# 字节顺序

byte order

同样是表示 `0x12345678`，在不同的机器上，内存中的存储可能是：

- 小端序：（低地址）`0x78 0x56 0x34 0x12`（高地址）
- 大端序：（低地址）`0x12 0x34 0x56 0x78`（高地址）

**看到了吗，字节内部顺序是固定的，和大端序小端序无关！**

> 思考：字符串 `abcdefgh` 在内存中的存储形式是？提示：`a` 的 ASCII 码为 `0x61`。

一定要在脑子里明确知道，所谓内存，就是一系列连续的字节。无论你是现在初学的一维线性模型，还是后面做 lab 时会考虑到的二维模型，首先都要明确哪边是低地址哪边是高地址。

### 应用{.mt-8.mb-4}

- 现今，大多数计算机都采用 **小端序**，x86, RISC-V。
- 网络通讯中，一般采用 **大端序**。注意：IBM, Sun, Oracle。


<!--
提问学生
-->

---

# 布尔运算

boolean operation

<div grid="~ cols-2 gap-12">

<div>

| `~`(not) 非  |   |
|---|---|
| 0 | 1 |
| 1 | 0 |

</div>

<div>


| `&`(and)  与  | 0 | 1 |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 0 | 1 |

</div>

<div>

| `\|`(or) 或  | 0 | 1 |
|---|---|---|
| 0 | 0 | 1 |
| 1 | 1 | 1 |

</div>

<div>

| `^` (xor)  异或  | 0 | 1 |
|---|---|---|
| 0 | 0 | 1 |
| 1 | 1 | 0 |
</div>

</div>

---

# 逻辑运算

logical operation

- 逻辑运算符：`&&`(and，与)、`||`(or，或)、`!`(not，非)
- 逻辑运算符的运算结果只有两种：`true` 和 `false`

注意与**按位**运算区分！

#### 短路特性{.mt-6.mb-2}

- `&&`：前一个表达式为假时，后一个表达式不执行，因为无论后一个表达式是什么，结果都是假
- `||`：前一个表达式为真时，后一个表达式不执行，因为无论后一个表达式是什么，结果都是真

也即：如果对第一个参数求值能确定表达式的结果，那么逻辑运算符不会对第二个参数求值

Q：为什么 `p && *p++` 不会引用空指针？（注意这里是位运算，也有短路特性）

A：因为 `&&` 运算符的短路特性，当 `p` 为空指针时（对应其数字表达为 `0x00000000`，或者说是 `NULL`），`*p` 不会被执行，所以不会出现引用空指针的情况。

---

# 位移

bit shift

- 左移：`<<`，右移：`>>`
- > C++ 中流相关运算符就重载了这俩

#### 逻辑右移 / 算术右移{.mt-6.mb-2.font-bold}

<div grid="~ cols-2 gap-12">

<div>

- 逻辑右移：左边补 0
- 算术右移：左边补 最高位（思考：为什么？）

</div>

<div>

- 逻辑左移 / 算术左移：右边补 0

</div>

</div>

C 语言：有符号数算术右移（但注意没有明确规定，只是大家都这么做）, 无符号数逻辑右移

运算时，需要注意运算符优先级 <span class="text-sm">（如果记不住就全加上括号！）</span>

例如：`1 << 2 + 3 << 4`，记忆方法：回忆大一写计概的时候的 `cout << a + b`

关于移 $k$ 位而 $k$ 很大？参见课本 p41 旁注，注意这个在 C 语言中是 UB。

<!--
-->


---

# 整数编码

integer encoding

<div grid="~ cols-2 gap-12">

<div>


### 无符号数

对向量 $x = [x_{w-1}, x_{w-2}, ..., x_0]$：

$$
\text{B2U}_w(x) = \sum_{i=0}^{w-1}(x_i \times 2^i)
$$

- $\text{B2U}_w$ 表示把二进制编码转化为非负整数
  <br>
  <span class="text-sm">（Binary to Unsigned）</span>  

  该函数是双射，即无符号数编码具有唯一性

- $\text{UMax}_w = 2^w - 1$

</div>

<div>

### 有符号数

对向量 $x = [x_{w-1}, x_{w-2}, ..., x_0]$：

$$
\text{B2T}_w(x) = - x_{w-1} \times 2^{w-1} + \sum_{i=0}^{w-2}(x_i \times 2^i) 
$$

- $\text{B2T}_w$ 表示把二进制编码转化为补码
  <br>
  <span class="text-sm">（Binary to Two's Complement）</span>

- 当最高位为 1，整个数表示为一个负数
- 同样具有唯一性

</div>

</div>


---

# 整数编码

integer encoding


对于有符号数，取值范围是不对称的，典型例子 int：

- $\text{TMax}_{32} = 2147483647$
- $\text{TMin}_{32} = -2147483648$

<span class="text-sm">为什么？ 0：在想我的事？</span>


<!--
提问学生：0 的表示的唯一性
-->

---

# 数据的其他表示

other representations

### 反码

最高位的权重为 $-2^{w-1} + 1$

在此方法下，0 的表示有两种：$\text{000...0}$ 和 $\text{111...1}$

### 原码

最高位是符号位，用来确定剩下的位应该取正权还是负权

$$
\text{B2S}_w(x) = (-1)^{x_{w-1}} \times \sum_{i=0}^{w-2} x_i \times 2^i
$$

经典案例：浮点数（等会会讲）


---

# 有符号数与无符号数之间的转换

conversion between signed and unsigned

强制类型转换保持位值不变，**只改变解释这些位的方式**

<div grid="~ cols-2 gap-12">

<div>

### 补码→无符号数

对满足 $\text{TMin}_w \leq x \leq \text{TMax}_w$ 的 $x$ 来说：

- 若 $\text{TMin}_w \leq x < 0$，则 $\text{T2U}(x) = x + 2^w$
- 若 $0 \leq x \leq \text{TMax}_w$，则   $\text{T2U}(x) = x$

<br>

> 小学奥数：一个叛徒等于两个坏蛋，对于负数，最高位“翻转了阵营”，从补码的代表的 $-2^{w-1}$ 变成了 $+2^{w-1}$

</div>

<div>
  
### 无符号数→补码

对满足 $0 \leq x \leq \text{UMax}_w$ 的 $x$ 来说：

- 若 $x > \text{TMax}_w$，则 $\text{U2T}(x) = x - 2^w$
- 若 $0 \leq x \leq \text{TMax}_w$ 则 $\text{U2T}(x) = x$

<br>

> 当一个无符号数与一个有符号数进行计算时，有符号数在这个表达式中会被当做无符号数（即发生了隐式的强制类型转换）
>  
> **例如** ：`-1 > 0u` 此为无符号的比较

<span class="text-sm">（-1 在计算机中表示为全 1，即 $\text{UMax}_w$，而 0u 表示为全 0 的无符号数）</span>

</div>

</div>

<!--
左边：举几个例子，比如说 -1，可以打开计算器给大家展示
右边：x > TMax_w 实际上意思就是 符号位 被占用了，所以溢出补码表示了
-->

---

# 有符号数与无符号数之间的转换

conversion between signed and unsigned

![T2U&U2T](/01-Data-Representation/T2U&U2T.png)


---

# 扩展和截断

extension and truncation

### 扩展一个数{.mb-2}

- 对于无符号数，高位补 0
- 对于有符号数（补码），高位**补符号位**

当把 short（有符号数，2 字节）强制转换为 unsigned（无符号数，4 字节）时？

**先进行数位扩展，再转换为无符号数**

#### 为什么对于有符号数，高位补符号位？{.mt-6.mb-2}

<div grid="~ cols-2 gap-12">

<div>

Hint：消消乐！

- 若最高位为 0，显然；
- 若最高位为 1，则你补的一堆 1 和原先的 1 等价

</div>

<div>

设现在位数为 $m$，补到 $n$ 位，且 $n > m$，则：

$$
-2^{n-1} + \sum_{i=m-1}^{n-2}2^i = -2^{m-1}
$$

</div>

</div>

---

# 扩展和截断

extension and truncation

### 截断一个数{.mt-6.mb-2}

- 对于无符号数 $x = [x_{w-1}, ..., x_0]$，截断为 $w'$ 位，则 $x' = [x_{w'-1}, ..., x_0]$
  
  即 $x' = x \mod 2^k$

- 补码截断，原理上与无符号数类似，但对于数位的解释方式不同（最高位符号位）

---

# 扩展和截断

extension and truncation

<div grid="~ cols-2 gap-12">
<div>

在采用小端法存储机器上运行下面的代码，输出的结果将会是？

（如无特别说明，`int`，`unsigned` 为 32 位长， `short` 为 16 位长，0~9 的 ASCII 码分别是 `0x30 ~ 0x39`，之后题目同）

```c
#include <stdio.h>

int main() {
    char* s = "2018";
    int* p1 = (int*)s;
    short s1 = (*p1) >> 12;
    unsigned u1 = (unsigned)s1;
    printf("0x%x \n", u1);
}
```

</div>

<div class="text-sm" v-click>

1. `char *` 声明的是一个指针，底层是 C 风格的字符串，以 `\0` 结尾，所以实际存储中，其指向一个 `char` 数组的首字节，该数组在内存中是连续存储的，从低地址到高地址依次为 `0x32`，`0x30`，`0x31`，`0x38`，`0x00`
2. `p1` 强制将 `s` 看做一个 `int` 型指针，由于采用小端法，所以其指向的内存被看做了一个 `int` 型变量，其值为 `0x38313032`
3. 将 `int` 型变量 `0x38313032` 右移 12 位，得到 `0x00038313`，然后截断，得到 `short` 型变量 `s1` 的值 `0x8313`
4. 从短、有符号的 `short` 型变量 `s1` 到长、无符号的 `unsigned` 型变量 `u1`，先<span class="text-sky-5">符号扩展</span>，再看作无符号数，得到 `0xffff8313`

</div>
</div>

<!--
1. `char *` 声明的是一个指针，底层是 C 风格的字符串，以 `\0` 结尾，所以实际存储中，其指向一个 `char` 数组的首字节，该数组在内存中是连续存储的，从低地址到高地址依次为 `0x32`，`0x30`，`0x31`，`0x38`，`0x00`
2. `p1` 强制将 `s` 看做一个 `int` 型指针，由于采用小端法，所以其指向的内存被看做了一个 `int` 型变量，其值为 `0x38313032`
3. 将 `int` 型变量 `0x38313032` 右移 12 位，得到 `0x00038313`，然后截断，得到 `short` 型变量 `s1` 的值 `0x8313`
4. 从短、有符号的 `short` 型变量 `s1` 到长、无符号的 `unsigned` 型变量 `u1`，先<span class="text-sky-5">符号扩展</span>，再看作无符号数，得到 `0xffff8313`
-->


---

# 整数加减法

integer addition and subtraction

### 无符号数加法

由于两个 $w$ 位的无符号数相加，结果的范围是 $[0, 2^{w+1}-2]$，而这需要 $w+1$ 位来表示，所以实际上：

结果表示 $x+y$ 的低 $w$ 位，也即 $x + y \mod 2^w$

- 当 $x + y < 2^w$ 时，结果正确；
- 当 $x + y \geq 2^w$ 时，$x + y$ 的结果需要减去 $2^w$，才会得到实际结果，即 $x + y - 2^w$，这就是 **溢出**

![overflow](/01-Data-Representation/overflow.png){.h-180px}

<!--
指一下图中哪里是溢出
-->

---

# 整数加减法

integer addition and subtraction

### 有符号数加法

由于两个 $w$ 位的有符号数相加，结果的范围是 $[-2^w, 2^{w}-2]$，所以实际上：

- 若 $-2^{w-1} \leq x + y < 2^{w-1}$，结果正确；
- 若 $x + y \geq 2^{w-1}$，结果需要减去 $2^w$，才会得到实际结果，即 $x + y - 2^w$，此时称为 **正溢出/上溢出**
- 若 $x + y < -2^{w-1}$，结果需要加上 $2^w$，才会得到实际结果，即 $x + y + 2^w$，此时称为 **负溢出/下溢出**

![signed_overflow](/01-Data-Representation/signed_overflow.png){.h-200px}


---

# 判断溢出

determine overflow

### 无符号数加法

- $s = x + y$，若 $s < x$ 或 $s < y$ 则溢出

<br>

### 有符号数加法

<div grid="~ cols-2 gap-12">

<div>

- $s = x + y$，若 $x > 0$ 且 $y > 0$ 且 $s \leq 0$，则正溢出；
- 若 $x < 0$ 且 $y < 0$ 且 $s \geq 0$，则负溢出


为什么只有这两种情况？

</div>

<div>

![signed_overflow](/01-Data-Representation/signed_overflow.png){.h-250px}

</div>

</div>
<!--
想要溢出，必须两个加数符号相同且与结果相异
一正一负溢出不了
-->

---

# 判断溢出

determine overflow

关于整数加减法/溢出的一个有趣事实：这里的加法是个 **环**（阿贝尔群）！

无论你怎么改变次序，它总是可以轮换回来~

这是一个做题很方便的技巧！

<div grid="~ cols-2 gap-12">

<div>

#### 证明： `~x + 1 = -x` (`x != TMin`)

证：

$$
\begin{aligned}
\sim x + 1 &= -x \\
\sim x + x &= -1 \\
\end{aligned}
$$


</div>

<div>

#### 证明： $\text{TMax} + 1 = \text{TMin}$

证：想想消消乐

$$
\begin{aligned}
0111...1111 + 1 = 1000...0000
\end{aligned}
$$

</div>

</div>

<!--
为什么排除在下一页说明
-->

---

# 补码的非运算

two's complement negation

对满足 $\text{TMin}_w \leq x \leq \text{TMax}_w$ 的 $x$ 来说：

- 若 $x = \text{TMin}_w$，则 $-x = \text{TMin}_w$
- 否则，$-x = -x$（算术上的）

注：这里式子左边的 $-x$ 是 **算数逆元**

- 对于 $x \neq \text{TMin}_w$ 时，本身 $-x$ 也在表示范围内，结论是平凡的
- 对于 $x = \text{TMin}_w$ 时，$-x$ 不在表示范围内。
  
  但是，两个 $\text{TMin}_w$ 相加，溢出到了上一位，结果是 0，所以此时我们说 $\text{TMin}_w$ 的算数逆元就是它自身

回忆：刚才说的 `~x + 1 = -x`


---

# 乘除法

multiplication and division

### 无符号数乘法

等于乘法计算得到的结果（一个 $2w$ 位长的数），而后截断到 $w$ 位

### 补码乘法{.mt-6.mb-2}

等于有符号数乘法后得到的结果（一个 $2w$ 位长的数），无符号截断到 $w$ 位，而后将最高位转化为符号位

**核心：粗暴的位级表示截断**

### 乘以二的幂次{.mt-6.mb-2}

此时，**相当于左移**



---

# 乘除法

multiplication and division

特别注意：除法这里以二的幂次作为除数，也只有此时可以采用右移来取巧。

### 无符号数除法

无符号数 $u$ 除以 $2^k$：将 $u$ **逻辑右移** $k$ 位

（此时恰好就是舍入到 0 的）

### 有符号数除法{.mt-6.mb-1}

直接右移 `x >> k` 得到的是 **向下舍入** 的结果，而不是正常来讲的向 0 取整。

例如：`-3 / 2 = -1`，而 `-3 >> 1 = -2`

向 0 取整：`(x < 0) ? (x + (1 << k) - 1 : x) >> k`

证明见书 P73 ~~助教之前写权值线段树的时候就遇到过此类问题，使用向下舍入就没问题但向 0 舍入就寄了~~

<!--
为什么是向下舍入？因为后面都是正权！

为什么下面加偏置就对？对于恰好整除不用管，否则只要有一个 1 就会向上取 1。
-->


---

# 浮点数表示

floating point

### IEEE 754 标准

本质是对实数的近似

<div grid="~ cols-2 gap-12">

<div>

- 符号位：1 位
- 指数位：$e$ 位
- 尾数位：$m$ 位

实际表示：

- 单精度浮点数（`float`）: $e = 8, {~} m = 23$
- 双精度浮点数（`double`）: $e = 11, {~} m = 52$

各个位长多少要牢牢记清楚！考试会考！

<span class="text-sm">注意，0 的表示有两种，+0 和 -0</span>

</div>

<div>

![IEEE 754](/01-Data-Representation/IEEE.png)

</div>

</div>


---

# 理解 IEEE 754

underlying IEEE 754

<div grid="~ cols-2 gap-12">

<div>

### 规格化值

$$
V = (-1)^s \times (1.M) \times 2^E
$$

- $s$ 为符号位，$M$ 为尾数，$E$ 为阶码
- $E = [e] - Bias$，其中 $[e]$ 为阶码处这 $e$ 位的实际值，$Bias = 2^{e-1} - 1$
- 尾数隐含的 1，可以获得 1 位额外精度

</div>

<div>

### 非规格化值

$$
V = (-1)^s \times (0.M) \times 2^E
$$

- $E = 1 - Bias$，虽然此时 $[e] = 0$，但如此规定可以实现规格化值和非规格化值的平滑过渡
- 尾数没有隐含的 1

</div>

</div>

---

# 理解 IEEE 754

underlying IEEE 754

<div grid="~ cols-2 gap-12">

<div>

### 无穷（$\pm \infty$）

- 符号位 $s$ 区分正无穷/负无穷
- 阶码 $[e] = 1...1$（全1），尾数 $M = 0$
- 表示无穷大，在计算中可以用于表示溢出或未定义的结果

</div>

<div>

### 非数值 (NaN，Not a Number)

- 符号位 $s$ 任意，阶码 $[e] = 1...1$（全1），尾数 $M \ne 0$
- NaN 用于表示未定义或无法表示的值，例如 $0/0$ 或 $\sqrt{-1}$
- 通常在比较中被认为不等于任何值，包括自身{.text-sky-5}

</div>


<div>

### 零

- 符号位 $s$ 任意，阶码 $[e] = 0...0$（全0），尾数 $M = 0$
- 两种表达方式，+0 和 -0

</div>

<div>

### 特殊值的应用

- 处理异常情况：如除零错误、溢出、下溢等
- 提高计算的鲁棒性，避免程序崩溃
- 在数值算法中用于标记和处理特殊情况

</div>

</div>

<!-- <div grid="~ cols-2 gap-12">

<div>

### 特殊值



</div>

<div>

</div>

</div> -->

---

# 理解 IEEE 754

underlying IEEE 754

### 平滑过渡

考虑某一进制，$e=2$，$m=3$（考试的时候可能就会考改变进制的题哦！）


<div grid="~ cols-2 gap-12">

<div>


```
0 01 000

0 00 111
```

</div>

<div>

$$
Bias = 2^{e-1} - 1 = 2^{2-1} - 1 = 1
$$

$$
1.000_2 \times 2^{01_2 - 1} = 1.000_2
$$

$$
0.111_2 \times 2^{1 - 1} = 0.111_2
$$

</div>

</div>

---

# 浮点舍入

rounding

由于浮点数是对实数的近似，浮点数可以精确表示的实数是有限的，所以舍入是不可避免的。

### 实数舍入到浮点数

- 向偶数舍入（round-to-even）（round-to-nearest）
- 类比“四舍六入五成双”，避免统计偏差

$$
1.234 \Rightarrow 1.0 \\
1.678 \Rightarrow 2.0 \\
1.500 \Rightarrow 2.0
$$

\* 实际上，这一过程发生在浮点数精度最末位

### 浮点数转整型{.mt-6}

- 如果舍入，向零舍入
- 如果溢出，C 语言未规定（undefined behavior），各自处理（Intel：$T_{\text{min}}^w$，即舍入到限定最接近的数）

---

# 浮点舍入

rounding

给定一个实数，会因为该实数表示成单精度浮点数 `float` 而发生误差。不考虑 `NaN` 和 `Inf` 的情况，该绝对误差的最大值为？

<div class="text-sm" v-click>

1. 显然阶码位要尽可能的大，才会让误差变大，由于不考虑 `Inf`，所以最大时，阶码位为 `11111110`，即 $2^{8} - 2$，于是<br> $E = [e] - Bias = (2^8 - 2) - (2^7 - 1) = 2^7 - 1 = 127$
2. 尾数位的最大误差发生在舍入时，尾数的 23 位的最后 1 位是上取了还是下取了，最大误差为 $2^{-23} · \frac{1}{2} = 2^{-24}$
3. 于是最大误差为 $2^{127} \times 2^{-24} = 2^{103}$

也即，原数的精确表示实际上是：

$$
\pm 2^{127} \times (1.\underbrace{111...\blue{1}}_{24 个 1})_2
$$

其被舍入到了

$$
\pm 2^{127} \times (1.\underbrace{111...1}_{23 个 1})_2
$$

</div>

---

# 浮点运算

floating point arithmetic

- 加法可交换 `x + y = y + x`，加法不可结合 `(x + y) + z != x + (y + z)`，`NaN`没有加法逆元
- 浮点加法单调性，如果 $a \ge b$，那么对于任何 $a$，$b$ 以及 $x$ 的值，除了 `NaN` 都有 $x + a \ge x + b$
- 乘法可交换 `x * y = y * x`，乘法不可结合 `(x * y) * z != x * (y * z)`
- 乘法在加法上不可分配 `(x + y) * z != x * z + y * z`
- 小心特殊值：`+inf`，`-inf`，`NaN`
  - `NaN != NaN` 为真，其他涉及 `Nan` 的比较表达式都为假。
  - `-inf == -inf < R < +inf == +inf`

<span class="text-sm text-gray-500">* 这些东西说了没用，得你自己做题踩坑才会知道。</span>

<!--
加法/乘法会损失精度，所以顺序会影响。
-->

---

# IEEE 754 异常

exception

- Invalid operation：零乘无穷、零除零、无穷除无穷、无穷绝对值相减......
- Division by zero：有穷数除零结果为无穷
- Overflow：无穷
- Underflow：舍入结果
- Inexact：舍入结果

更多详情请见 [IEEE754](https://en.wikipedia.org/wiki/IEEE_754) 异常处理

---

# 练习：字节顺序

Exercises

1. 在 x86-64 机器上运行如下代码，输出是？
2. 如果把 B 的初始值改为 `0x34566666`，输出是？

```c
int main() {
  unsigned int A = 0x11112222;
  unsigned int B = 0x33336666;
  void *x = (void *)&A;
  void *y = 2 + (void *)&B;
  unsigned short P = *(unsigned short *)x;
  unsigned short Q = *(unsigned short *)y;
  printf("0x%04x", P + Q);
  return 0;
}
```

<div v-click>

考虑 A 和 B 在内存中的存储，从低地址到高地址，A 为 `22 22 11 11`，B 为 `66 66 33 33`。P 显然为 `22 22`，Q 为 `33 33`，所以结果为 `0x5555`。

改初值之后，B 为 `66 66 56 34`，`22 22` + `56 34` = `78 56`，所以结果为 `0x5678`（注意小端法哦）

</div>

<!--
考虑 A 和 B 在内存中的存储，从低地址到高地址，A 为 `22 22 11 11`，B 为 `66 66 33 33`。P 显然为 `22 22`，Q 为 `33 33`，所以结果为 `0x5555`。

改初值之后，B 为 `66 66 56 34`，`22 22` + `56 34` = `78 56`，所以结果为 `0x5678`（注意小端法哦）
-->

---

# 练习：字节顺序

Exercises

在 x86-64 机器上运行如下代码，输出是？（提示：`0` 的 ASCII 码为 `0x30`）

```c
int main() {
  char A[12] = "11224455"
  char B[12] = "11445577"
  void *x = (void *)&A;
  void *y = 2 + (void *)&B;
  unsigned short P = *(unsigned short *)x;
  unsigned short Q = *(unsigned short *)y;
  printf("0x%04x", Q - P);
  return 0;
}
```

<div v-click>

注意字符串在内存中的存储形式。P 为 `31 31`，Q 为 `34 34`，Q - P 得到 `03 03`，所以输出 `0x0303`。

</div>

<!--
注意字符串在内存中的存储形式。P 为 `31 31`，Q 为 `34 34`，Q - P 得到 `03 03`，所以输出 `0x0303`。
-->


---

# 整型/类型提升

Integral/Type Promotion 

<br>

我猜你答不对下面这个程序的输出：

```c
#include <stdio.h>

int main() {
  unsigned char uc = 128;
  char c = 128;
  printf("%d %d\n", uc == c, uc + c)
}
```
---

# 整型/类型提升

Integral/Type Promotion

规则 #1：对于 `char`, `unsigned char`, `short` 这样范围小于 `int` 的类型，在做任何运算之前，都会被隐式扩展成 `int` 类型

> `unsigned char` 是怎么扩展到 `int` 的？

<br>

<div grid="~ cols-2 gap-12">
<div>

```c
#include <stdio.h>

int main() {
  unsigned char uc = 128;
  char c = 128;
  printf("%d %d\n", uc == c, uc + c)
}
```

</div>

<div class="text-sm" v-click>

1. `uc` 的初始值为 128，二进制表示为 `1000 0000`，`c` 的初始值为 -128，二进制表示为 `1000 0000`。
2. 二者进行运算时，都被扩展到 `int`。`uc` 做无符号数的零扩展然后改变解释方式，变为 `... 1000 0000`，值仍为 128。
3. `c` 做有符号数扩展，前面补 1，变为 `1111 ... 1000 0000`，值为 -128。
4. 所以输出为 `0 0`。

</div>
</div> 

<!--
1. `uc` 的初始值为 128，二进制表示为 `1000 0000`，`c` 的初始值为 -128，二进制表示为 `1000 0000`。
2. 二者进行运算时，都被扩展到 `int`。`uc` 做无符号数的零扩展然后改变解释方式，变为 `... 1000 0000`，值仍为 128。
3. `c` 做有符号数扩展，前面补 1，变为 `1111 ... 1000 0000`，值为 -128。
4. 所以输出为 `0 0`。
-->

---

# 整型/类型提升

Integral/Type Promotion

- 规则 #2：int 及以上，存在一系列按等级排列的类型。当表达式中数“是否有符号”相同，但等级不同时，统一扩展到存在的最高等级类型
  - 类型等级为：`int` < `long` < `long long`
  - 因为 C 标准中规定了 `sizeof(int) <= sizeof(long) <= sizeof(long long)`
- 规则 #3：无符号类型与相应有符号类型处于同一等级。表达式中无符号数的等级更高，或二者相同时，有符号类型统一转换到无符号
  - 例如：
    - `int` 和 `unsigned`：统一转换为 `unsigned`
    - `int` 和 `unsigned long`：统一转换为 `unsigned long`
    - `-1 < sizeof(int)` 为假：为什么？参考：https://en.cppreference.com/w/c/types/size_t.html

<!--
sizeof(int) 类型为 size_t，通常为 unsigned long 或 unsigned long long 但必须能表示对象的最大大小。
但总之不会低于 int

-->

---

# 整型/类型提升

Integral/Type Promotion

规则 #4：表达式中无符号数的等级更低时，如果有符号数的类型无法完全覆盖无符号数，则将它们转换为有符号数的类型对应的无符号数

例如：在 32 位的机器上，`sizeof(int) == sizeof(long) == 4`
- 比较 `1u` 和 `-1l` 时
- 因为 `unsigned` 的等级低于 `long`，但 `long` 不能覆盖 `unsigned` 的范围（重要）
- 所以都会把他们转化为 `unsigned long` 比较。
- 所以需要比较的是 `1ul`(1) 和 `-1ul`(4294967295)

---

# 整型/类型提升

Integral/Type Promotion

<div grid="~ cols-2 gap-12">
<div>

让我来看看你真的学懂了没有

请分别回答以下程序在 32 位和 64 位机器上的输出是什么

```c
#include <stdio.h>

int main() {
  unsigned short us = 1;
  printf(
    "%d %d\n",
    1u + 1l > -1l,
    2147483646 + us > -2147483647 - 1
  );
}
```

</div>

<div class="text-sm">
<div v-click>

#### **32 位**

应该还是比较简单的

- `1ul`(1) 和 `-1ul`(4294967295) 相加得到 `0ul`，小于 `-1ul`。
- `int` 能完整表示 `short`，所以 `1us` 直接被扩展到 `1`
- 所以 lhs 为 2147483647，正好是 `INT_MAX`，rhs 正好是 -2147483648，正好是 `INT_MIN`。

</div> 

<div v-click>

<br>

#### **64 位**

- 此时，`long` 是 64 位的，表示范围能覆盖 `unsigned`，所以第一个表达式统一扩展到 `long`，`1u + 1l` 结果为 `2l`。
- 后者不变

</div>
</div>
</div>

<!--
**32 位**

应该还是比较简单的

- `1ul`(1) 和 `-1ul`(4294967295) 相加得到 `0ul`，小于 `-1ul`。
- `int` 能完整表示 `short`，所以 `1us` 直接被扩展到 `1`
- 所以 lhs 为 2147483647，正好是 `INT_MAX`，rhs 正好是 -2147483648，正好是 `INT_MIN`。

**64 位**

- 此时，`long` 是 64 位的，表示范围能覆盖 `unsigned`，所以第一个表达式统一扩展到 `long`，`1u + 1l` 结果为 `2l`。
- 后者不变
-->

---

# 练习：类型转换

Exercises

在 x86-64 机器上，对任意的整型 x 和 y 值，ux 和 uy 分别为其转化成无符号数的值，则下面的 C 语言表达式中，等价的是（不成立的给出反例）

<style>
table {
  line-height: 1.3;
  font-size: 1rem;
}
table th, table td {
  padding: 6px 8px !important;
  vertical-align: middle;
}
</style>

| 命题 1                     | 命题 2                         | 等价？ | 原因/反例 |
| -------------------------- | ------------------------------ | ------ | --------- |
| `x > y`                    | `ux > uy`                      |    <div v-click> False </div>   |     <div v-click> `x = 0, y = -1` </div>      |
| `(x > 0) \|\| (x < ux)`      | `1`                            |   <div v-click> False </div>     |     <div v-click> `x <= 0` </div>      |
| `x ^ y ^ x ^ y ^ x`        | `x`                            |    <div v-click> True </div>    |     <div v-click> 异或的性质 </div>      |
| `((x >> 1) << 1) <= x`     | `1`                            |    <div v-click> True </div>    |     <div v-click> 清空了最低位 </div>      |
| `((x / 2) * 2) <= x`       | `1`                            |   <div v-click> False </div>     |     <div v-click> 向零取整，负奇数 </div>      |
| `x ^ y ^ (~x) - y`         | `y ^ x ^ (~y) - x`             |    <div v-click> True </div>    |     <div v-click> 优先级，`-x = ~x + 1` </div>      |
| `(x == 1) && (ux - 2 < 2)` | `(x == 1) && ((!!ux) - 2 < 2)` |    <div v-click> False </div>    |     <div v-click> `!!ux` 会被整型提升到 int </div>      |

---

# 练习：浮点运算

Exercises

考虑 IEEE-754 标准的浮点数

| **Description**                                                  | **True?** | **Why?** |
| ------------------------------------------------------------ | ----- | ---- |
| 对于任意单精度浮点数 `a` 和 `b`，若 `a > b`，则 `a + 1 > b`  |    <div v-click> True </div>   |   <div v-click> 显然 </div>   |
| 对于任意单精度浮点数 `a` 和 `b`，若 `a > b`，则 `a + b > b = b` |    <div v-click> False </div>   |   <div v-click> `inf` </div>   |
| 对于任意双精度浮点数 `d`，若 `d < 0`，那么 `d * d > 0`       |    <div v-click> False </div>   |   <div v-click> 下溢 </div>   |
| 对于任意双精度浮点数 `d`，若 `d < 0`，那么 `d * 2 < 0`       |   <div v-click> True </div>    |   <div v-click> `-inf` 也没关系 </div>   |
| 对于任意双精度浮点数 `d`，`d == d`                           |   <div v-click> False </div>    |   <div v-click> NaN </div>   |
| 将 `float` 转换为 `int` 时，既可能造成舍入，也可能造成溢出   |   <div v-click> True </div>    |   <div v-click> 显然 </div>   |

----

# 练习：浮点运算

Exercises

（19 期中）运行下面的代码，输出结果是（其中 `float` 类型表示 IEEE-754 规定的浮点数，包括 1 位符号、8 位阶码和 23 位尾数）：

```c
for (float f = 1; ; f = f + 1) {
  if (f + 1 - f != (float)1) {
    printf("%.0f\n", f);
    break;
  }
}
```

A. `8388608(=2^23)`
B. `16777216(=2^24)`
C. `2147483647(=2^31-1)`
D. 程序为死循环，没有输出

<div v-click>

`float` 有几位尾数？答案很明显了。

</div>

---

# 练习：浮点舍入

Exercises

（13 期中）对 $x = 1 \frac 18$ 和 $y = 1 \frac 38$ 进行小数点后两位取整（rounding to nearest even），结果正确的是

A. $1\frac14, 1\frac14$

B. $1, 1\frac14$

C. $1\frac14, 1\frac12$

D. $1, 1\frac12$

<div v-click>

$x = (1.00100)_2$，“四舍六入五成双”，$(1.00)_2$。

$y = (1.01100)_2$，“四舍六入五成双”，$(1.10)_2$。

</div>

---
layout: cover
class: text-center
coverBackgroundUrl: /01-Data-Representation/cover.jpg
---

# Thank you for your listening!


Cat$^2$Fish❤

<style>
  div{
   @apply text-gray-2;
  }
</style>