---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: bg.jpg
# some information about your slides (markdown enabled)
title: "04-Arch2-Hierarchy"
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
coverBackgroundUrl: /04-Arch2-Hierarchy/cover.png
---

# Pipeline & Memory Hierarchy

Taoyu Yang, EECS, PKU

<style>
  div{
   @apply text-gray-2;
  }
</style>

---

# 关于 Archlab

- **请仔细完整阅读 writeup！！**
- Part-B 是助你理解流水线的重要练习
  - 强烈建议不要用 AI 辅助
  - 鼓励同学之间互相讨论
  - 利用 Git 做版本管理会方便不少
  - 初始下发的 `pipe_s4b.rs` 和 `pipe_s4c.rs` 有问题，请对照群消息修改或者下载最新版
  - ~~可能听完这次课你也不理解流水线，但自己写完 Part-B 是一定可以理解的~~
- Part-C
  - 仔细读评分标准可以发现 arch cost 这个指标可能比你想象中重要！
  - 不是几年前狂卷 CPE 的时代了
  - ac 如何降到 3 呢，仔细想想！
- **注意 DDL 是 11 月 3 号！！！尽早开始写**
- ~~这周四就发 cachelab 了，不要 pipelined lab（~~

---
layout: center
class: text-center
---

# 研讨题分享

<!--

-->


---

# 流水线实现

pipelined implementation

什么是流水线？答：通过同一时间上的并行，来提高效率。

<div grid="~ cols-2 gap-12">
<div>

![without_pipeline](/04-Arch2-Hierarchy/without_pipeline.png)

</div>

<div>

![with_pipeline](/04-Arch2-Hierarchy/with_pipeline.png)

</div>
</div>

---

# 流水线实现

pipelined implementation

<div class="text-sm">


吞吐量：单位时间内完成的指令数量。

单位：每秒千兆指令（GIPS，$10^9$ instructions per second，等于 1 ns（$10^{-9}$ s） 执行多少条指令再加个 G）。


<div grid="~ cols-2 gap-8">
<div>

$$
\text{吞吐量} = \frac{1}{(300 + 20) \text{ps}} \cdot \frac{1000 \text{ps}}{1 \text{ns}}  = 3.125 \text{GIPS}
$$

![without_pipeline](/04-Arch2-Hierarchy/without_pipeline.png){.h-60.mx-auto}

</div>

<div>

$$
\text{吞吐量} = \frac{1}{(100 + 20) \text{ps}} \cdot \frac{1000 \text{ps}}{1 \text{ns}}  = 8.33 \text{GIPS}
$$

![with_pipeline](/04-Arch2-Hierarchy/with_pipeline.png){.h-60.mx-auto}

</div>
</div>


</div>

---

# 流水线实现的局限性

pipelined implementation: limitations

- **运行时钟的速率是由最慢的阶段的延迟限制的**。每个时钟周期的最后，只有最慢的阶段会一直处于活动状态
- **流水线过深**：不能无限增加流水线的阶段数，**因为此时流水线寄存器的延迟占比加大**。
- **数据冒险**

<div grid="~ cols-2 gap-12">
<div>

![pipe_limit_1](/04-Arch2-Hierarchy/pipe_limit_1.png){.mx-auto}

</div>

<div>

![pipe_limit_2](/04-Arch2-Hierarchy/pipe_limit_2.png){.mx-auto}

</div>
</div>

```asm
irmovq $50, %rax   ; 将立即数50移动到寄存器rax中
addq %rax, %rbx    ; 将寄存器rax中的值与rbx中的值相加
mrmovq 100(%rbx), %rdx  ; 从内存地址rbx+100读取值到寄存器rdx中
```

---

# 小练习：流水线计算

exercise

A~H 为8个基本逻辑单元，下图中标出了每个单元的延迟，以及用箭头标出了单元之间的数据依赖关系。寄存器的延迟均为10ps。

<div grid="~ cols-[1fr_1.8fr] gap-12">

<div>

1. 计算目前的电路的总延迟
2. 通过插入寄存器，可以对这个电路进行流水化改造。现在想将其改造为两级流水线，为了达到尽可能高的吞吐率，问寄存器应插在何处?获得的吞吐率是多少?
3. 现在想将其改造为三级流水线，问最优改造所获得的吞吐率是多少?

</div>

<div>

![](/04-Arch2-Hierarchy/pipeline_calc_exercise.png)

</div>

</div>

---

# SEQ 与 SEQ+

SEQ vs SEQ+

- 在 SEQ 中，PC 计算发生在时钟周期结束的时候，根据当前时钟周期内计算出的信号值来计算 PC 寄存器的新值。
- 在 SEQ+ 中，我们需要在每个时钟周期都可以取出下一条指令的地址，所以更新 PC 阶段在一个时钟周期开始时执行，而不是结束时才执行。
- **SEQ+ 没有硬件寄存器来存放程序计数器**。而是根据从前一条指令保存下来的一些状态信息动态地计算 PC。

![seq+_pc](/04-Arch2-Hierarchy/seq+_pc.png){.mx-auto.h-40}

此处，小写的 `p` 前缀表示它们保存的是前一个周期中产生的控制信号。

<!--
意思就是在之前的 SEQ 里面，一条指令全部执行完之后才知道 PC 的新值。不方便我们流水线化地取下一条指令

所以在 SEQ+ 里面把更新 PC 阶段放在开头，直接从前一条指令留下来的信息算 PC，即放到了取指阶段进行
-->

---

# SEQ vs SEQ+

<div grid="~ cols-2 gap-12">
<div>

![seq_hardware](/04-Arch2-Hierarchy/seq_hardware.png){.h-90.mx-auto}

</div>

<div>

![seq+_hardware](/04-Arch2-Hierarchy/seq+_hardware.png){.h-90.mx-auto}

</div>
</div>

<!--
把新 PC 的计算移动到了最前，其余没有区别
-->

---

<div grid="~ cols-2 gap-12">
<div>

# 弱化一些的 PIPE 结构

PIPE-

<div class="text-sm">

各个信号的命名：

- 在命名系统中，大写的前缀 “D”、“E”、“M” 和 “W” 指的是 **流水线寄存器**，所以 `M_stat` 指的是流水线寄存器 `M` 的状态码字段。

    可以理解为，对应阶段开始时就已经是正确的值了（且由于不回写的原则，所以该时钟周期内不会再改变，直到下一个时钟上升沿的到来）
- 小写的前缀 `f`、`d`、`e`、`m` 和 `w` 指的是 **流水线阶段**，所以 `m_stat` 指的是在访存阶段 **中** 由控制逻辑块产生出的状态信号。

    可以理解为，对应阶段中，完成相应运算时才会是正确的值

- 右图中没有转发逻辑，右侧的实线是流水线寄存器间（大写前缀）的同步。

</div>




</div>

<div>

![pipe-_hardware](/04-Arch2-Hierarchy/pipe-_hardware.png){.h-120.mx-auto}

</div>
</div>

<!--
注意区分这里的大小写区别。
-->

---

# SEQ+ vs PIPE-

<div grid="~ cols-2 gap-12">
<div>

![seq+_hardware](/04-Arch2-Hierarchy/seq+_hardware.png){.h-90.mx-auto}

