---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: bg.jpg
# some information about your slides (markdown enabled)
title: "05-Cache-ProgOptim"
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
coverBackgroundUrl: /05-Cache-ProgOptim/cover.jpg
---

# Cache & Program Optimization

Taoyu Yang, EECS, PKU

<style>
  div{
   @apply text-gray-2;
  }
</style>


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

![memory_hierarchy](/05-Cache-ProgOptim/memory_hierarchy.png)

</div>
</div>

<!--
那么不命中的话，就要从 $L_{k+1}$ 取出，如果 $L_k$ 满了就涉及到驱逐的问题。
-->

---

# 缓存替换策略

Cache Replacement Policy

如果缓存已满，我们需要决定替换 / 驱逐哪个现有块（要腾地方）。

<div grid="~ cols-3 gap-12" mt-8>
<div>

### 最近最少使用

- LRU（Least Recently Used）
- 替换最后一次访问时间最久远的行

</div>

<div>

### 最不常使用

- LFU（Least Frequently Used）
- 替换过去某个时间窗口内引用次数最少的行


</div>

<div>

### 随机替换

- 随机选择一个块进行替换

</div>

</div>

LRU 不一定比随机替换好。具体哪个策略好，还取决于数据分布。{.text-sky-5}

---

# 缓存不命中的类型

Cache Miss Types

- **冷不命中 / 强制性不命中**：数据块从未进入缓存，短暂性，在 **暖身** 后不会出现
- **冲突不命中**：由于冲突性放置策略的存在，缓存块的预期位置被其他数据块占据（但是实际上放得下，工作集小于缓存容量）
- **容量不命中**：与冲突性放置策略无关，工作集大于缓存容量，怎么摆都放不下

![miss](/05-Cache-ProgOptim/miss.svg)

---

# 抖动

Thrashing

**抖动**：当多个数据频繁被访问，但它们无法同时全部放入缓存时，系统不断地在缓存和主存之间进行的频繁数据替换。

![thrashing](/05-Cache-ProgOptim/thrashing.svg){.mx-auto.h-60}

一共只有 4 个位置，但是要放 5 个数据，还都要用，只能不断替换。{.text-center}


---

# 缓存组织结构

Cache Organization

<div grid="~ cols-2 gap-12">
<div text-sm>

一个计算机系统，其中每个存储器地址有 $m$ （<span text-sky-5>m</span>emory）位，从而形成 $M=2^m$ 个不同的地址。

- 高速缓存被组织成一个有 $S=2^s$（<span text-sky-5>s</span>et）个高速缓存组的数据组。
- 每个组包含 $E$（lin<span text-sky-5>e</span>）个高速缓存行。
- 每行包含一个 $B=2^b$ （<span text-sky-5>b</span>lock）字节的数据块。

每个行有：

- 有效位（valid bit）：1 位，标明该行是否包含有意义的信息
- 标记位（tag bit）：$t=m-(b+s)$ 位，用于标识存储在该高速缓存行中的地址
- 数据块：$B=2^b$ 字节，存储实际数据

总容量（<span text-sky-5>C</span>apacity）：$C=B \times E \times S$ 字节，不包括标记位和有效位 



</div>

<div>

![cache_arch](/05-Cache-ProgOptim/cache_arch.png)

</div>
</div>

---

# 缓存地址划分

Cache Address Division

<div grid="~ cols-2 gap-12">
<div>

1 个地址，总共有 $m$ 位，从 **高位到低位** 划分如下：

- 标记位：$t$
- 组索引：$s$
- 块偏移：$b$

> - 小写符号是位数
> - 大写符号是位数对应的 2 的幂次，代表一个总数。



</div>

<div>

![cache_address](/05-Cache-ProgOptim/cache_address.png)

</div>
</div>

---

# 缓存寻址过程

Cache Addressing Process

<div grid="~ cols-2 gap-12">
<div>



当一条加载指令 $A$ 访问存储地址 $A$ 时：

1. **组选择**：根据地址 $A$ 的 **组索引位**，找到对应的组。
2. **行匹配**：检查该组内是否有 **有效位有效** 且 **标记位匹配** 的缓存行。
3. **字抽取**：若存在匹配行，则命中缓存，返回该行数据；
4. **行替换**：否则，发生缓存不命中，选择一个现有的行/块驱逐，从低一级存储器中读取新数据放入缓存。

</div>

<div>



![cache_set_index](/05-Cache-ProgOptim/cache_set_index.png)

![cache_byte_index](/05-Cache-ProgOptim/cache_byte_index.png)

</div>
</div>

---

# 缓存地址划分

Cache Address Division

<div grid="~ cols-2 gap-12">
<div>

为什么划分设计成这样？

1. 块偏移：我们肯定希望 **两个相连的字节在同一个块内**（块是数据交换的最小单位），这样空间局部性更好。从而我们将最低的 $b$ 位作为块偏移。
2. 组索引：我们希望 **相邻的块可以放在不同的组内**，从而减少冲突不命中。从而我们将接下来的 $s$ 位作为组索引。
3. 标记：利用地址的唯一性，我们将剩下的 $t$ 位作为标记，用以区分分在同一组的各个块。


