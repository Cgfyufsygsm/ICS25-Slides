---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: bg.jpg
# some information about your slides (markdown enabled)
title: "03-Arch1"
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
coverBackgroundUrl: /03-Arch1/cover.jpg
---

# Arch 1: ISA/Sequential

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

# 什么是 ISA？

Instruction Set Architecture

直译：指令集体系结构

- 一个处理器支持的指令和指令的字节级编码
- 不同的处理器“家族”都有不同的 ISA
- 本章我们将研究一个硬件系统怎么执行某种 ISA（Y86-64）

Y86-64：一种精简的 ISA（基于 x86-64）

<div v-click>

- 定义一个 ISA 需要定义：
  - 状态单元
  - 指令集及编码
  - 编程规范
  - 异常处理

</div>


---

# 程序员可见状态

programmer visible state


| 缩写 | 全称 | 描述 | 包括 |
|------|-------|------|------|
| RF   | Register File | 程序寄存器 | `%rax` ~ `%r14` |
| CC   | Condition Code | 条件码 | ZF<span follow>zero</span>, OF<span follow>overflow</span>, SF<span follow>symbol</span> |
| Stat | Status | 程序状态 | - |
| PC   | Program Counter | 程序计数器 | - |
| DMEM | Data Memory | 内存 | - |

<style>
span[follow] {
  @apply text-[0.6rem];
}
</style>

<!--
指的是指令可以读取/修改的处理器状态。包含RF, CC, Stat, PC, DMEM
-->


---
layout: image-right
image: /03-Arch1/Y86-Instruction.png
---

# Y86-64 ISA

一个 X86-64 的子集

```md {all|1|2|3|4|5|6|7|8|9|10|11|12|13|all}
* halt # 停机
* nop # 空操作，可以用于对齐字节
* cmovXX rA, rB # 如果条件码满足，则将寄存器 A 的值移动到寄存器 B
* rrmovq rA, rB # 将寄存器 A 的值移动到寄存器 B
* irmovq V, rB # 将立即数 V 移动到寄存器 B
* rmmovq rA, D(rB) # 将寄存器 A 的值移动到内存地址 rB + D
* mrmovq D(rB), rA # 将内存地址 rB + D 的值移动到寄存器 A
* OPq rA, rB # 将寄存器 A 和寄存器 B 的值进行运算，结果存入寄存器 B
* jXX Dest # 如果条件码满足，跳转到 Dest
* call Dest # 跳转到 Dest，同时将下一条指令的地址压入栈
* ret # 从栈中弹出地址，跳转到该地址
* pushq rA # 将寄存器A的值压入栈
* popq rA # 从栈中弹出值，存入寄存器A
```

<div text-sm>

* 第一个字节为 **代码** ，其高 4 位为操作类型，低 4 位为操作类型（fn）的具体操作（或 0）
* F：0xF，为 Y86-64 中“不存在的寄存器”
* 所有数值（立即数、内存地址）均以 hex 表示，为 8 字节

</div>


---
layout: image-right
image: /03-Arch1/Y86-Instruction.png
---

# Y86-64 ISA

一个 X86-64 的子集

```md {all|1|2|3|4|5|6|7|8|9|10|11|12|13|all}
* halt # 停机
* nop # 空操作，可以用于对齐字节
* cmovXX rA, rB # 如果条件码满足，则将寄存器 A 的值移动到寄存器 B
* rrmovq rA, rB # 将寄存器 A 的值移动到寄存器 B
* irmovq V, rB # 将立即数 V 移动到寄存器 B
* rmmovq rA, D(rB) # 将寄存器 A 的值移动到内存地址 rB + D
* mrmovq D(rB), rA # 将内存地址 rB + D 的值移动到寄存器 A
* OPq rA, rB # 将寄存器 A 和寄存器 B 的值进行运算，结果存入寄存器 B
* jXX Dest # 如果条件码满足，跳转到 Dest
* call Dest # 跳转到 Dest，同时将下一条指令的地址压入栈
* ret # 从栈中弹出地址，跳转到该地址
* pushq rA # 将寄存器A的值压入栈
* popq rA # 从栈中弹出值，存入寄存器A
```


<div class="text-[0.8rem]" grid="~ cols-2 gap-4">