</div>

<div>

![pipe-_hardware](/04-Arch2-Hierarchy/pipe-_hardware.png){.h-90.mx-auto}

</div>
</div>

<button @click="$nav.go(43)">🔙</button>

<!--
在 SEQ+ 的基础上，把每个阶段的信号给放到流水线寄存器里面存下来
-->

---

<div grid="~ cols-2 gap-12">
<div>

# 弱化一些的 PIPE 结构

PIPE-


- 等价于在 SEQ+ 中插入了流水线寄存器 **（他们都是即将由对应阶段进行处理）**{.text-sky-5}
  - F：Fetch，取指阶段
  - D：Decode，译码阶段
  - E：Execute，执行阶段
  - M：Memory，访存阶段
  - W：Write back，写回阶段
- 同时，有个新模块 `selectA` 来选择 `valA` 的来源
  - `valP`：`call` `jXX`（后面讲，可以想想为啥，提示：控制冒险）
  - `d_rvalA`：其他未转发的情况（后面讲）<button @click="$nav.go(41)">🔙</button>

</div>

<div>

![pipe-_hardware](/04-Arch2-Hierarchy/pipe-_hardware.png){.h-120.mx-auto}

</div>
</div>

<!--
selectA 的逻辑其实就是，回顾 SEQ，只有 call 在 M 阶段需要 valP，只有 jXX 在 E 阶段（不需要跳转的时候）需要 valP。而他们都不需要寄存器文件读出来的 valA。所以我们将 valP 合并到 valA，这正是 selectA 在做的事情。

这样可以减少流水线寄存器的状态数量（不然是不是就需要在 E 和 M 都记 valP）
-->

---

# PIPE- 分支预测

PIPE- branch prediction

**分支预测**：猜测分支方向并根据猜测开始取指的技术。

对于 `jXX` 指令，有两种情况：

- 分支不执行：下一条 PC 是 `valP`
- 分支执行：下一条 PC 是 `valC`

由于我们现在是流水线，我们需要每个时钟周期都能给出一个指令地址用于取址，所以我们采用分支预测：

最简单的策略：总是预测选择了条件分支，因而预测 PC 的新值为 `valC`。

对于 `ret` 指令，我们等待它通过写回 `W` 阶段（从而可以从 `M` 中得到之前压栈的返回值并更新 `PC`）。

> 同条件转移不同，`ret` 可能的返回值几乎是无限的，因为返回地址是位于栈顶的字，其内容可以是任意的。

<!--
我们希望每个时钟周期都发射一条新指令

always taken
-->

---

# 流水线冒险

hazards

冒险分为两类：

1. **数据冒险 (Data Hazard)**：下一条指令需要使用当前指令计算的结果。
2. **控制冒险 (Control Hazard)**：指令需要确定下一条指令的位置，例如跳转、调用或返回指令。

<!-- 提醒大家仔细听 -->

---

# 数据冒险

data hazard

<div grid="~ cols-2 gap-8">
<div>

数据冒险是相对容易理解的。

在右图代码中，`%rax` 的值需要在第 6 个周期结束时才能完成写回，但是在 第 6 个周期内，正处于译码阶段的 `addq` 指令就需要使用 `%rax` 的值了。这就产生了数据冒险。

类似可推得，如果一条指令的操作数被它前面 3 条指令中的任意一条改变的话，都会出现数据冒险。

我们需要满足：当后来的需要某一寄存器的指令处于译码 D 阶段时，该寄存器的值必须已经更新完毕（即已经 **完成** 写回 W 阶段）。

<div class="text-sm">

以 2F 的左边缘作为起始时刻，则：

$$
5(完成 W) - 1(开始 D，即完成 F) - 1(错开一条指令) = 3
$$

</div>


</div>

<div>



![data_hazard](/04-Arch2-Hierarchy/data_hazard.png){.mx-auto}

</div>
</div>

---

# 数据冒险的解决：暂停

data hazard resolution: stall


<div grid="~ cols-2 gap-4">
<div>


**暂停**：暂停时，处理器会停止流水线中一条或多条指令，直到冒险条件不再满足。

<div class="text-sm">

> 让一条指令停顿在译码阶段，直到产生它的源操作数的指令通过了写回阶段，这样我们的处理器就能避免数据冒险。（即，下一个时钟周期开始时，此指令开始真正译码，此时源操作数已经更新完毕）

暂停技术就是让一组指令阻塞在它们所处的阶段，而允许其他指令继续通过流水线（如右图 `irmovq` 指令）。

每次要把一条指令阻塞在 **译码阶段**，就在 **执行阶段**（下一个阶段）插入一个气泡。

气泡就像一个自动产生的 `nop` 指令，**它不会改变寄存器、内存、条件码或程序状态。**{.text-sky-5}

</div>


</div>

<div>

![stall](/04-Arch2-Hierarchy/stall.png){.mx-auto}

<div class="text-xs">

- ↑ 5W、6W 的右边缘蓝色线代表直到此处，这条指令才能正确的更新寄存器，在 5W、6W 块内起始已经准备好了值，但是由于没有到时钟上升沿，所以并没有写入到只有在时钟上升沿才会采样输入、更新其内值的寄存器文件（注意不是流水线寄存器）。
- ↑ 7D 的左边缘蓝色线代表第 7 个周期的译码 D 阶段流水线寄存器，我们需要在此时保证寄存器文件（注意不是流水线寄存器）的值正确，因为在这个 7D 阶段，寄存器文件不会遇到新的时钟上升沿，更新其内值、其输出。

流水线寄存器 vs 寄存器文件：{.!mb-0}

- 流水线寄存器：保存的是和流水线某一阶段运算所需的一些初始值
- 寄存器文件：保存的是当前所有寄存器（`%rax` `%rbx` 等等）的值

</div>


</div>
</div>

---

# 暂停 vs 气泡

stall vs bubble

<div grid="~ cols-2 gap-12">
<div>

- 正常：寄存器的状态和输出被设置成输入的值
- 暂停：状态保持为先前的值不变
- 气泡：会用 `nop` 操作的状态覆盖当前状态

所以，在上页图中，我们说：
- 给执行阶段插入了气泡
- 对译码阶段执行了暂停


</div>

<div>

![stall_vs_bubble](/04-Arch2-Hierarchy/stall_vs_bubble.png){.mx-auto}

</div>
</div>

---

# 数据冒险的解决：转发

data hazard resolution: forwarding

<div grid="~ cols-2 gap-12">
<div>

实际上，在这里，所需要的真实  `%rax` 值，早在 4E 快结束时（其内红线）就已经计算出来了（3E 同理）。

而我们需要用到它的是 5E 的开始（此时，5E 阶段的组合逻辑即将从其左边缘红线所代表的 E 执行阶段流水线寄存器中取出 `valA` `valB` `valC` 用于计算）。

回忆：大写的寄存器是在对应阶段开始时就已经是正确的值。

</div>

<div>


![data_hazard_2](/04-Arch2-Hierarchy/data_hazard_2.png){.mx-auto}

</div>
</div>

---

# 数据冒险的解决：转发

data hazard resolution: forwarding

**转发**：将结果值直接从一个流水线阶段传到较早阶段的技术。

