---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: bg.jpg
# some information about your slides (markdown enabled)
title: "11-Synchronization"
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
coverBackgroundUrl: /11-SYNC/cover.jpg
---

# 同步

Synchronization

<style>
  div{
   @apply text-gray-2;
  }
</style>

---

# 一些杂事

misc

- 注意 Proxy Lab 明晚截止，~~实在搞不定咱要不先 claude/codex 一波带走得了~~
- 考试时间是下周一（12.29 下午），时间非常紧，大家尽量安排时间进行复习
  - ~~每年都是考试周第一天考，但大家考完就可以解放了~~
- 今天的课件看似只有 31 页但内容一点都不简单，可以说这节内容是第 12 章最难的地方，请大家尽量认真听课，有跟不上的地方请随时打断
- 最后一节小班课了，大家一路走来辛苦了

---

# 同步

Synchronization

**竞争**：多个线程同时访问 / 修改共享资源，可能会引发一些问题

- 原因：线程共享地址空间，不同线程可能同时操作同一变量

**原子**：一旦开始就无法被打断的操作

- 一行代码可能翻译成若干行汇编代码，例: `i++` 翻译成汇编 `mov, add, mov`，一般的变量不具有原子性

**死锁**：线程竞争可能导致的一种问题

- A 进行操作 a 的前提是 B 进行操作 b, B 进行操作 b 的前提是 A 进行操作 a
- 例: 开门的钥匙被锁在门里面
- **判断**：进度图 + 临界区

<!--
这一页讲慢一点，给大家看一下badcnt的例子。一个循环有 $H_i$（头）、$L_i$（load），$U_i$（update），$S_i$（save）和 $T_i$（tail）。如果多个线程执行的时候有 L L U U 的情况，显然 cnt 更新的结果就不对了。

操作共享变量 `cnt` 内容的指令 $(L_i,U_i,S_i)$ 构成了一个（关于共享变量 `cnt` 的）临界区。临界区不应该和其他线程的临界区交错执行。我们希望一个线程在临界区里面有对共享变量的互斥访问。
-->

---

# 信号量

Semaphore

**信号量**：一种具有 **非负整数值的全局变量**{.text-sky-5}，只能由两种特殊的操作处理（P 和 V）。

其目的是 **保证互斥访问**，从而保证线程化程序正确执行，禁止不安全的执行轨迹。

<div grid="~ cols-2 gap-12">
<div>

#### `P(s)` 操作

如果 $s$ 是非零的，那么 P 将 $s$ 减 1，并且立即返回。

1. 如果 $s$ 为零，则 **挂起线程**{.text-sky-5}，直到 $s$ 变为非零，并且该线程被一个 V 操作重启。
2. 在重启之后，P 操作将 $s$ 减 1，并将控制返回给调用者。

</div>

<div>

#### `V(s)` 操作

V 操作将 $s$ 加 1，若会导致超过上限，则无事发生

如果有任何线程阻塞在 P 操作等待 $s$ 变成非零，那么 V 操作会唤醒等待队列中的某一个线程，**具体哪个由实现/调度策略决定，不保证公平**，然后该线程将 $s$ 减 1，完成它的 P 操作。

V 操作是 **非阻塞**{.text-sky-5} 的，有没有 P 在等对 V 无所谓。

</div>
</div>

**一个计数信号量只能直接表达一种“资源计数不为负”的约束（比如“空槽数不为负”或“已有元素数不为负”）。想同时保证“不溢出 + 不下溢”，通常需要两个计数信号量（empty/full）再配一个 mutex**

<!--
在这一页画一下课本703页的图12-12。注意禁止区是包在不安全区的外面的，所以不可能进入不安全区。
-->

---

# 信号量使用注意事项

Semaphore usage notes

**P 的顺序很重要（不合适的话可能引发死锁）**

原因：P 操作要求信号量 $s > 0$，这一条件不一定总成立

**V 的顺序无所谓（虽然顺序不合适可能导致效率问题，但是不会死锁）**

原因：V 操作没有前提要求，只是给信号量 $s + 1$，总是能进行的

**死锁**

- 简单粗暴地判断：两个线程, 一个先 $P(A)$ 后 $P(B)$，一个先 $P(B)$ 后 $P(A)$，（中间无释放，没有用其他信号量分隔），必然死锁
- 若 $P$ 操作持有顺序和 $V$ 操作释放顺序倒序，即构成 $P(s_1) \to P(s_2) \to V(s_2) \to V(s_1)$，则一般不会死锁
- 对于使用二元信号量来实现互斥时，**互斥锁加锁顺序原则**：给定所有互斥操作的一个全序，如果每个线程都是以一种顺序获得互斥锁并以相反的顺序释放，那么这个程序就是无死锁的。