<div>
  
* i(immediate)：立即数
* r(register)：寄存器
* m(memory)：内存地址{.text-sky-4}
  
</div>
<div>
  
* d(displacement)：偏移量
* dest(destination)：目标地址
* v(value)：数值
  
</div>
</div>


---
layout: image-right
image: /03-Arch1/register.png
---

# 寄存器

Register

```markdown{all|1-4|5-6|7-8|9-15|16|all|8,7,3,2|all|4,6,13-16}
* 0x0 %rax 
* 0x1 %rcx
* 0x2 %rdx
* 0x3 %rbx
* 0x4 %rsp
* 0x5 %rbp
* 0x6 %rsi
* 0x7 %rdi
* 0x8 %r8
* 0x9 %r9
* 0xA %r10
* 0xB %r11
* 0xC %r12
* 0xD %r13
* 0xE %r14
* 0xF F / No Register
```

- 一共只有 15 个寄存器，`0xF` 表示空。
- 用 4 个二进制位来标识


---

# 汇编代码翻译

translate assembly code to machine code

以下习题节选自书 P248，练习题 4.1 / 4.2

<div v-click-hide>

### Quiz

|     |     |
| --- | --- |
| 0x200 | a0 6f 80 0c 02 00 00 00 00 00 00 00 30 f3 0a 00 00 00 00 00 00 00 90 |
| loop | rmmovq %rcx, -3(%rbx) |

对于第一条翻译为汇编代码，第二条翻译为机器码

<br/>

</div>

<div v-after>

### Step 1
|     |     |
| --- | --- |
| 0x200 | <kbd>a0</kbd> <kbd>6f</kbd> \| <kbd>80</kbd> <kbd>0c 02 00 00 00 00 00 00</kbd> \| <kbd>00</kbd> \| <kbd>30</kbd> <kbd>f</kbd><kbd>3</kbd> <kbd>0a 00 00 00 00 00 00 00</kbd> \| <kbd>90</kbd>|
| loop | rmmovq, rcx, rbx, -3 |


</div>

<br>

<div v-click>

### Step 2

<div  grid="~ cols-2 gap-4">
<div>

```bash
0x200:
  pushq %rbp
  call 0x20c
  halt
0x20c:
  irmovq $10 %rbx
  ret
```

</div>
<div>

<kbd>40</kbd> <kbd>1</kbd><kbd>3</kbd> <kbd>ff ff ff fd</kbd>

</div>
</div>
</div>

<style>
.slidev-vclick-hidden {
  @apply hidden;
}
</style>



<!--
地址、立即数都是小端法

0x200:
  pushq %rbp
  call 0x20c
  halt
0x20c:
  irmovq $10 %rbx
  ret

<kbd>40</kbd> <kbd>1</kbd><kbd>3</kbd> <kbd>ff ff ff fd</kbd>
-->

---

# Y86-64 vs x86-64, CISC vs RISC

Complex Instruction Set Computer & Reduced Instruction Set Computer


<div grid="~ cols-2 gap-4">
  <div>

* Y86-64 是 X86-64 的子集
* X86-64 更复杂，但是更强大
* Y86-64 更简单，复杂指令由简单指令组合而成
  
如 Y86-64 的算数指令（`OPq`）只能操作寄存器，而 X86-64 可以操作内存

> 所以 Y86-64 需要额外的指令（`mrmovq`、`rmmovq`）来先加载内存中的值到寄存器，再进行运算

  </div>
<div>

* CISC：复杂指令集计算机
* RISC：精简指令集计算机
* 设计趋势是融合的


</div>
</div>

---

# CISC vs RISC

需要会，很喜欢考

<div grid="~ cols-2 gap-4">
  <div>

## RISC

- 指令数量少
- 没有较长延迟的指令
- 指令编码定长（通常为 4 字节）
- 寻址方式简单
- 只能对寄存器操作数运算
- 没有条件码
- 栈密集的过程链接

代表：ARM, MIPS, RISC-V

  </div>
<div>

## CISC

- 指令数量多（非常多）
- 有些指令延迟很长
- 编码长度可变
- 寻址方式多样：`Imm(%base, %index, scale)`
- 可以对内存操作数运算
- 有条件码
- 寄存器密集的过程链接