这个过程可以发生在许多阶段（下图中，要到 6E 寄存器才定下来，所以只要在时钟上升沿来之前，都来得及）。

<div grid="~ cols-2 gap-12">
<div>

![forward_1](/04-Arch2-Hierarchy/forward_1.png){.mx-auto.h-80}

</div>

<div>

![forward_2](/04-Arch2-Hierarchy/forward_2.png){.mx-auto.h-80}

</div>
</div>

---

# 特殊的数据冒险：加载 / 使用冒险

data hazard: load / use hazard

- 如果在先前指令的 E 执行阶段（其内靠后时）就已经可以得到正确值，那么由于后面的指令至少落后 1 个阶段，我们总可以在后面指令的 E 寄存器最终确定之前，将正确值转发解决问题。
- 如果在先前指令的 M 访存阶段（其内靠后时）才能得到正确值，且后面指令紧跟其后，那么当我们实际得到正确值时，必然赶不上后面指令的 E 寄存器最终确定，所以我们必须暂停流水线。
- 所以，加载 / 使用冒险只发生在 `mrmovq` 后立即使用对应寄存器的情况。

<div class="text-sm text-gray-5">

书上老说什么把值送回过去，我觉得第一次读真难明白吧。

</div>

---

# 特殊的数据冒险：加载 / 使用冒险

data hazard: load / use hazard

<div grid="~ cols-2 gap-12">
<div>

在这里，所需要的真实  `%rax` 值，在 8M 快结束时（其内红线）才能从内存中取出，位于 `m_valM`。

而我们需要用到它的是 8E 的开始（此时，8E 阶段的组合逻辑即将从其左边缘红线所代表的 E 执行阶段流水线寄存器中取出 `valA` `valB` `valC` 用于计算）。

在图中可以清晰看出，这存在时间上的错位，所以是不可能的。

</div>

<div>

![load_use_hazard](/04-Arch2-Hierarchy/load_use_hazard.png){.mx-auto}

</div>
</div>

---

# 加载 / 使用冒险解决方案：暂停 + 转发

load / use hazard solution

<div grid="~ cols-3 gap-12">
<div>

依旧是：

- 译码阶段中的指令暂停 1 个周期
- 执行阶段中插入 1 个气泡

此时，`m_valM` 的值已经更新完毕，所以可以转发到 `d_valA`（然后被用于存入 `E_valA`）。

`m_valM`：在 M 阶段内，取出的内存值

`d_valA`：在 D 阶段内，计算得到的即将设置为 `E_valA` 的值

</div>

<div col-span-2>

![load_use_hazard_solution](/04-Arch2-Hierarchy/load_use_hazard_solution.png){.mx-auto.h-100}

</div>
</div>

---

<div grid="~ cols-2 gap-12">
<div>

# PIPE 最终结构

PIPE final structure

把各个转发逻辑都画出来，就得到了最终的结构。

注意：

- `Sel + Fwd A`：是 PIPE- 中标号为 `Select A` 的块的功能与转发逻辑的结合。<button @click="$nav.go(30)">💡</button>
- `Fwd B`


</div>

<div>

![pipe_hardware](/04-Arch2-Hierarchy/pipe_hardware.png){.mx-auto.h-120}

</div>
</div>

---

# PIPE- vs PIPE

<div grid="~ cols-2 gap-12">
<div>

![pipe-_hardware](/04-Arch2-Hierarchy/pipe-_hardware.png){.h-110.mx-auto}

</div>

<div>

![pipe_hardware](/04-Arch2-Hierarchy/pipe_hardware.png){.h-110.mx-auto}

</div>
</div>

---

# 结构之间的差异

differences between structures

<div grid="~ cols-2 gap-4" text-sm>
<div>

### SEQ

- 完全的分阶段，且顺序执行
- 没有流水线寄存器
- 没有转发逻辑

</div>

<div>

### SEQ+

- 把计算新 PC 计算放到了最开始
- 目的：为了能够划分流水线做准备，当前指令到 D 阶段时，应当能开始下一条指令的 F 阶段
- 依旧是没有转发逻辑、且顺序执行
- <button @click="$nav.go(9)">💡 结构差异图</button> 

</div>

<div>

### PIPE-

- 在 SEQ+ 的基础上，增加了流水线寄存器
- 没有转发逻辑
- <button @click="$nav.go(11)">💡 结构差异图</button> 

</div>

<div>

### PIPE

- 在 PIPE- 的基础上，完善了转发逻辑，可以转发更多的计算结果（小写开头的，而不是只有大写开头的流水线寄存器）
- 增加了转发逻辑
- 转发源：`M_valA` `W_valW` `W_valE`（流水线寄存器们）、`e_valE` `m_valM`（中间计算结果们）
- 转发目的地：`d_valA` `d_valB` 
- <button @click="$nav.go(24)">💡 结构差异图</button> 


</div>

</div>

---

# 控制冒险

control hazard

**控制冒险**：当处理器无法根据处于取指阶段的当前指令来确定下一条指令的地址时，就会产生控制冒险。

<div grid="~ cols-2 gap-12">
<div>


发生条件：`RET` `JXX`

`RET` 指令需要弹栈（访存）才能得到下一条指令的地址。

`JXX` 指令需要根据条件码来确定下一条指令的地址。

- `Cnd ← Cond(CC, ifun)`
- `Cnd ? valC : valP`



</div>

<div>

```hcl
# 指令应从哪个地址获取
word f_pc = [
  # 分支预测错误时，从增量的 PC 取指令
  # 传递路径：D_valP -> E_valA -> M_valA
  # 条件跳转指令且条件不满足时
  M_icode == IJXX && !M_Cnd : M_valA;
  # RET 指令终于执行到回写阶段时（即过了访存阶段）
  W_icode == IRET : W_valM;
  # 默认情况下，使用预测的 PC 值
  1 : F_predPC;
];
```

<button @click="$nav.go(23)">💡PIPELINE 电路图</button>

注意，这里用到的都是流水线寄存器，而没有中间计算结果（小写前缀）。

</div>
</div>

---

# 控制冒险：RET

control hazard: RET

![control_hazard_ret](/04-Arch2-Hierarchy/control_hazard_ret.png){.mx-auto.h-45}

涉及取指 F 阶段的不能转发中间结果 `m_valM`，必须等到流水线寄存器 `W_valM` 更新完毕！

为什么：取址阶段没有相关的硬件电路处理中间结果的转发！必须是流水线寄存器同步。

所以需要插入 3 个气泡（以 3F 的左边缘作为起始时刻）：

$$
4(\text{RET } 完成 M) - 0(开始 F) - 1(错开一条指令) = 3
$$

为什么是气泡：<button @click="$nav.go(17)">💡暂停 vs 气泡</button> 暂停保留状态，气泡清空状态。

---

# 控制冒险：JXX

control hazard: JXX

<div grid="~ cols-2 gap-12">
<div>

- 分支逻辑发现不应该选择分支之前（到达执行 E 阶段），已经取出了两条指令，它们不应该继续执行下去了。
- 这两条指令都没有导致程序员可见状态发生改变（没到到执行 E 阶段）。

</div>

<div>