---

# 用信号量解决竞争

Use semaphore to solve race condition

```c
volatile long cnt = 0;  /* 计数器 */
sem_t mutex;            /* 保护计数器的信号量 */

Sem_init(&mutex, 0, 1); /* 初始化信号量，初值为1 */

for (i = 0; i < niters; i++) {
    P(&mutex);          /* 加锁 */
    cnt++;
    V(&mutex);          /* 解锁 */
}
```

实际上是通过信号量 `mutex` 来约束了同时访问 `cnt` 的线程数量 $\leq 1$，即保证了同一时间最多只有一个线程访问 `cnt`。

实际上因为这个数量必然非负，从而约束了两端。

`cnt` 使用 `volatile` 修饰，确保每次操作它时都是最新的。

---

# 用信号量解决竞争

Use semaphore to solve race condition




#### 生产者-消费者问题{.font-bold.mb-4}

1. 生产者制造出产品，放进缓冲区
2. 消费者从缓冲区拿出产品，进行消费
3. 当缓冲区满，生产者无法继续；当缓冲区空，消费者不能继续

#### 读者-写者问题{.font-bold.my-4}

1. 一本书，有若干读者和若干写者可能访问它
2. 只要有一个写者在访问，任意其他读者/写者都不能进入
3. 只要有若干个读者在访问，任意写者都不能进入，但是其他读者可以进入



---

# 生产者消费者问题

Producer-consumer problem

<div grid="~ cols-3 gap-6">
<div col-span-2>

```c{all|32,34,42,49|32,38,42,45|32,42,35-37,46-48|all}{maxHeight: '400px',lines: true}
#include "csapp.h"
#include "sbuf.h"

typedef struct {
    int *buf;    /* 缓冲区数组 */
    int n;       /* 最大槽数 */
    int front;   /* buf[(front+1)%n] 是第一个项目 */
    int rear;    /* buf[rear%n] 是最后一个项目 */
    sem_t mutex; /* 保护对缓冲区的访问 */
    sem_t slots; /* 计算可用槽数 */
    sem_t items; /* 计算可用项目数 */
} sbuf_t;

/* 创建一个空的、有界的、共享的 FIFO 缓冲区，具有 n 个槽 */
void sbuf_init(sbuf_t *sp, int n)
{
    sp->buf = Calloc(n, sizeof(int)); /* 缓冲区最多容纳 n 个项目 */
    sp->n = n;
    sp->front = sp->rear = 0;   /* 如果 front == rear，缓冲区为空 */
    Sem_init(&sp->mutex, 0, 1); /* 用于锁定的二进制信号量 */
    Sem_init(&sp->slots, 0, n); /* 初始时，缓冲区有 n 个空槽 */
    Sem_init(&sp->items, 0, 0); /* 初始时，缓冲区没有数据项 */
}

/* 清理缓冲区 sp */
void sbuf_deinit(sbuf_t *sp)
{
    Free(sp->buf);
}

/* 将项目插入共享缓冲区 sp 的尾部 */
void sbuf_insert(sbuf_t *sp, int item)
{
    P(&sp->slots);                        /* 等待可用的槽 */
    P(&sp->mutex);                        /* 锁定缓冲区 */
    sp->buf[(++sp->rear)%(sp->n)] = item; /* 插入项目 */
    V(&sp->mutex);                        /* 解锁缓冲区 */
    V(&sp->items);                        /* 通知有可用项目 */
}

/* 移除并返回缓冲区 sp 中的第一个项目 */
int sbuf_remove(sbuf_t *sp)
{
    int item;
    P(&sp->items);                        /* 等待可用项目 */
    P(&sp->mutex);                        /* 锁定缓冲区 */
    item = sp->buf[(++sp->front)%(sp->n)];/* 移除项目 */
    V(&sp->mutex);                        /* 解锁缓冲区 */
    V(&sp->slots);                        /* 通知有可用槽 */
    return item;
}
```

</div>

<div relative>
<div :class="$clicks<=4 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute>

<v-clicks at="1">

1. 使用 `slots` 信号量的非负性，约束了缓冲区中项目数量 $\leq n$
2. 使用 `items` 信号量的非负性，约束了缓冲区中项目数量 $\geq 0$
3. 使用 `mutex` 信号量，约束了对全局变量缓冲区的访问