代表：IA32, x86-64

</div>
</div>

发展趋势是融合发展。请参考课本 p249-250。

我们学习的 Y86-64 既有 CISC 特性也有 RISC 特性。

<!--
栈密集：用栈存取过程参数和返回地址。
抽学生分析 Y86 有什么 CISC 特性和 RISC 特性。
CISC：条件码，变长指令，用栈保存返回地址
RISC：寄存器传递过程参数，load/store来操作内存
-->


---

# Y86-64 状态

status

状态码 Stat 描述了程序执行的总体状态。

| 值 | 名字 | 含义 | 全称 |
|----|------|------|------|
| 1  | `AOK`  | 正常操作 | All OK |
| 2  | `HLT`  | 遇到器执行`halt`指令遇到非法地址 | Halt |
| 3  | `ADR`  | 遇到非法地址，如向非法地址读/写 | Address Error |
| 4  | `INS`  | 遇到非法指令，如遇到一个 `ff` | Invalid Instruction |

除非状态值是 `AOK`，否则程序会停止执行。

---

# Y86-64 栈

stack

`Pushq rA F / 0xA0 rA F`

压栈指令
- 将 `%rsp` 减去8
- 将字从 `rA` 存储到 `%rsp` 的内存中

<br>

***

`Popq rA F / 0xB0 rA F`

弹栈指令
- 将字从 `%rsp` 的内存中取出
- 将 `%rsp` 加上8
- 将字存储到 `rA` 中

<!--
强调栈是从高往低增长的


Fn是0，第二个寄存器是F


根据书 P334 4.7、4.8，如果压栈 / 弹栈的时候的寄存器恰为 `%rsp`，则不会改变 `%rsp` 的值。
-->


---

# Y86-64 过程调用

`call` & `ret`

`Call Dest / 0x80 Dest`

调用指令
- 将下一条指令的地址 `pushq` 到栈上（`%rsp` 减 8、地址存入栈中）
- 从目标处开始执行指令

<br/>

***

`Ret / 0x90`

返回指令
- 从栈上 `popq` 出地址，用作下一条指令的地址（`%rsp` 加 8、地址从栈中取出，存入 `%rip`）


---

# Y86-64 终止与对齐

`Halt / 0x00`

终止指令
- 停止执行
- 停止模拟器
- 在遇到初始化为 0 的内存地址时，也会终止

<br/>

`Nop / 0x10`

空操作
- 什么都不做（但是 PC <span text-sm> Program Counter </span> + 1），可以用于对齐字节

---

# Y86-64 汇编

Y86-64 Assembly

与 x86-64 的区别与联系：

- 在算数指令中不能使用立即数操作数
  - 需要先 `irmovq` 一下
- 在算数指令中不能使用内存操作数
  - 需要先 `rmmovq` 一下
  - （至于为什么，学 SEQ 的时候就知道了）
- 所有的 `movq` 指令都有前缀指定其功能
  - 注意没有 `mmmovq`
- 操作数都是 64 位
- 其余与 x86-64 很像。
- Y86-64 模拟器推荐：https://boginw.github.io/js-y86-64/


---

# 逻辑设计和硬件控制语言 HCL

hardware control language

* 计算机底层是 0（低电压） 和 1（高电压）的世界
* HCL（硬件 **控制** 语言）是一种硬件 **描述** 语言（HDL），用于描述硬件的逻辑电路
* HCL 是 HDL 的子集

<br>

<div grid="~ cols-3 gap-4"  mt-2>

<div>

#### 与门 And

![And](/03-Arch1/and.png){.h-30}

```c
out = a&&b
```

</div>

<div>

#### 或门 Or

![Or](/03-Arch1/or.png){.h-30}

```c
out = a||b
```

</div>

<div>

#### 非门 Not

![Not](/03-Arch1/not.png){.h-30}

```c
out = !a
```

</div>

</div>

记忆：方形的更严格→与；圆形的更宽松→或



---

# 组合电路 / 高级逻辑设计

中杯：bit level / bool

<div grid="~ cols-2 gap-12"  mt-2>

<div>

```c
bool eq = (a && b) || (!a && !b);
```

![bit_eq](/03-Arch1/bit_eq.png){.h-50.mx-auto}