![control_hazard_jxx](/04-Arch2-Hierarchy/control_hazard_jxx.png){.mx-auto.h-40}

</div>
</div>
<div grid="~ cols-2 gap-12" text-sm>
<div>

```hcl
bool branch_mispred = E_icode == IJXX && !e_Cnd;
bool load_use_hazard = 
  E_icode in { IMRMOVQ, IPOPQ } &&
  E_dstM in { d_srcA, d_srcB };
bool ret_hazard = 
  IRET in { D_icode, E_icode, M_icode }
// 先把三种冒险的 HCL 表达式定义如上，方便之后使用
```

</div>

<div>

```hcl
bool D_bubble = branch_mispred ||
  !load_use_hazard && ret_hazard;
// 如果是 load_use_harzard 的话是 stall

bool E_bubble = branch_mispred || load_use_hazard
```

</div>
</div>

---

# 控制冒险：JXX

control hazard: JXX

<div grid="~ cols-2 gap-12">
<div text-sm>

1. 在第 4 个时钟周期内靠后的位置，在 4E 处的红线所在的执行阶段，通过组合逻辑计算得到 `jne` 的条件没有满足
2. 于是这个信息被转发到了前面同一周期的 D、F 阶段，而这两个阶段正在分别进行运算，以准备第 5 个时钟周期初始的 E、D 流水线寄存器（两个蓝色框右边缘）
3. 得到转发的信息后，他们分别通过设置两个值 `E_bubble` `D_bubble`（右图未画出），以告诉下一阶段
4. 进入到第 5 个时钟周期后，E、D 阶段首先读取 E、D 流水线寄存器，发现各自的 `Bubble` 信号为真时，便会用 Bubble 气泡的 `nop` 指令顶掉第 5 个时钟周期时的 E、D 阶段的指令（也即第 4 个时钟周期时的 D、F 阶段的指令），从而实现了气泡的插入，且顶掉了错误的指令。

</div>

<div>

![control_hazard_jxx](/04-Arch2-Hierarchy/control_hazard_jxx.png){.mx-auto.h-40}

<div class="text-sm">

↑深蓝色框里是插入气泡的逻辑发生位置，深蓝色框右边缘代表得出的气泡信号存储到的流水线寄存器，左边缘代表得到转发开始设置的时间。

</div>

</div>
</div>

---

# PIPELINE 的各阶段实现：取指阶段

pipeline hcl: fetch stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 指令应从哪个地址获取
word f_pc = [
  # 分支预测错误时，从增量的 PC 取指令
  # 传递路径：D_valP -> E_valA -> M_valA
  # 条件跳转指令且条件不满足时
  M_icode == IJXX && !M_Cnd : M_valA;
  # RET 指令终于执行到回写阶段时（即过了访存阶段）
  W_icode == IRET : W_valM;
  # 默认情况下，使用预测的 PC 值
  1 : F_predPC;
];
# 取指令的 icode
word f_icode = [
  imem_error : INOP;  # 指令内存错误，取 NOP
  1 : imem_icode;     # 否则，取内存中的 icode
];
# 取指令的 ifun
word f_ifun = [
  imem_error : FNONE; # 指令内存错误，取 NONE
  1 : imem_ifun;      # 否则，取内存中的 ifun
];
```
</div>

<div>

![pipeline_fetch_stage](/04-Arch2-Hierarchy/pipeline_fetch_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：取指阶段

pipeline hcl: fetch stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 指令是否有效
bool instr_valid = f_icode in {
  INOP, IHALT, IRRMOVQ, IIRMOVQ, IRMMOVQ, IMRMOVQ,
  IOPQ, IJXX, ICALL, IRET, IPUSHQ, IPOPQ
};
# 获取指令的状态码
word f_stat = [
  imem_error : SADR;   # 内存错误
  !instr_valid : SINS; # 无效指令
  f_icode == IHALT : SHLT; # HALT 指令
  1 : SAOK;            # 默认情况，状态正常
];
```

</div>

<div>