`slots` 维护了**空槽**的数量，`items` 维护了项目的数量，`mutex` 是把锁。

一般技巧：对于几个限制就用几个信号量。因为一个信号量只能管一边。

思考：为什么不能先 P(mutex) 后 P(slots)/P(items)?

</v-clicks>

</div>
<div :class="$clicks>=5 ? 'opacity-100' : 'opacity-0'" transition duration-400 absolute>

设 $p$ 表示生产者数量，$c$ 表示消费者数量，而 $n$ 表示以项目单位为单位的缓冲区大小。对于下面的每个场景，指出 `sbuf_insert` 和 `sbuf_remove` 中的互斥锁信号量是否是必需的。

1. $p = 1, c = 1, n > 1$
2. $p = 1, c = 1, n = 1$
3. $p > 1, c > 1, n = 1$

<div class="text-sm">

<v-click at="6">

答案：

1. 不需要（标答有误）
2. 不需要
3. 不需要

</v-click>

</div>

</div>
</div>
</div>

<!--
先带大家看一遍这个代码，这个是一个循环队列的结构，维护了头和尾。

把 P 操作理解成，进入这个动作需要获取什么资源。比如说对于 insert，就是需要可用的槽，所以要 P(slots)。对于 remove，需要槽里面有 item，所以要 P(items)。

把 V 操作理解成，我释放了什么，使得别人可用继续。对于 insert，是“释放”了一个可用的 item，所以 V(items)，对于 remove，释放了一个空槽，生产者可以继续往里面放东西，所以 V(slots)。

如果生产者先 P(mutex) 后 P(slots)，那么假设生产者拿到了互斥锁，然后被阻塞在 P(slots)（没有空的槽，需要等消费者释放），但是消费者又被互斥锁卡着，也没法释放。所以死锁。对于消费者先 P(mutex) 后 P(items) 是同一个道理。

大家把 P(slots) 理解为“拿到资格”，P(mutex) 理解为“进门”。**先拿资格再进门**，不要在持有互斥锁的情况下做可能阻塞的操作。

全是不必要。

对于一个消费者和一个生产者的情况，不会出现两个插入改 rear 和两个删除改 front 的竞争。insert 和 remove 改到 `rear == front` 的情况当且仅当槽满或者槽空，但是这种情况一定有一方被 P(slots) 或者 P(items) 卡住。所以 mutex 在这个场景没有必要。

对于只有一个槽的情况，和刚才的道理类似，同一时刻最多有一个生产者通过 P(slots) 进入插入过程，最多有一个消费者通过 P(items) 进入删除过程。而且 `slots + items = 1`，所以这两者不可能同时进入临界区，所以 mutex 也是没有必要的
-->

---

# 第一类读者写者问题

First type of reader-writer problem

<div grid="~ cols-2 gap-8">
<div>

```c{all|7,25|8,12,15,19|11,18,26,29|10-11,17-18|all}{maxHeight: '400px',lines: true}
/* 全局变量 */
int readcnt;         /* 初始值 = 0 */
sem_t mutex, w;      /* 两者初始值均为 1 */

void reader(void)
{
    while (1) {
        P(&mutex);
        readcnt++;
        if (readcnt == 1) /* 第一个进入 */
            P(&w);
        V(&mutex);
        /* 临界区 */
        /* 读取操作 */
        P(&mutex);
        readcnt--;
        if (readcnt == 0) /* 最后一个离开 */
            V(&w);
        V(&mutex);
    }
}

void writer(void)
{
    while (1) {
        P(&w);
        /* 临界区 */
        /* 写入操作 */
        V(&w);
    }
}
```

</div>

<div>

<v-clicks at="1">

- 竞争的模拟来写成了 `while` 循环（而非多线程）
- 使用 `mutex` 信号量来保护对于全局变量 `readcnt` 的访问
- 使用 `w` 信号量来保证同一时间最多只有一个写者，但是可以有多个读者（注意顺序！）
- 通过在读者内判断 `readcnt` 的数量，来决定是否作为读者全体，大发慈悲释放 `w` 锁让写者进入
- 看似读者优先写者，但这个优先级很弱，所以既可以造成读者饥饿，也可以造成写者饥饿

</v-clicks>

</div>
</div>