- 组合电路是 `响应式` 的：在输入改变时，输出经过一个很短的时间会立即改变
- 没有短路求值特性：`a && b` 不会在 `a` 为 `false` 时就不计算 `b`

</div>

<div>

```c
bool out = (s && a) || (!s && b);
```

![bit_mux](/03-Arch1/bit_mux.png){.h-50.mx-auto}

- Mux：Multiplexer / 多路复用器，用一个 `s` 信号来选择 `a` 或 `b`

</div>

</div>


---

# 组合电路 / 高级逻辑设计

大杯：word level / word

<div grid="~ cols-2 gap-12">
<div>




```c
bool Eq = (A == B)

```

![word_eq](/03-Arch1/word_eq.png){.h-60}

</div>

<div>

```c
int Out = [
  s : A; # select: expr
  1 : B;
];

```

![word_mux](/03-Arch1/word_mux.png){.h-60}

</div>
</div>


---

# 组合电路 / 算数逻辑单元 ALU
Arithmetic Logic Unit

![ALU](/03-Arch1/alu.png)

<div grid="~ cols-2 gap-4"  mt-2>

<div>

- 组合逻辑
- 持续响应输入
- 控制信号选择计算的功能
</div>
<div>

- 对应于 Y86-64 中的 4 个算术 / 逻辑操作
- 计算条件码的值
- 注意 `sub` 是被减的数在后面，即输入 B 减去输入 A
</div>
</div> 

大家可以想想这几个 ALU 可以怎么用逻辑门实现，其实并不难~

---

# 存储器和时钟

可能开始不好理解了

组合电路：不存储任何信息，只是一个 `输入` 到 `输出` 的映射（**有一定的延迟**）

时序电路：有 **状态** ，并基于此进行计算



---

# 时钟寄存器 / 寄存器 / 硬件寄存器

register

存储单个位或者字

- 以时钟信号控制寄存器加载输入值
- 直接将它的输入和输出线连接到电路的其他部分


<div grid="~ cols-2 gap-12" mt-8>
<div>

![clock-1](/03-Arch1/clock-1.png){.h-45.mx-auto}

</div>

<div>

![clock-2](/03-Arch1/clock-2.png){.h-45.mx-auto}

</div>
</div>

在 Clock 信号的上升沿，寄存器将输入的值采样并加载到输出端，其他时间输出端保持不变

---

# 随机访问存储器 / 内存

memory

<div grid="~ cols-2 gap-12">
<div>

以 **地址** 选择读写

包括：

- 虚拟内存系统，寻址范围很大
- 寄存器文件 / 程序寄存器，个数有限，在 Y86-64 中为 15 个程序寄存器（`%rax` ~ `%r14`）

可以在一个周期内读取和 / 或写入多个字词

**一定要注意“寄存器”这个词在不同语境下的语义差别！**

前一页的东西可以叫做“硬件寄存器”。

</div>

<div>

![register-file](/03-Arch1/register-file.png){.h-50.mx-auto}

两个读端口，一个写端口。srcA 输入查询地址，valA 返回存储在相应程序寄存器的值。

写入通过**时钟**控制，时钟上升时，valW 上的值会被写入 dstW 对应的程序寄存器（0xF 则什么都不做）。

</div>
</div>

---

# Y86-64 的顺序实现

sequential implementation

我们已经有了实现 Y86-64 处理器所需要的部件。接下来我们首先考虑实现一个 SEQ：每个时钟周期上 SEQ 完整执行一条指令。

当然这样的话，一个时钟周期就会很长，但是实现 SEQ 是将来实现流水线化的 PIPE 的基础。

对于 SEQ 的实现、线是怎么连接的，信号是怎么产生、在什么时候产生的，都**需要完全理解、背诵**

处理一条指令通常包含以下几个阶段：

1. 取指（Fetch）
2. 译码（Decode）
3. 执行（Execute）
4. 访存（Memory）
5. 写回（Write Back）
6. 更新PC（PC Update）

---

# Y86-64 的顺序实现

sequential implementation

<div grid="~ cols-2 gap-12">
<div>

### 1. 取指（Fetch）

**操作**：取指阶段从内存中读取指令字节，地址由程序计数器 (PC) 的值决定。