</div>

<div>


![cache_set_index_pos](/05-Cache-ProgOptim/cache_set_index_pos.png)

<div text-center text-sm>

此图中，除外了地址的最低 $b$ 位。

</div>

</div>
</div>

---

# 不同的缓存组织结构

Different Cache Organization

<div grid="~ cols-3 gap-x-8" text-sm>
<div>

#### 直接映射高速缓存

- $E=1$
- 每个组仅有一行
- 不止 1 个组
- 最容易发生冲突不命中
- 硬件最简单（只需匹配 1 次 Tag）

</div>

<div>

#### 组相联高速缓存

- $1 < E < C/B$
- 每个组有多行
- 不止 1 个组
- <span text-sky-5> $E$ 称为路数（$E$ 路组相联） </span>

</div>
<div>

#### 全相联高速缓存

- <span text-sky-5> $E=C/B$ </span>
- 1 个组拥有所有行
- 只有 1 个组，$s=0$
- 所有行可以任意放置，最灵活，最不易发生冲突不命中
- 硬件最复杂（需要匹配 Tag 数最多）

</div>



![cache_direct_mapped](/05-Cache-ProgOptim/cache_direct_mapped.png){.w-60}

![cache_set_associative](/05-Cache-ProgOptim/cache_set_associative.png){.w-60}

![cache_fully_associative](/05-Cache-ProgOptim/cache_fully_associative.png){.w-60}

</div>

---

# 高速缓存读写策略

Cache Read / Write Policy

<div grid="~ cols-2 gap-12">
<div>


### 写命中

写命中：当数据在缓存中时，写操作的策略。

- 写回（Write Back）：写在缓存，直到被替换的时候再写到下层存储器<br><span class="text-sm text-gray-5">（需要额外的 1 位 dirty bit 来标识缓存中数据是否被修改）</span>
- 直写（Write Through）：写缓存的同时直接写到下层存储器

</div>

<div>


### 写不命中

写不命中：当数据不在缓存中时，写操作的策略。

- 写分配（Write Allocate）：写下层存储器的同时加载到缓存
- 非写分配（Not Write Allocate）：只写到下层存储器，不改变缓存


</div>
</div>

高速缓存层次结构中，下层一般采用写回。

常见搭配：写回+写分配（效率高，因为试图利用局部性，可以减少访存次数），直写+非写分配

<!-- 内存是个不准确的概念，实际上是下层存储器 -->

---

# 高速缓存参数的性能影响

Cache Parameter Performance Impact

高速缓存大小（$C$）：
- 高速缓存越大，命中率越高
- 高速缓存越大，命中时间也越高，运行相对更慢

块大小（$B$）：
- 块大小越大，空间局部性越好
- 块大小越大，时间局部性可能会变差，因为容量不变时，块越大，高速缓存行数（$E$）可能就会越少，损失时间局部性带来的命中率，不命中处罚大

---

# 高速缓存参数的性能影响

Cache Parameter Performance Impact

相联度（$E$）：
- $E$ 较高，降低冲突不命中导致抖动的可能性，因为下层存储器的不命中处罚很高，所以下层存储器的相联度往往更高，因为此时降低冲突不命中带来的收益很高
- $E$ 越高，复杂性越高、成本越高
- $E$ 越高，不命中处罚越高。因为高相联度缓存的替换策略（如 LRU）更复杂，导致在缓存未命中时，找到一个合适的缓存行来替换会花费更多时间
- $E$ 增高，可能需要更多标记位（$t \geq \log_2 E$）、LRU 状态位
- 原则是命中时间和不命中处罚的折中{.text-sky-5}

---

# 高速缓存参数的性能影响

Cache Parameter Performance Impact

写策略：
- 直写高速缓存容易实现
- 写回高速缓存引起的传送较少
- 一般而言，高速缓存越往下层，就越可能使用写回（因为直写无论如何都需要写到下层存储器，这是相对较慢（昂贵）的操作）

---

# 存储器山

Memory Hill

![memory_hill](/05-Cache-ProgOptim/memory_hill.png){.h-100.mx-auto}

---

# 存储器山：空间局部性

Memory Hill: Spatial Locality

<div grid="~ cols-3 gap-4">
<div>

**步长（stride）对性能的影响**：

- 小步长访问数据时，空间局部性好，缓存命中率高，带宽利用率高。
- 步长增加时，访问数据的空间局部性下降，缓存命中率降低，带宽利用率下降，吞吐量降低。

</div>

<div col-span-2>

![memory_hill_spatial_locality](/05-Cache-ProgOptim/memory_hill_spatial_locality.png)

</div>
</div>

---

# 存储器山：时间局部性

Memory Hill: Temporal Locality

<div grid="~ cols-3 gap-4">
<div>

**工作集大小对性能的影响**：