<!--
为什么写者饥饿？只要已经有读者在读，后来的读者就可以继续“插队”进来（写着一直被 P(w） 卡着的）；而写者必须等到“所有读者都走光”（readcnt 变回 0）才能拿到 w。

读者怎么饥饿？如果调度是一直调度写者，那么读者也是可能饿死的。
-->


---

# 第二类读者写者问题

Second type of reader-writer problem

<div grid="~ cols-2 gap-8">
<div>

```c{all}{maxHeight: '400px',lines: true}
/* 全局变量 */
int readcnt = 0;          /* 初始值 = 0 */
int writecnt = 0;         /* 初始值 = 0 */
sem_t rmutex, wmutex;     /* 保护 readcnt / writecnt，初值均为 1 */
sem_t w;                  /* 控制对“书”的互斥访问，初值为 1 */
sem_t readtry;            /* 门禁：有写者在等时，禁止新读者进入，初值为 1 */

void reader(void)
{
    while (1) {
        P(&readtry);          /* 先过门禁：只要有写者在等，就别插队了 */
        P(&rmutex);
        readcnt++;
        if (readcnt == 1)     /* 第一个读者进来：锁住 w，挡住写者 */
            P(&w);
        V(&rmutex);
        V(&readtry);          /* 门禁要尽快放开：读者只是“登记一下” */

        /* 临界区 */
        /* 读取操作 */

        P(&rmutex);
        readcnt--;
        if (readcnt == 0)     /* 最后一个读者离开：放行写者 */
            V(&w);
        V(&rmutex);
    }
}

void writer(void)
{
    while (1) {
        P(&wmutex);
        writecnt++;
        if (writecnt == 1)    /* 第一个写者到达：把门口一锁，禁止新读者进入 */
            P(&readtry);
        V(&wmutex);

        P(&w);
        /* 临界区 */
        /* 写入操作 */
        V(&w);

        P(&wmutex);
        writecnt--;
        if (writecnt == 0)    /* 最后一个写者离开：把门口打开，放行读者 */
            V(&readtry);
        V(&wmutex);
    }
}
```

</div>

<div v-click text-sm>


* 目标：**写者优先**{.text-sky-5}（解决“读者一直插队，写者永远进不去”的饥饿问题）
* 对比第一类：第一类只有 `readcnt + mutex + w`，读者可以在已有读者读的时候不断“续命式”插队，写者就可能一直卡在 `P(&w)`。（读者流量大时很常见）
* 新增两个东西：
  * `writecnt + wmutex`：用来判断“**有没有写者在等待**”
  * `readtry`：**门禁**{.text-sky-5}
    * 第一个 writer 到来就 `P(&readtry)` 把门锁上：此后新 reader 会先卡在 `P(&readtry)`，不允许继续插队
    * 老 reader 不受影响：已经进门的读者照样读完，最后一个读者 `V(&w)` 后写者就能进
    * 最后一个 writer 离开再 `V(&readtry)` 开门：读者恢复正常进入
* 性质：writer 基本不会饿死了；**代价是 reader 可能饿死**（写者源源不断来，门就一直锁着）


</div>
</div>

<!--
直觉：
- 第一类的问题在于：读者拿到 w 的方式是“第一个读者 P(w)”，但“新读者”不需要等写者队列清空就能继续进来，只要有人在读就能进。
- 第二类的关键就是 readtry：只要检测到“有人写者在等”（writecnt>0），就先把 readtry 锁死，后来的读者连 readcnt++ 这一步都做不了。
- 注意读者对 readtry 的持有时间要非常短：只用于“是否允许进入”的检查 + 登记 readcnt。
-->


---

# 线程安全函数

Thread-safe functions

**线程安全**：一个函数被多个并发线程反复地调用时，它会一直产生正确的结果。

回忆：线程之间存在竞争关系，在没有使用信号量等同步机制时，你不能假定其执行顺序。

四类线程不安全函数：

1. 第 1 类：不保护全局变量
2. 第 2 类：保持跨越多个调用的状态，也即返回结果强相关于调用顺序（比如伪随机数生成器）
3. 第 3 类：返回指向静态变量（`static`）的指针
4. 第 4 类：调用线程不安全的函数

---

# 第 1 类线程不安全函数

Class 1 Thread-unsafe functions

<div grid="~ cols-2 gap-8">
<div>

第 1 类：不保护全局变量

- 多线程并行时，**全局变量可能被多个线程同时修改**{.text-sky-5}，导致结果不正确
- 可以使用信号量来保护全局变量，使得每次只有一个线程可以访问它

</div>

<div>

```c
int counter = 0;

void increment(void) {
    counter++;
}
```

</div>
</div>

---

# 第 2 类线程不安全函数

Class 2 Thread-unsafe functions

<div grid="~ cols-2 gap-8">
<div>

第 2 类：保持跨越多个调用的状态，也即返回结果强相关于调用顺序

- `next_random` 同时是第 1 类和第 2 类线程不安全函数，因为 `next_seed` 是全局变量，且跨越多个调用的状态
- `next_random_2` 是第 2 类线程不安全函数，虽然保护了对于全局变量 `next_seed` 的访问，但是 `next_seed` 是跨越多个调用的状态，**即下一次调用返回结果依赖于从现在到那时之间是否有其他线程调用**{.text-sky-5}
- 注意，`static` 声明的变量在函数内共享

</div>

<div>

```c
unsigned next_seed = 1;
sem_t mutex;

/* 返回一个随机数，书上版本 */
unsigned next_random(void) {
    next_seed = next_seed * 1103515245 + 12345;
    return (unsigned int)(next_seed / 65536) % 32768;
}

/* 返回一个随机数，修改后版本 */
unsigned next_random_2(void) {
    P(&mutex);
    static unsigned next_seed_2 = 1;
    next_seed_2 = next_seed_2 * 1103515245 + 12345;
    V(&mutex);
    return (unsigned int)(next_seed_2 / 65536) % 32768;
}
```

</div>
</div>

---

# 第 3 类线程不安全函数

Class 3 Thread-unsafe functions

<div grid="~ cols-2 gap-8">
<div>

第 3 类：返回指向静态变量（`static`）的指针

- 和第 2 类一样，你这个结果正确与否取决于在调用它得到结果到你使用它之间，是否有其他线程调用同函数
- 这也是一个第 1 类线程不安全函数，因为 `static` 变量是全局变量，这里没保护
- 若有，则此 `static` 由于在函数内共享（进而在线程间共享），所以可能会被其他线程修改

</div>

<div>

```c
char* ctime(const time_t* timer) {
    // ctime 总是返回一个长度为 26 的固定字符串
    static char buf[26]; 
    struct tm* tm_info = localtime(timer);
    strftime(buf, 26, "%a %b %d %H:%M:%S %Y\n", tm_info);
    return buf;
}
```


</div>
</div>

---

# 第 3 类线程不安全函数

Class 3 Thread-unsafe functions

<div grid="~ cols-2 gap-8">
<div>

第 3 类：返回指向静态变量（`static`）的指针

解决方法：

- 核心：设法使得结果对于每个线程私有、独立
- 做法：
    - `malloc` 分配堆上内存，使结果对线程唯一
    - 传递存放结果处指针，使结果完全独立可控

</div>

<div>

```c
char *ctime_ts(const time_t *timep, char *privatep)
{
    char *sharedp;
    P(&mutex);
    // 获取时间字符串
    sharedp = ctime(timep);
    // 将共享的字符串复制到私有空间
    strcpy(privatep, sharedp);
    V(&mutex);
    // 返回私有空间的指针
    return privatep;
}

```


</div>
</div>

---

# 第 4 类线程不安全函数

Class 4 Thread-unsafe functions

<div grid="~ cols-2 gap-8">
<div>

第 4 类：调用线程不安全的函数

- 但是不一定调用了就不行
- 比如第 1 类、第 3 类很多情况下加个锁就可以了
    - 使用前：`P(&mutex)`
    - 使用后：`V(&mutex)`

</div>

<div>

```c
char* ctime(const time_t* timer) {
    // ctime 总是返回一个长度为 26 的固定字符串
    static char buf[26]; 
    struct tm* tm_info = localtime(timer);
    strftime(buf, 26, "%a %b %d %H:%M:%S %Y\n", tm_info);
    return buf;
}

void safe_ctime(){
    P(&mutex);
    char* result = ctime(NULL);
    // 使用 result
    V(&mutex);
}
```

</div>
</div>

---

# 可重入性

Reentrant functions

**可重入函数**：被多个线程调用时，不会引用任何共享数据。

注意：可重入和线程安全并不等价！

- 显式可重入：完全使用本地自动栈变量，在线程上下文切换时能保证切换回来的时候 “一切如初”
- 隐式可重入：要共享的东西使用指针传递，小心处理，保证对于线程是唯一的，**这使得这个数据不再是线程间共享的**{.text-sky-5}

<div grid="~ cols-2 gap-8">
<div>

```c
/* 显式可重入 */
/* 自己玩自己的，别的线程和我无关 */
void reentrant_function() {
    int a = 1;
    int b = 1;
    for (int i = 0; i < 100; i++) {
        int tmp = a;
        a = a + b;
        b = tmp;
    }
    return a;
}
```

</div>

<div>

```c
/* 寄 */
unsigned next_seed = 1;
unsigned rand(void)
{
    next_seed = next_seed * 1103515245 + 12345;
    return (unsigned)(next_seed >> 16) % 32768;
}
/* 隐式可重入 */
unsigned int rand_r(unsigned int *nextp)
{
    // 好好维护指针，那么 nextp 就不会共享
    *nextp = *nextp * 1103515245 + 12345;
    return (unsigned int)(*nextp / 65536) % 32768;
}
```

</div>
</div>

---

# 回顾

Recap

<div grid="~ cols-2 gap-8">
<div>

- 线程安全：一个函数被多个并发线程反复地调用时，它会一直产生正确的结果
    - 末尾加 `_r` 表示是函数的线程安全版本
- 可重入：被多个线程调用时，不会引用任何共享数据

线程安全但不可重入的函数：

```c
int counter = 0;

void increment(void) {
    P(&mutex);
    counter++; // 引用了共享数据
    V(&mutex);
}
```

</div>

<div>

![thread_safe_func](/10-CONC/thread_safe_func.png)

</div>
</div>

---

# 多线程编程

Multithreaded Programming


![multithread](/10-CONC/multithread.png){.h-80.mx-auto}

---

# 作业题

homework

下面的程序有一个 bug。要求线程睡眠一秒钟然后输出一个字符串。

```c
void *thread(void *vargp);

int main() {
    pthread_t tid;
    pthread_create(&tid, NULL, thread, NULL);
    exit(0);
}

void *thread(void *vargp) {
    sleep(1); // 让主线程有时间退出
    printf("Hello from thread\n");
    return NULL;
}
```

1. 为什么没有输出？
2. 可以用两个不同的 pthread 函数调用中的一个来替代里面的 `exit` 来改正。哪两个？

<div v-click>

答案：因为 `exit` 直接终止了整个进程。用 `pthread_join` 和 `pthread_exit` 都可以。

</div>

<!--
可以给大家现场演示代码。
-->

---

# 作业题

Homework

12.18（课本 p724）用图 12-21 中的进度图，将下列的轨迹线分类为安全/不安全的。

1. $H_2, L_2, U_2, H_1,L_1,S_2,U_1,S_1,T_1,T_2$
2. $H_2,H_1,L_1,U_1,S_1,L_2,T_1,U_2,S_2,T_2$
3. $H_1,L_1,H_2,L_2,U_2,S_2,U_1,S_1,T_1,T_2$

---

# 作业题

Homework

<div grid="~ cols-2 gap-8">
<div>

12.19（课本 p724）先前第一类读者-写者问题的解答给予读者的是有些弱的优先级。

因为写者在离开它的临界区时，可能会重启一个正在等待的写者，而不是一个正在等待的读者。<span class="text-sm text-gray-5">（Why？）</span>

推导出一个解答，它给予读者更强的优先级，当写者离开它的临界区的时候，如果有读者正在等待的话，就总是重启一个正在等待的读者。

<div class="text-sm text-sky-5" v-click>

读者和写者竞争同一个 `w` 信号量，当一个 `V(&w)` 调用时，可能是：

- 0 / 1 个读者阻塞（读者之间还有 `mutex` 互锁，拿不到 `w` 时最多有 1 个读者）
- 多个写者阻塞

</div>

</div>

<div>

```c{all|11,26,29}{maxHeight: '400px',lines: true,at: 1}
/* 全局变量 */
int readcnt;         /* 初始值 = 0 */
sem_t mutex, w;      /* 两者初始值均为 1 */

void reader(void)
{
    while (1) {
        P(&mutex);
        readcnt++;
        if (readcnt == 1) /* 第一个进入 */
            P(&w);
        V(&mutex);
        /* 临界区 */
        /* 读取操作 */
        P(&mutex);
        readcnt--;
        if (readcnt == 0) /* 最后一个离开 */
            V(&w);
        V(&mutex);
    }
}

void writer(void)
{
    while (1) {
        P(&w);
        /* 临界区 */
        /* 写入操作 */
        V(&w);
    }
}
```

</div>
</div>

---

# 作业题

Homework

<div grid="~ cols-2 gap-8">
<div text-sm>

<v-clicks>

1. 因为弱优先问题是由读者和写者同时阻塞在 `P(&w)` 引起的，那如果我们能让读者阻塞在 `P(&w)`，而写者阻塞在其他地方，那就能解决这个问题。
2. 当 writer 释放 `V(&w)` 时，如果有多个读者和写者，则其中一个读者阻塞在 `P(&w)`，而所有写者都会阻塞在 `P(&writetry)`。
3. 不过这并不能保证读者一定能继续执行，我们需要在读者继续之前锁住这个 writer，让它没法释放 `writetry`。
4. `mutex` 正好合适，因为当有 reader 正在等待时，`mutex` 必然为 0，而这会让那个将要结束的 writer 线程阻塞，从而只有 reader 线程能继续执行下去。

</v-clicks>

</div>

<div>

```c{all|8,19,23|19,23,25|5,8,23-25}{maxHeight: '400px',lines: true,at: 2}
/* 全局变量 */
int readcnt = 0;
sem_t mutex, w, writetry; /* 初始值均为 1 */
void reader() {   /* reader代码不变 */
    P(&mutex);
    ++readcnt;
    if(readcnt == 1)
        P(&w);
    V(&mutex);
    /* 临界区 */
    /* 读取操作 */
    P(&mutex);
    --readcnt;
    if(readcnt == 0)
        V(&w);
    V(&mutex);
}
void writer() {
    P(&writetry);
    P(&w);
    /* 临界区*/
    /* 写入操作 */
    V(&w);
    P(&mutex);
    V(&writetry);
    V(&mutex);
}
```

</div>
</div>

---

# 作业题

Homework

12.28（课本 p724）在图 12-45（课本 p722）中将两个 $V$ 的顺序交换，对程序死锁是否有影响？通过画出四种可能情况的进度图来证明你的答案。

<div v-click>
答案：都不会（记住这个结论）
</div>

---

# 作业题

Homework

12.30（课本 p725）考虑下面这个会死锁的程序。初始时 `a = 1, b = 1, c = 1`。

<div text-sm>

<style scoped>
table {
  line-height: 1.5;
}
th, td {
  padding: 0.25rem 0.5rem;
}
</style>

| 线程 1  | 线程 2  | 线程 3  |
| ------- | ------- | ------- |
| `P(a);` | `P(c);` | `P(c);` |
| `P(b);` | `P(b);` | `V(c);` |
| `V(b)`; | `V(b);` | `P(b);` |
| `P(c);` | `V(c);` | `P(a);` |
| `V(c)`; | `P(a);` | `V(a);` |
| `V(a);` | `V(a);` | `V(b);` |

</div>

1. 列出每个线程同时占用的一对互斥锁。<span v-click text-sm> a&b,a&c; b&c; a&b </span>
2. 如果规定加锁全序 $a<b<c$，那么哪个线程违背了互斥锁加锁顺序规则？<span v-click text-sm> 2 和 3  </span>
3. 对于这些线程，指出一个新的保证不会发生死锁的加锁顺序。<span v-click text-sm> 线程2 交换 b/c 加锁顺序，线程 3 交换 a/b 加锁顺序 </span>



---

# 并发习题

Concurrent Programming Exercises

<div grid="~ cols-2 gap-8">
<div text-sm>

有三个线程 `PA` `PB` `PC` 协作工作以解决文件打印问题。

- `PA` 线程从磁盘读取输入存缓冲区 `Buff1`，每执行一次读入一个记录；
- `PB` 将缓冲区 `Buff1` 的内容复制到缓冲区 `Buff2`，每执行一次复制一个记录；
- `PC` 将缓冲区 `Buff2` 中的内容打印出来，每执行一次打印一个记录。

缓冲区 `Buff1` 可以放 4 个记录，缓冲区 `Buff2` 可以放 8 个记录。

请设计若干信号量，给出每一个信号量的作用和初值，然后将信号量上对应的 PV 操作填写在代码中适当位置，可以留空。

> 注意：课本中的 API 提供的 `P` 和 `V` 函数操作的都是信号量的指针，如果考试让填的话不要忘记填 `&`。

</div>

<div>



```c{*}{maxHeight: '400px',lines: true}
PA() {
    while(1) {
        // ① 
        // 从磁盘读入一个记录
        // ② 
        // 将记录放入 Buff1
        // ③ 
    }
}

PB() {
    while(1) {
        // ④ 
        // 从 Buff1 中取出一个记录
        // ⑤ 
        // 将记录放入 Buff2
        // ⑥ 
    }
}

PC() {
    while(1) {
        // ⑦ 
        // 从 Buff2 中取出一个记录
        // ⑧ 
        // 打印
    }
}
```

</div>
</div>

---

# 并发习题

Concurrent Programming Exercises

```c{*}{maxHeight: '400px',lines: true}
/* 信号量 */
sem_t empty1 /* 初值：4 */
sem_t full1 /* 初值：0 */
sem_t empty2 /* 初值：8 */
sem_t full2 /* 初值：0 */
sem_t mutex1 /* 初值：1 */
sem_t mutex2 /* 初值：1 */

PA() {
    while(1) {
        // NONE
        // 从磁盘读入一个记录
        P(&empty1); // empty1--
        P(&mutex1);
        // 将记录放入 Buff1，顺序无所谓，V 操作不阻塞
        V(&full1); // full1++
        V(&mutex1);
    }
}

PB() {
    while(1) {
        P(&full1); // full1--
        P(&mutex1);
        // 从 Buff1 中取出一个记录
      	// V 操作可以挪到最后，因为此时持有 mutex1 保证不会有 PA 来竞争
        V(&mutex1);
      	V(&empty1) // empty1++
        // --- //
        P(&empty2); // empty2--
        P(&mutex2);
        // 将记录放入 Buff2
        // 这里顺序无所谓，V 操作不阻塞
        V(&mutex2);
        V(&full2); // full2++
    }
}

PC() {
    while(1) {
        P(&full2); // full2--
        P(&mutex2);
        // 从 Buff2 中取出一个记录
        // 顺序无所谓，V 操作不阻塞
        V(&mutex2);
        V(&empty2); // empty2++
        // 打印
    }
}
```

---

# 关于信号量

Recap of Semaphores

1. 信号量没有“上限”这一概念，它只要求一侧，即其值非负
2. 连续多个 `V` 操作的时候，无所谓 `V` 操作的顺序，因为 `V` 操作永不阻塞
3. 做题的时候主要考虑 `P` 操作的顺序要能够保证不会死锁
4. 做题的时候可以显式将 `P` 翻译为对应变量 `--`，`V` 翻译为对应变量 `++`，观察语义，确定你的代码没有问题
5. 单个线程里 `P` 操作数不要求等于 `V` 操作数，但一整个流程过下来要求 `P` 操作数等于 `V` 操作数

---

# 复习建议

some advice

- 在考前尽可能把**课本完整读一遍**（这不会花你很多时间，但是是有必要的）
  - 对于基础知识的掌握是很重要的，不可因小失大
  - ~~万一出题人认为 xxx 是需要掌握的知识点呢~~
- 对于 ICS 考试，**熟练度**是必要的，请至少做三套**往年题**（23 年除外），如果有精力的话可以从 13 年的开始挨个做，但*不要只做往年题而不看课本内容，因小失大*
  - 对于链接，一定要搞清楚静态库、重定位等逻辑
  - 对于 VM，一定要熟练进行地址翻译以及页表相关推导，以及几种空闲块组织的数据结构和算法
  - 对于网络，一定要记住客户端-服务器模型里面的每个函数
  - 对于信号和并发，在理解课程内容的基础上（这一点可能已经不是很简单）尽量多做题
  - 复习我的这节课件的时候可以打开 presenter mode 看我的~~小抄~~注释
- **不建议除了突发疾病以外的情况缓考**，大三有大三要做的事，早点过了为好。如果有缓考的同学请记得私信我
- 祝大家好运！

---

# 后记

after this semester

- 很感谢大家一学期以来的包容与支持，很开心能和大家一起度过一学期的学习时光。
- 虽然过程和阶段性结果可能是痛苦的或是负面的，但还是希望大家能真正从 ICS 这门课学到有价值的东西
  - ICS 是后面四大礼包（操统、体系、编译、计网）的先导课
  - 学完 ICS 后至少计算机系统对于你来说不再是一个黑盒
  - 哪怕之后不从事系统方向的工作/科研（可能对于大多数同学包括我自己都如此），这些知识也总能在某个时刻帮到你
- 如果有任何方面（学业、科研、~~吃喝玩乐~~）的问题（没有问题也可以）欢迎和我多多交流
- 祝大家以后都能顺顺利利！
- ~~欢迎明年也报名当助教，虽然当助教救不了 ICS~~

---
layout: cover
class: text-center
coverBackgroundUrl: /11-SYNC/cover.jpg
---

# Thank you for your listening!


Cat$^2$Fish❤

<style>
  div{
   @apply text-gray-2;
  }
</style>