<div text-sm>

读出的指令由如下几个部分组成：

- `icode`：指令代码，指示指令类型，是指令字节的低 4 位
- `ifun`：指令功能，指示指令的子操作类型，是指令字节的高 4 位（不指定时为 0）
- `rA`：第一个源操作数寄存器（可选）
- `rB`：第二个源操作数寄存器（可选）
- `valC`：常数，Constant（可选）

</div>

<div text-sm text-gray-5 mt-4>

各个不同名称的指令一般具有不同的 `icode`，但是也有可能共享相同的 `icode`，然后通过 `ifun` 区分。

</div>
</div>

<div>

![fetch](/03-Arch1/fetch.png)

</div>
</div>

<!--
根据 icode 决定读多少字节后面的内容，以及读不读 rA, rB 和 valC
-->


---

# Y86-64 的顺序实现

sequential implementation

<div grid="~ cols-2 gap-12">
<div>

### 1. 取指（Fetch）

**操作**：取指阶段从内存中读取指令字节，地址由程序计数器 (PC) 的值决定。

<div text-sm>

- `ifun` 在除指令为 `OPq`，`jXX` 或 `cmovXX` 其中之一时都为 0
- `rA`，`rB` 为寄存器的编码，取值为 0 到 F，每个编码对应着一个寄存器。注意当编码为 F 时代表无寄存器。
- `rA`，`rB` 并不是每条指令都有的，`jXX`，`call` 和 `ret` 就没有 `rA` 和 `rB`，这在 HCL 中通过 `need_regids` 来控制
- `valC` 为 8 字节常数，可能代表立即数（`irmovq`），偏移量（`rmmovq` `mrmovq`）或地址（`call` `jmp`）。`valC` 也不是每条指令都有的，这在 HCL 中通过 `need_valC` 来控制


</div>
</div>

<div>

![fetch](/03-Arch1/fetch.png)

</div>
</div>

---

# Y86-64 的顺序实现

sequential implementation

### 2. 译码（Decode）

**操作**：译码阶段从寄存器文件读取操作数，得到 `valA` 和 / 或 `valB`。

一般根据上一阶段得到的 `rA` 和 `rB` 来确定需要读取的寄存器。

也有部分指令会读取 `rsp` 寄存器（`popq` `pushq` `ret` `call`）。


---

# Y86-64 的顺序实现

sequential implementation

### 3. 执行（Execute）

**操作**：执行阶段，算术/逻辑单元（ALU）进行运算，包括如下情况：

- 执行指令指明的操作（`opq`）
- 计算内存引用的地址（`rmmovq` `mrmovq`）
- 增加/减少栈指针（`pushq` `popq`）<span text-sm text-gray-5>其中加数可以是 +8 或 -8</span>

最终，我们把此阶段得到的值称为 `valE`（Execute stage value）。

一般来讲，这里使用的运算为加法运算，除非是在 `OPq` 指令中通过 `ifun` 指定为其他运算。这个阶段还会：

<div grid="~ cols-2 gap-12">
<div>

设置条件码（`OPq`）：

```hcl
set CC
```

</div>

<div>

检查条件码和和传送条件（`jXX` `cmovXX`）：

```hcl
Cnd <- Cond(CC, ifun)
```

</div>
</div>

---

# Y86-64 的顺序实现

sequential implementation

### 4. 访存（Memory）

**操作**：访存阶段可以将数据写入内存（`rmmovq` `pushq` `call`），或从内存读取数据（`mrmovq` `popq` `ret`）

- 若是向内存写，则：
  - 写入的地址为 `valE`（需要计算得到，`rmmovq` `pushq` `call`）
  - 数据为 `valA`（`rmmovq` `pushq`） 或 `valP`（`call`）
- 若是从内存读，则：
  - 地址为 `valA`（`popq` `ret`，此时 `valB` 用于计算更新后的 `%rsp`） 或者 `valE`（需要计算得到，`mrmovq`）
  - 读出的值为 `valM`（Memory stage value）

---

# Y86-64 的顺序实现

sequential implementation

### 5. 写回（Write Back）

**操作**：写回阶段最多可以写 **两个**{.text-sky-5} 结果到寄存器文件（即更新寄存器）。