- 小工作集大小时，数据可以更容易地装入上级存储器缓存，缓存命中率高，时间局部性好。
- 工作集大小增加时，如果工作集超过某一级缓存容量，导致更多的数据需要从更低层次的存储中读取，传输速率下降，吞吐量降低，缓存命中率低，时间局部性差。

</div>

<div col-span-2>

![memory_hill_temporal_locality](/05-Cache-ProgOptim/memory_hill_temporal_locality.png)

</div>
</div>

---

# 存储器山：预取

Memory Hill: Prefetch

<div grid="~ cols-3 gap-4">
<div>

**预取（prefetching）**：指在数据块被实际访问之前，提前将其加载到高速缓存中。


- 自动识别顺序的、步长为 1 的引用模式
- 提前将数据块取到高速缓存中，减少访问延迟
- 提高读吞吐量，特别是在步长较小的情况下效果最佳

</div>

<div col-span-2>

![memory_hill_prefetch](/05-Cache-ProgOptim/memory_hill_prefetch.png)

</div>
</div>

---

# 矩阵乘法


<div grid="~ cols-2 gap-12">
<div>

```c
# ijk
for (i = 0; i < n; i++)
  for (j = 0; j < n; j++) {
    sum = 0.0;
    for (k = 0; k < n; k++)
      sum += A[i][k] * B[k][j];
    C[i][j] += sum;
  }

# jki
for (j = 0; j < n; j++)
  for (k = 0; k < n; k++) {
    r = B[k][j];
    for (i = 0; i < n; i++)
      C[i][j] += A[i][k] * r;
  }

# kij
for (k = 0; k < n; k++)
  for (i = 0; i < n; i++) {
    r = A[i][k];
    for (int j = 0; j < n; j++)
      C[i][j] += r * B[k][j];
  }
```
</div>
<div>


```c
# jik
for (j = 0; j < n; j++)
  for (i = 0; i < n; i++) {
    sum = 0.0;
    for (k = 0; k < n; k++)
      sum += A[i][k] * B[k][j];
    C[i][j] += sum;
  }

# kji
for (k = 0; k < n; k++)
  for (j = 0; j < n; j++) {
    r = B[k][j];
    for (i = 0; i < n; i++)
      C[i][j] += A[i][k] * r;
  }

# ikj
for (i = 0; i < n; i++)
  for (k = 0; k < n; k++) {
    r = A[i][k];
    for (int j = 0; j < n; j++)
      C[i][j] += r * B[k][j];
  }
```


</div>
</div>

---

# 矩阵乘法

Matrix Multiplication

- 可以按每次内循环迭代访问的矩阵分成三个等价类：AB, AC, BC
- 假设每个数组是 `double` 的，且只有一个高速缓存，块大小为 $32$，且数组足够大到矩阵的一行都无法放进 L1-cache 中。
- 假设编译器将局部变量保存在寄存器中（这样就不需要访存了）

- 分析一下每次迭代有会发生几次未命中？
  
---

# 矩阵乘法：结论

conclusion

- 对于 AB 型，每轮 $A$ 不命中 0.25 次，$B$ 不命中 1 次，一共是 1.25 次。
- 对于 AC 型，每轮 $A, C$ 均不命中 1 次，一共是 2 次。
- 对于 BC 型，每轮 $B,C$ 均不命中 0.25 次，一共是 0.5 次。

<br>

- 根据书上的实验结果，我们发现 AC 型的显著劣，而 BC 的是最优的。
- 对于足够大的 $n$，运算效率可以相差高达 40 倍
- 对于大的 $n$，由于**预取**机制，性能基本保持不变。

---

# 程序优化

Program Optimization

- 本章主要关注优化处理器执行程序的性能（Performance）
- 而不是优化程序的时间复杂度
  - 例如排序：冒泡排序 $O(n^2)$ 与快排 $O(n)$
- 而是想办法让处理器执行程序的速度更快
  - 例如减少函数调用/提升指令并行度……
  - 实际上是在做**常数优化**
- 常数也可以产生很大的影响！
  - 例如矩阵乘法，实现得不好的可能会慢上几十倍！

---

# 机器无关优化

target-independent

- 一句话原则：**只要有出错的可能就不做优化**
  - 不能改变程序的行为
  - 保守
- 代码移动（识别要执行多次但计算结果不会改变的计算）
  - 例如字符串的 `strlen`，$O(n^2)$？
- 减少过程调用
- 消除不必要的内存引用
  - 访存还是很耗时的

---

# 理解现代处理器

modern CPU

- 延迟、发射时间、容量、吞吐率
  - 辨析概念，书本 p361
- 数据流图与关键路径
  - 理解循环展开的关键
- $k\times k$ 循环展开：$k$ 路，$k$ 个累积变量。
- 循环展开的路数越多不一定效果越好。

---
layout: center
---

# 复习小练习

---
layout: cover
class: text-center
coverBackgroundUrl: /05-Cache-ProgOptim/cover.jpg
---

# Thank you for your listening!


Cat$^2$Fish❤

<style>
  div{
   @apply text-gray-2;
  }
</style>