![pipeline_fetch_stage](/04-Arch2-Hierarchy/pipeline_fetch_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：取指阶段

pipeline hcl: fetch stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 指令是否需要寄存器 ID 字节
# 单字节指令 `HALT` `NOP` `RET`；不需要寄存器 `JXX` `CALL`
bool need_regids = f_icode in {
  IRRMOVQ, IOPQ, IPUSHQ, IPOPQ,
  IIRMOVQ, IRMMOVQ, IMRMOVQ
};
# 指令是否需要常量值
# 作为值；作为 rB 偏移；作为地址
bool need_valC = f_icode in {
  IIRMOVQ, IRMMOVQ, IMRMOVQ, IJXX, ICALL
};
# 预测下一个 PC 值
word f_predPC = [
  # 跳转或调用指令，取 f_valC
  f_icode in { IJXX, ICALL } : f_valC;
  # 否则，取 f_valP
  1 : f_valP;
];
```
</div>

<div>

![pipeline_fetch_stage](/04-Arch2-Hierarchy/pipeline_fetch_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：译码阶段

pipeline hcl: decode stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 决定 d_valA 的来源
word d_srcA = [
  # 一般情况，使用 rA
  D_icode in { IRRMOVQ, IRMMOVQ, IOPQ, IPUSHQ } : D_rA;
  # 此时，valB 也是栈指针
  # 但是同时需要计算新值（valB 执行阶段计算）、使用旧值访存（valA）
  D_icode in { IPOPQ, IRET } : RRSP;
  1 : RNONE; # 不需要 valA
];
# 决定 d_valB 的来源
word d_srcB = [
  # 一般情况，使用 rB
  D_icode in { IOPQ, IRMMOVQ, IMRMOVQ } : D_rB;
  # 涉及栈指针，需要计算新的栈指针值
  D_icode in { IPUSHQ, IPOPQ, ICALL, IRET } : RRSP;
  1 : RNONE; # 不需要 valB
];
```

</div>

<div>

![pipeline_decode_stage](/04-Arch2-Hierarchy/pipeline_decode_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：译码阶段

pipeline hcl: decode stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 决定 E 执行阶段计算结果的写入寄存器
word d_dstE = [
  # 一般情况，写入 rB，注意 OPQ 指令的 rB 是目的寄存器
  D_icode in { IRRMOVQ, IIRMOVQ, IOPQ} : D_rB;
  # 涉及栈指针，更新 +8/-8 后的栈指针
  D_icode in { IPUSHQ, IPOPQ, ICALL, IRET } : RRSP;
  1 : RNONE; # 不写入 valE 到任何寄存器
];
# 决定 M 访存阶段读出结果的写入寄存器
word d_dstM = [
  # 这两个情况需要更新 valM 到 rA
  D_icode in { IMRMOVQ, IPOPQ } : D_rA;
  1 : RNONE; # 不写入 valM 到任何寄存器
];
```

</div>

<div>

![pipeline_decode_stage](/04-Arch2-Hierarchy/pipeline_decode_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：译码阶段

pipeline hcl: decode stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 决定 d 译码阶段的 valA 的最终结果，即将存入 E_valA
word d_valA = [
  # 保存递增的 PC
  # 对于 CALL，d_valA -> E_valA -> M_valA -> 写入内存
  # 对于 JXX，d_valA -> E_valA -> M_valA
  # 跳转条件不满足（预测失败）时，同步到 f_pc
  D_icode in { ICALL, IJXX } : D_valP; # 保存递增的 PC
  d_srcA == e_dstE : e_valE; # 前递 E 阶段计算结果
  d_srcA == M_dstM : m_valM; # 前递 M 阶段读出结果
  d_srcA == M_dstE : M_valE; # 前递 M 流水线寄存器最新值
  d_srcA == W_dstM : W_valM; # 前递 W 流水线寄存器最新值
  d_srcA == W_dstE : W_valE; # 前递 W 流水线寄存器最新值
  1 : d_rvalA; # 使用从寄存器文件读取的值，r 代表 read
];
```

</div>

<div>

![pipeline_decode_stage](/04-Arch2-Hierarchy/pipeline_decode_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：译码阶段

pipeline hcl: decode stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 决定 d 译码阶段的 valB 的最终结果，即将存入 E_valB
word d_valB = [
  d_srcB == e_dstE : e_valE; # 前递 E 阶段计算结果
  d_srcB == M_dstM : m_valM; # 前递 M 阶段读出结果
  d_srcB == M_dstE : M_valE; # 前递 M 流水线寄存器最新值
  d_srcB == W_dstM : W_valM; # 前递 W 流水线寄存器最新值
  d_srcB == W_dstE : W_valE; # 前递 W 流水线寄存器最新值
  1 : d_rvalB; # 使用从寄存器文件读取的值，r 代表 read
];
```

</div>

<div>

![pipeline_decode_stage](/04-Arch2-Hierarchy/pipeline_decode_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：执行阶段

pipeline hcl: execute stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 选择 ALU 的输入 A
word aluA = [
  # RRMOVQ：valA + 0; OPQ：valB OP valA
  E_icode in { IRRMOVQ, IOPQ } : E_valA;
  # IRMOVQ：valC + 0; RMMOVQ/MRMOVQ：valC + valB
  E_icode in { IIRMOVQ, IRMMOVQ, IMRMOVQ } : E_valC;
  # CALL/PUSH：-8; RET/POP：8
  E_icode in { ICALL, IPUSHQ } : -8;
  E_icode in { IRET, IPOPQ } : 8;
  # 其他指令不需要 ALU 的输入 A
];
# 选择 ALU 的输入 B
word aluB = [
  # 涉及栈时，有 E_valB = RRSP，用于计算新值
  E_icode in { IRMMOVQ, IMRMOVQ, IOPQ, ICALL,
    IPUSHQ, IRET, IPOPQ } : E_valB;
  # 注意 IRMOVQ 的寄存器字节是 rA=F，即存到 rB
  E_icode in { IRRMOVQ, IIRMOVQ } : 0;
  # 其他指令不需要 ALU 的输入 B
];
```

</div>

<div>

![pipeline_execute_stage](/04-Arch2-Hierarchy/pipeline_execute_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：执行阶段

pipeline hcl: execute stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 设置 ALU 功能
word alufun = [
  # 如果指令是 IOPQ，则选择 E_ifun
  E_icode == IOPQ : E_ifun;
  # 默认选择 ALUADD
  1 : ALUADD;
];
# 是否更新条件码
# 仅在指令为 IOPQ 时更新条件码
# 且只在正常操作期间状态改变
bool set_cc = E_icode == IOPQ &&
  !m_stat in { SADR, SINS, SHLT } &&
  !W_stat in { SADR, SINS, SHLT };
```

</div>

<div>

![pipeline_execute_stage](/04-Arch2-Hierarchy/pipeline_execute_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：执行阶段

pipeline hcl: execute stage

<div grid="~ cols-2 gap-4">
<div>


```hcl
# 在执行阶段仅传递 valA 的去向
# E_valA -> e_valA -> M_valA
word e_valA = E_valA;
# CMOVQ 指令，与 RRMOVQ 共用 icode
# 当条件不满足时，不写入计算值到任何寄存器
word e_dstE = [
  E_icode == IRRMOVQ && !e_Cnd : RNONE
  1 : E_dstE;    # 否则选择 E_dstE
];
```

</div>

<div>

![pipeline_execute_stage](/04-Arch2-Hierarchy/pipeline_execute_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：访存阶段

pipeline hcl: memory stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 选择访存地址
word mem_addr = [
  # 需要计算阶段计算的值
  # RMMOVQ/MRMOVQ：valE = valC + valB，这里 valA/C “统一”
  # CALL/PUSH：valE = valB(RRSP) + 8
  M_icode in { IRMMOVQ, IPUSHQ, ICALL, IMRMOVQ } : M_valE;
  # 需要计算阶段不修改传递过来的值，即栈指针旧值
  # d_valA(RRSP) -> E_valA -> M_valA
  M_icode in { IPOPQ, IRET } : M_valA;
  # 其他指令不需要访存
];
# 是否读取内存
bool mem_read = M_icode in { IMRMOVQ, IPOPQ, IRET };
# 是否写入内存
bool mem_write = M_icode in { IRMMOVQ, IPUSHQ, ICALL };
```

</div>

<div>

![pipeline_memory_stage](/04-Arch2-Hierarchy/pipeline_memory_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：访存阶段

pipeline hcl: memory stage

<div grid="~ cols-2 gap-4">
<div>

```hcl
# 更新状态
word m_stat = [
  dmem_error : SADR; # 数据内存错误
  1 : M_stat; # 默认状态
];
```


</div>

<div>

![pipeline_memory_stage](/04-Arch2-Hierarchy/pipeline_memory_stage.png){.mx-auto}

</div>
</div>

---

# PIPELINE 的各阶段实现：写回阶段

pipeline hcl: writeback stage

<div grid="~ cols-2 gap-4">
<div>


```hcl
# W 阶段几乎啥都不干，单纯传递
# 设置 E 端口寄存器 ID
word w_dstE = W_dstE; # E 端口寄存器 ID
# 设置 E 端口值
word w_valE = W_valE; # E 端口值
# 设置 M 端口寄存器 ID
word w_dstM = W_dstM; # M 端口寄存器 ID
# 设置 M 端口值
word w_valM = W_valM; # M 端口值
# 更新处理器状态
word Stat = [
  # SBUB 全称 State Bubble，即气泡状态
  W_stat == SBUB : SAOK;
  1 : W_stat; # 默认状态
];
```


</div>

<div>

![pipeline_memory_stage](/04-Arch2-Hierarchy/pipeline_memory_stage.png){.mx-auto}

</div>
</div>

---

# 异常处理（气泡 / 暂停）：取指阶段

bubble / stall in fetch stage

注意：bubble 和 stall 不能同时为真。

```hcl
# 是否向流水线寄存器 F 注入气泡？
bool F_bubble = 0; # 恒为假
# 是否暂停流水线寄存器 F？
bool F_stall = 
  # 加载/使用数据冒险时，要暂停 1 个周期的译码，进而也需要暂停 1 个周期的取指
  E_icode in { IMRMOVQ, IPOPQ } && E_dstM in { d_srcA, d_srcB } ||
  # 当 ret 指令通过流水线时暂停取指，一直等到 ret 指令得到 W_valM
  IRET in { D_icode, E_icode, M_icode };

// 实际就是 F_stall = load_use_hazard || ret_hazard
```

<div grid="~ cols-2 gap-12" relative>
<div>

![load_use_hazard_solution_stall](/04-Arch2-Hierarchy/load_use_hazard_solution_stall.png){.mx-auto}

</div>

<div>

![control_hazard_ret_stall](/04-Arch2-Hierarchy/control_hazard_ret_stall.png){.mx-auto}

</div>
</div>

---

# 异常处理（气泡 / 暂停）：译码阶段

bubble / stall in decode stage

注意：bubble 和 stall 不能同时为真。


```hcl
# 是否暂停流水线寄存器 D？
# 加载/使用数据冒险
bool D_stall = E_icode in { IMRMOVQ, IPOPQ } && E_dstM in { d_srcA, d_srcB };
# 是否向流水线寄存器 D 注入气泡？
bool D_bubble = 
  # 分支预测错误
  (E_icode == IJXX && !e_Cnd) ||
  # 当 ret 指令通过流水线时暂停 3 次译码阶段，但要求不满足读取/使用数据冒险的条件
  !(E_icode in { IMRMOVQ, IPOPQ } && E_dstM in { d_srcA, d_srcB }) && IRET in { D_icode, E_icode, M_icode };
```

<div grid="~ cols-2 gap-12">
<div>

![control_hazard_jxx_bubble_1](/04-Arch2-Hierarchy/control_hazard_jxx_bubble_1.png){.mx-auto}

</div>

<div>

![control_hazard_ret_bubble](/04-Arch2-Hierarchy/control_hazard_ret_bubble.png){.mx-auto} 

</div>
</div>

---

# 异常处理（气泡 / 暂停）：执行阶段

bubble / stall in execute stage

注意：bubble 和 stall 不能同时为真。


```hcl
# 是否需要阻塞流水线寄存器 E？
bool E_stall = 0;
# 是否向流水线寄存器 E 注入气泡？
bool E_bubble = 
  # 错误预测的分支
  (E_icode == IJXX && !e_Cnd) || 
  # 负载/使用冒险条件
  (E_icode in { IMRMOVQ, IPOPQ } && E_dstM in { d_srcA, d_srcB });
```

<div grid="~ cols-2 gap-12">
<div>

![control_hazard_jxx_bubble_2](/04-Arch2-Hierarchy/control_hazard_jxx_bubble_2.png){.mx-auto}

</div>

<div>

![load_use_hazard_solution_bubble](/04-Arch2-Hierarchy/load_use_hazard_solution_bubble.png){.mx-auto}

</div>
</div>

---

# 异常处理（气泡 / 暂停）：访存阶段

bubble / stall in memory stage

注意：bubble 和 stall 不能同时为真。


```hcl
# 是否需要暂停流水线寄存器 M？
bool M_stall = 0;
# 是否向流水线寄存器 M 注入气泡？
# 当异常通过内存阶段时开始插入气泡
bool M_bubble = m_stat in { SADR, SINS, SHLT } || W_stat in { SADR, SINS, SHLT };
```

---

# 异常处理（气泡 / 暂停）：写回阶段

bubble / stall in writeback stage

注意：bubble 和 stall 不能同时为真。

```hcl
# 是否需要暂停流水线寄存器 W？
bool W_stall = W_stat in { SADR, SINS, SHLT };
# 是否向流水线寄存器 W 注入气泡？
bool W_bubble = 0;
```

---

# 特殊的控制条件

special control conditions

![special_condition](/04-Arch2-Hierarchy/special_condition.png){.mx-auto.h-50}

<div grid="~ cols-2 gap-8" text-sm>
<div>

组合 A：执行阶段中有一条不选择分支（预测失败）的跳转指令 `JXX`，而译码阶段中有一条 `RET` 指令。

即，`JXX` 指令的跳转目标 `valC` 对应的内存指令是一条 `RET` 指令。

</div>

<div>

组合 B：包括一个加载 / 使用冒险，其中加载指令设置寄存器 `%rsp`，然后 `RET` 指令用这个寄存器作为源操作数。

因为 `RET` 指令需要正确的栈指针 `%rsp` 的值去寻址，才能从栈中弹出返回地址，所以流水线控制逻辑应该将 `RET` 指令阻塞在译码阶段。

</div>
</div>

---

# 特殊的控制条件：组合 A

special control conditions: combination A

![combination_a](/04-Arch2-Hierarchy/combination_a.png){.mx-auto.h-40}


<div grid="~ cols-2 gap-12" text-sm>
<div>

组合情况 A 的处理与预测错误的分支相似，只不过在取指阶段是暂停。

当这次暂停结束后，在下一个周期，PC 选择逻辑会选择跳转后面那条指令的地址，而不是预测的程序计数器值。

所以流水线寄存器 F 发生了什么是没有关系的。

<div text-sky-5>

气泡顶掉了 `RET` 指令的继续传递，所以不会发生第二次暂停。

</div>


</div>

<div>


```hcl
# 指令应从哪个地址获取
word f_pc = [
  # 分支预测错误时，从增量的 PC 取指令
  # 传递路径：D_valP -> E_valA -> M_valA
  # 条件跳转指令且条件不满足时
  M_icode == IJXX && !M_Cnd : M_valA;
  # RET 指令终于执行到回写阶段时（即过了访存阶段）
  W_icode == IRET : W_valM;
  # 默认情况下，使用预测的 PC 值
  1 : F_predPC;
];
```

</div>
</div>

---

# 特殊的控制条件：组合 B

special control conditions: combination B


![combination_b](/04-Arch2-Hierarchy/combination_b.png){.mx-auto.h-40}


<div grid="~ cols-2 gap-12" text-sm>
<div>

对于取指阶段，遇到加载/使用冒险或 `RET` 指令时，流水线寄存器 F 必须暂停。

对于译码阶段，这里产生了一个冲突，制逻辑会将流水线寄存器 D 的气泡和暂停信号都置为 1。这是不行的。

<div text-sky-5>

我们希望此时只采取针对加载/使用冒险的动作，即暂停。我们通过修改 `D_bubble` 的处理条件来实现这一点。

</div>


</div>

<div>


```hcl
# 是否需要注入气泡至流水线寄存器 D
bool D_bubble =
  # 错误预测的分支 
  (E_icode == IJXX && !e_Cnd) || 
  # 在取指阶段暂停，同时 ret 指令通过流水线
  # 但不存在加载/使用冒险的条件（此时使用暂停）
  !(E_icode in { IMRMOVQ, IPOPQ } &&
   E_dstM in { d_srcA, d_srcB }) &&
  # IRET 指令在 D、E、M 任何一个阶段
  IRET in { D_icode, E_icode, M_icode };
```

</div>
</div>

---

# 一些记忆要点

tips

- `branch_mispred`：F 暂停，D 气泡，E 气泡
- `load_use_hazard`：F 暂停，D 暂停，E 气泡
- `ret_hazard`：F 暂停，D 气泡
- 组合情况直接列表出来现推即可，有且仅有 load_use + RET 和 branch_mispred + RET 两种组合
  - 可以想想为什么剩余组合不存在
- F 不会气泡，E 不会暂停


---

# 随机访问存储器

Random Access Memory, RAM

- 速度非常快
- **断电后数据不可恢复**
- 常用于运行时产生数据的存储

### 随机访问{.mb-4.mt-6}

- 指在存储设备中，可以以任意顺序访问存储的数据，而不需要按照特定的顺序逐个读取。
- 这种访问方式使得数据的读取和写入速度更快，尤其是在需要频繁访问不同位置的数据时。

---

# 随机访问存储器

Random Access Memory, RAM

<div grid="~ cols-2 gap-12">
<div>

### SRAM

Static RAM，静态随机访问存储器

- 速度最快（仅次于寄存器文件）
- 抗噪音干扰能力强，采用 **双稳态结构**{.text-sky-5}
- 价格最高（晶体管更多，造价更高）
- 常用于高速缓存

![sram](/04-Arch2-Hierarchy/sram.png){.h-40.mx-auto}

</div>

<div>

### DRAM

Dynamic RAM，动态随机访问存储器

- 对干扰非常敏感
- **需要不断地刷新以保持稳定性**{.text-sky-5}
- 速度慢于 SRAM，价格更低
- 多用于主存（内存）

![dram](/04-Arch2-Hierarchy/dram.png)

</div>
</div>

---

# DRAM 的读取

DRAM read

- 通过 address 引脚传入地址
- 在 DRAM 单元阵列中访存后通过 data 引脚输出数据
- 通常会重复利用 address 引脚进行二维访存

<div grid="~ cols-3 gap-12">
<div>

![dram_core](/04-Arch2-Hierarchy/dram_core.png){.h-100px.mx-auto}

DRAM 芯片{.text-center}

- 由 $r$ 行，$c$ 列个 DRAM 超单元组成（组织成二维阵列）
- 总共有 $d = r \times c$ 个超单元
- 总容量：$d \times w$ 位数据

</div>

<div>

![dram_supercell](/04-Arch2-Hierarchy/dram_supercell.png){.h-100px.mx-auto}

DRAM 超单元（SuperCell）{.text-center}

- 由 $w$ 个 DRAM 单元组成，携带 $w$ 位数据

</div>

<div>

![dram](/04-Arch2-Hierarchy/dram.png){.h-100px.mx-auto}

DRAM 单元（Unit）{.text-center}

- 每个 DRAM 单元携带 $1$ 位数据

</div>
</div>

---

# DRAM 的读取

DRAM read

1. 行缓冲区在传入行访问信号（RAS，Row Address Strobe，行地址选通）时复制一行内容，实现缓存
2. 传入列地址选通信号（CAS，Column Address Strobe，列地址选通），从行缓冲区中选出指定列的数据

二维访存：可以将原先需要 $m$ 位引脚的地址，拆分为两次 $m/2$ 位引脚的地址，即分别传入行地址和列地址

![dram_ras_cas](/04-Arch2-Hierarchy/dram_ras_cas.png){.mx-auto.h-60}

---

# DRAM 的读取

DRAM read

<div grid="~ cols-2 gap-12">
<div>

“8 个 8M x 8 的 64 MB 内存模块”

- 8 个 DRAM 芯片
- 每个芯片由 8M 个超单元组成
- 每个超单元携带 8 位（bit）数据
- 总容量：$8 \times 8M \times 8 \text{bit} = 64 \text{MB}$

可以利用相同的地址引脚，快速取出 64 位（bit）数据

（回忆：地址是超单元的地址）

</div>

<div>

![dram_example](/04-Arch2-Hierarchy/dram_example.png)

</div>
</div>

---

# 增强的 DRAM

Enhanced DRAM

重要！经常考选择题辨析。

<div grid="~ cols-2 gap-6" text-sm>
<div>

#### 快页存取DRAM

- Fast Page Mode DRAM（FPM DRAM）
- FPM DRAM 允许对同一行连续地址访问可以直接从行缓冲区得到服务{.text-sky-5}（从而减少 `RAS` 请求）。

</div>

<div>

#### 扩展数据输出DRAM

- Extended Data Out DRAM（EDO DRAM）
- FPM DRAM 的增强版
- 它允许 `CAS` 信号在时间上靠得更紧密一点

</div>

<div>

#### 同步DRAM

- Synchronous DRAM（SDRAM）{.text-sky-5}
- 使用同步控制信号（时钟上升沿），能更快速输出超单元内容。
- FPM 和 EDO DRAM 是异步控制。

![sdram](/04-Arch2-Hierarchy/sdram.png){.w-70.mx-auto}

</div>

<div>

#### 双倍数据速率同步DRAM

- Double Data-Rate Synchronous DRAM（DDR SDRAM）
- SDRAM 的增强版本，通过使用两个时钟沿（同时使用上升沿和下降沿）作为控制信号
- 使得 DRAM 速度翻倍

![ddrm](/04-Arch2-Hierarchy/ddrm.png){.w-70.mx-auto}

</div>
</div>

省流：全都是 DRAM 的增强版，和 SRAM 没有关系。

---

# ROM

Read-Only Memory

只读存储器（非易失性存储器）

- 断电后仍然能保存数据
- 常用于数据的持久性存储
- 常见：闪存
- SSD 基于闪存

---

# 磁盘存储

Disk Storage

- 非易失性存储器，断电后数据不丢失
- 容量数量级：GB~TB
- 访问时间：ms 级别

---

# 磁盘结构

Disk Structure

![disk_structure](/04-Arch2-Hierarchy/disk_structure.png){.mx-auto.h-60}

- 磁盘：由多个盘片构成，每个盘片有 2 个可读写面
- 磁道：盘片表面同一半径的圆周，每个盘面有多个磁道
- 扇区：磁道被划分成一段段数据块
- 柱面：**所有盘片** 的同一半径磁道集合

---

# 磁盘容量

Disk Capacity

容量公式：

<div class="text-sm">

$$
\text{磁盘容量} = \text{每个扇区字节数} \times \text{每个磁道平均扇区数} \times \text{每个表面磁道数} \times \text{每个盘片表面数(2)} \times \text{盘片数}
$$

</div>

衍生概念：

- 记录密度：磁道一英寸能放的位数
- 磁道密度：从圆心出发半径一英寸能有多少条磁道
- 面密度：记录密度 × 磁道密度

---

# 多区记录

Multi-Zone Recording

<div grid="~ cols-2 gap-4">
<div>

### 传统方法

每个磁道都划分为相同数量的扇区，则：

- 扇区数目是由最内磁道决定的
- 外周磁道会有很多空隙



</div>

<div>


### 多区记录方法

- 将柱面划分为若干组
- 每组内部采用相同的扇区数，不同组间扇区数可不同
- 能有效利用空间

</div>

![disk_traditional](/04-Arch2-Hierarchy/disk_traditional.svg){.mx-auto.h-40}

![disk_multi_zone](/04-Arch2-Hierarchy/disk_multi_zone.svg){.mx-auto.h-40}
</div>

---

# 计量单位

Unit of measurement

<div grid="~ cols-2 gap-12">
<div>


DRAM 和 SRAM 容量相关计量单位：

- K = $2^{10}$
- M = $2^{20}$
- G = $2^{30}$
- T = $2^{40}$

</div>

<div>


磁盘和网络等 I/O 设备容量计量单位：

- K = $10^3$
- M = $10^6$
- G = $10^9$
- T = $10^{12}$

</div>
</div>

省流版本：

- 内存（含）及以上（更快），使用 2 的幂次作为单位{.text-sky-5}
- 磁盘及以下（更慢），使用 10 的幂次作为单位{.text-sky-5}

---

# 磁盘读写

Disk Read/Write

传动臂末端具有读写头，通过以下步骤进行读写：

1. **寻道**：通过旋转将读写头移动到对应磁道上（$T_{\text{seek}}$）
2. **旋转**：等待对应扇区开头旋转到读写头位置（$T_{\text{rotate}}$），最差情况为 $\frac{1}{\text{RPM}} \times 60 \text{s/min}$，接近于寻道时间
3. **传送**：开始读写，每个扇区的平均传送速率（$T_{\text{transfer}}$），一般可忽略

<div grid="~ cols-2 gap-12">
<div>

![disk_seek](/04-Arch2-Hierarchy/disk_seek.png){.h-40.mx-auto}

<div text-center>

寻道时间：$T_{\text{seek}}$

</div>

</div>

<div>

![disk_rotate](/04-Arch2-Hierarchy/disk_rotate.png){.h-40.mx-auto}

<div text-center> 

旋转时间：$T_{\text{rotate}}$

</div>

</div>

</div>

---

# SSD 固态硬盘

Solid State Disk

固态硬盘（Solid State Disk，SSD）是一种基于闪存的存储技术，是传统旋转磁盘的替代产品。

SSD 价格贵于旋转磁盘。

<div grid="~ cols-2 gap-12">

<div>

#### SSD 层级结构{.my-4}

- SSD，闪存由多个闪存块组成
- 闪存块（Block），$0 \sim B-1$，每个块包含多个闪存页
- 闪存页（Page），$0 \sim P-1$，每个页包含 512B～4KB 数据


</div>

<div>

![ssd](/04-Arch2-Hierarchy/ssd.png)

</div>

</div>

---

# SSD 读写特性

SSD Read/Write Characteristics 

- 速度：读 > 写，顺序访问 > 随机访问
- 数据以页为单位读写，页所在块必须先擦除再写入（全部置为 1）{.text-sky-5}
- 写操作前需复制 **页内容** 到 **新块** 并 **擦除旧块**
- 一旦一个块被擦除了，块中每一个页都可以不需要再进行擦除就写一次
- 每个块在反复擦除后会磨损乃至损坏（约 100,000 次），需要通过闪存翻译层管理，以最小化擦除次数


![ssd](/04-Arch2-Hierarchy/ssd.png){.h-60.mx-auto}
---

# 局部性

Locality

**局部性**：程序倾向于引用最近引用过的数据项的邻近的数据项，或者最近引用过的数据项本身。

- **空间局部性**：相邻位置的变量被集中访问（最近引用过的数据项及其邻近数据项）
- **时间局部性**：同一变量在短时间内被重复访问（最近引用过的数据项本身）

注意，指令也是数据的一种，因此指令也有局部性。


---

# 步长与引用模式

stride and reference pattern

- **步长为 $k$ 的引用模式**：每隔 $k$ 个元素访问一次，**步长越短，空间局部性越强。**{.text-sky-5}（行优先访问好于列优先访问）
- **指令的局部性**：指令按顺序执行，例如 `for` 循环，具有良好的时间（循环体、循环变量复用）和空间局部性（循环体内指令连续）。

循环次数越多越好，循环体越小越好

---

# 存储器层次结构

Memory Hierarchy

<div grid="~ cols-2 gap-12">
<div>

- 越靠近 CPU 的存储器，速度越快，单位比特成本越高，容量越小
- 越远离 CPU 的存储器，速度越慢，单位比特成本越低，容量越大

通常，我们使用 $L_k$ 层作为 $L_{k+1}$ 层的缓存

如果我们要在 $L_{k+1}$ 中寻找数据块 $a$，我们首先应该在 $L_k$ 中查找。

- **缓存命中**：如果能找到，我们就不必访问 $L_{k+1}$
- **缓存不命中**：如果找不到，我们才去访问 $L_{k+1}$（那就要花较长时间来复制了）


</div>

<div>

![memory_hierarchy](/04-Arch2-Hierarchy/memory_hierarchy.png)

</div>
</div>


---

# 存储器层次习题

Questions

某磁盘的旋转速率为 7200RPM，每条磁道平均有 400 扇区，则一个扇区的平均传送时间为

- A. 0.02 ms
- B. 0.01 ms
- C. 0.03 ms
- D. 0.04ms


---

# 存储器层次习题

Questions

<div class="text-sm">

以下关于存储的描述中，正确的是？

- A. 由于基于 SRAM 的内存性能与 CPU 的性能有很大差距，因此现代计算机使用更快的基于 DRAM 的高速缓存，试图弥补 CPU 和内存间性能的差距。
- B. SSD 相对于旋转磁盘而言具有更好的读性能，但是 SSD 写的速度通常比读的速度慢得多，而且 SSD 比旋转磁盘单位容量的价格更贵，此外 SSD 底层基于 EEPROM 的闪存会磨损。
- C. 一个有 2 个盘片、10000 个柱面、每条磁道平均有 400 个扇区，每个扇区有 512 个字节的双面磁盘的容量为 8GB。
- D. 访问一个磁盘扇区的平均时间主要取决于寻道时间和旋转延迟，因此一个旋转速率为 6000RPM、平均寻道时间为 9ms 的磁盘的平均访问时间大约为 19ms。
- E. SDRAM 兼具 SRAM 和 DRAM 的特点。

</div>


---

# 存储器层次习题

Questions

<div>

（24 期中）以下关于存储设备的说法正确的是：

A. SRAM 是双稳态的，只要有电就能保持它的值，所以是非易失性存储器

B. DRAM 每单元所需的晶体管数比 SRAM 少，所以 DRAM 速度一定比 SRAM 更快

C. 随机读写时，SSD 无需像旋转磁盘一样进行多次寻道操作，一般速度更快

D. SSD 有速度快、耗能低等优点，所以任何情况下都应使用 SSD 而不是旋转磁盘

</div>

---

# 存储器层次习题

Questions

（24 期中）考虑一个有 $x$ 个盘片，每个扇区 $y$ 字节，每个面 $z$ 条磁道，每条磁道平均 $w$ 个扇区，旋转速率 $a$ RPM，平均寻道时间 $b$ ms 的磁盘。则下列说法正确的是： 

A. 磁盘容量为 $2wxyz / 2^{30}$ GB

B. 访问一个磁盘扇区内容的平均时间为 $(60/a \times 1000 + 60/a/w \times 1000 + b)$ ms

C. 访问一个磁盘扇区中 $512$ 个字节的时间主要是寻道时间和传送时间

D. 假设旋转速率未知，在通常情况下我们可以简单估计 $a = 60/b \times 1/2 \times 1000$ RPM


---
layout: cover
class: text-center
coverBackgroundUrl: /04-Arch2-Hierarchy/cover.png
---

# Thank you for your listening!


Cat$^2$Fish❤

<style>
  div{
   @apply text-gray-2;
  }
</style>