---

# Y86-64 的顺序实现

sequential implementation

### 6. 更新PC（PC Update）

**操作**：将 PC 更新成下一条指令的地址 `new_pc`。

- 对于 `call` 指令，`new_pc` 是 `valC`
- 对于 `jxx` 指令，`new_pc` 是 `valC` 或 `valP`，取决于条件码
- 对于 `ret` 指令，`new_pc` 是 `valM`
- 其他情况，`new_pc` 是 `valP`


---

# Y86-64 的顺序实现

sequential implementation

<div text-sm>

下面是 `op`, `cmovXX`, `rrmovq` 和 `irmovq` 在 SEQ 实现中各个阶段的计算。

这里的表中没有写出 `cmovXX`，因为其与 `rrmovq` 共用同一个 `icode`，然后通过 `ifun` 区分。注意 `OPq` 的顺序，是 `valB OP valA`。

</div>

![seq_inst_stages_1](/03-Arch1/seq_inst_stages_1.png){.h-75.mx-auto}

<!--
可以发现是很统一地用 valE 写回。因为都是要用 ALU 计算出来的值。

注意 OP 操作是要更新 CC 的

注意 $M_1$ 和 $M_8$ 的区别
-->

---

# Y86-64 的顺序实现

sequential implementation

<div grid="~ cols-3 gap-8">
<div>

下面是两种涉及访存的 mov 类指令。

`valC` 被当做偏移量使用，与 `valB` 相加得到 `valE`，然后 `valE` 被当做地址使用。

</div>

<div col-span-2>

![seq_inst_stages_2](/03-Arch1/seq_inst_stages_2.png){.h-90.mx-auto}

</div>
</div>

---

# Y86-64 的顺序实现

sequential implementation

<div grid="~ cols-3 gap-8">
<div>

`popq` 中，会将 `valA` 和 `valB` 的值都设置为 `R[%rsp]`，因为一个要用于去当内存，读出旧 `M[%rsp]` 处的值，一个要用于计算，更新 `R[%rsp]`。

为了统一，在 `popq` 中，用于计算的依旧是 `valB`。

<div text-sm>

- `pushq %rsp` 的行为：`pushq` 压入的是旧的 `%rsp`，然后 `%rsp` 减 8
- `popq %rsp` 的行为：`popq` 读出的是旧的 `M[%rsp]`，然后 `%rsp` 加 8

↑ 其他情况：

`pushq` 先 -8 再压栈；`popq` 先读出再 +8

</div>

</div>

<div col-span-2>

![seq_inst_stages_3](/03-Arch1/seq_inst_stages_3.png){.h-90.mx-auto}

</div>
</div>

<!--
这个是最复杂的

为了统一都是用 valB 来读 %rsp 的值然后进行更新后的指针计算。

可以发现访存是在写回前执行的，所以访存的时候栈指针是还没有更新的
-->
---

# Y86-64 的顺序实现

sequential implementation

<div grid="~ cols-3 gap-8">
<div>

根据这个流程，思考一下 `pushq %rsp` 和 `popq %rsp` 的时候会发生什么？

<div v-click>

- `pushq %rsp` 的时候，`rA = rB = %rsp`，访存时写入内存的是 `valA`，所以是把 `%rsp` 还没修改的值压进了栈。
- `popq %rsp` 的时候，`valM` 为栈顶的值。最后会往 `%rsp` 里写 `valE` 和 `valM`，因为写 `valM` 后发生（见课本习题答案），所以是直接把 `%rsp` 重置为栈顶的值。

</div>

</div>

<div col-span-2>

![seq_inst_stages_3](/03-Arch1/seq_inst_stages_3.png){.h-90.mx-auto}

</div>
</div>

<!--
这个是最复杂的

为了统一都是用 valB 来读 %rsp 的值然后进行更新后的指针计算。

可以发现访存是在写回前执行的，所以访存的时候栈指针是还没有更新的
-->

---

# Y86-64 的顺序实现

sequential implementation

<div text-sm>

`ret` 指令和 `popq` 指令类似，`call` 指令和 `pushq` 指令类似，区别只有 PC 更新的部分。

所以，同样注意他们用于计算的依旧是 `valB`。

</div>

![seq_inst_stages_4](/03-Arch1/seq_inst_stages_4.png){.h-75.mx-auto}

<!--
几个涉及控制流跳转的指令

解释一下这里的 Cnd 是什么。

call 和 ret 与 pushq 和 popq 都很像，只有 PC 更新的时候不一样
-->

---

# HCL 代码

hardware description/control language

HCL 语法包括两种表达式类型：**布尔表达式**（单个位的信息）和**整数表达式**（多个位的信息），分别用 `bool-expr` 和 `int-expr` 表示。

<div grid="~ cols-2 gap-12">
<div>

#### 布尔表达式

逻辑操作

`a && b`，`a || b`，`!a`（与、或、非）

字符比较

`A == B`，`A != B`，`A < B`，`A <= B`，`A >= B`，`A > B`

集合成员资格

`A in { B, C, D }`

等同于 `A == B || A == C || A == D`

</div>

<div>

#### 字符表达式

case 表达式

```hcl
[
  bool-expr1 : int-expr1
  bool-expr2 : int-expr2
  ...
  bool-exprk : int-exprk
]
```

- `bool-expr_i` 决定是否选择该 case。
- `int-expr_i` 为该 case 的值。

<div text-sky-5>

依次评估测试表达式，返回第一个成功测试的字符表达式 `A`，`B`，`C`

</div>

</div>
</div>


---

# 顺序实现 - 取指阶段

sequential implementation: fetch stage

<div grid="~ cols-2 gap-12">
<div>

```hcl {*}{maxHeight:'380px'}
# 指令代码
word icode = [
  imem_error: INOP; # 读取出了问题，返回空指令
  1: imem_icode; # 读取成功，返回指令代码
];

# 指令功能
word ifun = [
  imem_error: FNONE; # 读取出了问题，返回空操作
  1: imem_ifun; # 读取成功，返回指令功能
];

# 指令是否有效
bool instr_valid = icode in {
  INOP, IHALT, IRRMOVQ, IIRMOVQ, IRMMOVQ, IMRMOVQ,
  IOPQ, IJXX, ICALL, IRET, IPUSHQ, IPOPQ
};

# 是否需要寄存器
bool need_regids = icode in {
  IRRMOVQ, IOPQ, IPUSHQ, IPOPQ,
  IIRMOVQ, IRMMOVQ, IMRMOVQ
};

# 是否需要常量字
bool need_valC = icode in {
  IIRMOVQ, IRMMOVQ, IMRMOVQ, IJXX, ICALL
};
```

</div>

<div>

![fetch](/03-Arch1/fetch.png)

</div>
</div>

---

# 顺序实现 - 译码阶段

sequential implementation: decode stage

<div grid="~ cols-2 gap-12">
<div>

```hcl
# 源寄存器 A 的选择
word srcA = [
  icode in { IRRMOVQ, IRMMOVQ, IOPQ, IPUSHQ } : rA;
  icode in { IPOPQ, IRET } : RRSP;
  1 : RNONE; # 不需要寄存器
];
# 源寄存器 B 的选择
word srcB = [
  icode in { IOPQ, IRMMOVQ, IMRMOVQ } : rB;
  icode in { IPUSHQ, IPOPQ, ICALL, IRET } : RRSP;
  1 : RNONE; # 不需要寄存器
];
```

</div>

<div>

```hcl
# 目标寄存器 E 的选择
word dstE = [
  icode in { IRRMOVQ } && Cnd : rB; # 支持 cmovXX
  icode in { IIRMOVQ, IOPQ } : rB; # 注意这里！
  icode in { IPUSHQ, IPOPQ, ICALL, IRET } : RRSP;
  1 : RNONE; # 不写入任何寄存器
];
# 目标寄存器 M 的选择
word dstM = [
  icode in { IMRMOVQ, IPOPQ } : rA;
  1 : RNONE; # 不写入任何寄存器
];
```


</div>
</div>

寄存器 ID `srcA` 表明应该读哪个寄存器以产生 `valA`（注意不是 `aluA`），`srcB` 同理。

寄存器 ID `dstE` 表明写端口 E 的目的寄存器，计算出来的 `valE` 将放在那里，`dstM` 同理。

在 SEQ 实现中，回写和译码放到了一起。

---

# 顺序实现 - 执行阶段

sequential implementation: execute stage


```hcl
# 选择 ALU 的输入 A
word aluA = [
  icode in { IRRMOVQ, IOPQ } : valA;  # 指令码为 IRRMOVQ 时，执行 valA + 0
  icode in { IIRMOVQ, IRMMOVQ, IMRMOVQ } : valC;  # 立即数相关，都送入的是 aluA
  icode in { ICALL, IPUSHQ } : -8;  # 减少栈指针
  icode in { IRET, IPOPQ } : 8;  # 增加栈指针
  # 其他指令不需要 ALU
];
# 选择 ALU 的输入 B，再次强调 OPq 指令中，是 `valB OP valA`
word aluB = [
  icode in { IRMMOVQ, IMRMOVQ, IOPQ, ICALL, IPUSHQ, IRET, IPOPQ } : valB;  # 大部分都用 valB
  icode in { IRRMOVQ, IIRMOVQ } : 0;  # 指令码为 IRRMOVQ 或 IIRMOVQ 时，选择 0
  # 其他指令不需要 ALU
];
# 设置 ALU 功能
word alufun = [
  icode == IOPQ : ifun;  # 如果指令码为 IOPQ，则使用 ifun 指定的功能
  1 : ALUADD;  # 默认使用 ALUADD 功能
];
# 是否更新条件码
bool set_cc = icode in { IOPQ };  # 仅在指令码为 IOPQ 时更新条件码
```

---

# 顺序实现 - 访存阶段

sequential implementation: memory stage

<div grid="~ cols-2 gap-12">
<div>


```hcl
# 设置读取控制信号
bool mem_read = icode in { IMRMOVQ, IPOPQ, IRET };
# 设置写入控制信号
bool mem_write = icode in { IRMMOVQ, IPUSHQ, ICALL };
# 选择内存地址
word mem_addr = [
  icode in { IRMMOVQ, IPUSHQ, ICALL, IMRMOVQ } : valE;
  icode in { IPOPQ, IRET } : valA; # valE 算栈指针去了
  # 其它指令不需要使用地址
];
```


</div>

<div>


```hcl
# 选择内存输入数据
word mem_data = [
  # 从寄存器取值
  icode in { IRMMOVQ, IPUSHQ } : valA; # valB 算地址去了
  # 返回 PC
  icode == ICALL : valP;
  # 默认：不写入任何数据
];
# 确定指令状态
word Stat = [
  imem_error || dmem_error : SADR;
  !instr_valid : SINS;
  icode == IHALT : SHLT;
  1 : SAOK;
];
```

</div>
</div>

---

# 顺序实现 - 更新 PC 阶段

sequential implementation: update pc stage



<div grid="~ cols-2 gap-12">
<div>

```hcl
# 设置新 PC 值
word new_pc = [
  # 调用指令，使用指令常量
  icode == ICALL : valC;
  # 条件跳转且条件满足，使用指令常量
  icode == IJXX && Cnd : valC;
  # RET 指令完成，使用栈中的值
  icode == IRET : valM;
  # 默认：使用递增的 PC 值
  # 等于上一条指令地址 + 上一条指令长度 1,2,9,10
  1 : valP;
];
```

</div>

<div v-click>

![fetch](/03-Arch1/fetch.png)


</div>
</div>

<button @click="$nav.go(26)">🔙</button>

---

<div grid="~ cols-2 gap-12">
<div>

# 顺序实现 - 总结

sequential implementation: summary

重点关注：

- `valA` 和 `valB` 怎么连的
- 什么时候 `valP` 可以直传内存
- 什么时候 `valA` 可以直传内存

<div v-click mt-4>

### 答案：

1. `call`
2. `rmmovq` `pushq` `popq` `retq` （`mrmovq` 需要吗？不！）

</div>

</div>

<div>



![seq_hardware](/03-Arch1/seq_hardware.png){.h-120.mx-auto}

</div>
</div>


---
layout: cover
class: text-center
coverBackgroundUrl: /03-Arch1/cover.jpg
---

# Thank you for your listening!


Cat$^2$Fish❤

<style>
  div{
   @apply text-gray-2;
  }
</style>
