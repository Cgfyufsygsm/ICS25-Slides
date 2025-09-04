---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: bg.jpg
# some information about your slides (markdown enabled)
title: "00-Introduction"
info: |
  ICS 2025 Fall Slides
# apply unocss classes to the current slide
class: text-center
# https://sli.dev/features/drawing
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
coverBackgroundUrl: cover.jpg
---

# 欢迎来到 ICS 课程

Taoyu Yang, EECS, PKU


<!--
The last comment block of each slide will be treated as slide notes. It will be visible and editable in Presenter Mode along with the slide. [Read more in the docs](https://sli.dev/guide/syntax.html#notes)
-->

---
transition: fade-out
---

# 关于助教

~~苦命科研人~~

- 2023级计算机科学与技术专业本科生

<div class="my-10 grid grid-cols-[40px_1fr] w-min gap-y-4 items-center">
  <ri:github-line class="opacity-50"/>
  <div><a href="https://github.com/Cgfyufsygsm" target="_blank">Cgfyufsygsm</a></div>
  <ri:blogger-line class="opacity-50"/>
  <div><a href="https://blog.imyangty.com/" target="_blank">blog.imyangty.com</a></div>
  <ri:mail-line class="opacity-50"/>
  <div><a href="mailto:yangty1031@stu.pku.edu.cn">yangty1031@stu.pku.edu.cn</a></div>
  <ri:wechat-2-line class="opacity-50"/>
  <div>imyangty</div>
</div>


---

# 课程概述

上

|  章号  |  主题  |  对应的 lab  |
| --- | --- | --- |
| 1 | 计算机系统漫游 | |
| 2 | 数据表示 | Data Lab  |
| 3 |机器语言 | Bomb Lab / Attack Lab |
| 4-5 | 处理器体系结构 / 代码优化 | Arch Lab |
| 6 | 存储器层次结构 | Cache Lab |

---

# 课程概述

下

|  章号  |  主题  |  对应的 lab  |
| --- | --- | --- |
| 6 | 存储器层次结构 | Cache Lab |
| 7 | 链接 | |
| 8 | 异常控制流 | Shell Lab |
| 9 | 虚拟内存 | Malloc Lab |
| 10-12 | 系统级 I/O / 网络编程 / 并发编程 | Proxy Lab |

---

# 课程概述

给分方案

- 期中 15%、期末 40%
- Lab 的完成情况 30%
- 小班 15%
  - BONUS 主要参考对大家的学习做出的贡献。
  - BONUS：lab 做得很好并在小班上讲解
  - 提出了十分有价值的问题或者解答了同学们（或者助教）的有价值的问题（公开）
  - 回课质量十分优秀
  - 正常情况下没有 PENALTY
  - PENALTY：**无故迟到超过 5 分钟 (0.5' each) 无故缺勤 (1' each)**

<br>

> 可能有调整，大班也会有作业



---

# 关于小班

概述

- ICS 小班/讨论班是同学们之间相互讨论、相互提高的重要平台

- 自我介绍环节（以下作为参考，随便说点什么都行）
  - 姓名/年级/院系
  - 你喜欢做什么？你擅长做什么？
  - 对 ICS 有什么样的预期?
  - 对我们的讨论课有什么样的预期？
  - 学术上你对什么方向比较感兴趣？ 
  
---

# 关于小班

基本内容安排

- 回课
  - **简要**回顾大班课上内容，并适当加以延伸
  - 每位同学在学期中都会轮到两次回课，抽签决定排班
  - > ***注意：每次回课时间严格控制在 15 分钟以内，超时酌情扣分！！***
- Lab 讲解
  - 不专门安排同学讲 lab
  - 从第四个 lab (Arch) 开始，如果小班里有同学的 lab 做得很好（暂定标准：排名前25），那么就由这位同学来讲那次的lab；*有 BONUS*
- 助教梳理重点 & 适度拓展 & 讨论问题
- 做 / 讲习题


---

# 如何回课

请大家认真对待

- 什么是好的回课
  - 听课的同学可以跟上，且能有兴趣听下去 ~~不要开飞机也不要当 PPT reader，助教也会不想听~~
  - 对复习有帮助，对整体知识的把握有帮助
  - 对形式没有要求，用 ppt、板书、实机演示等都没问题
- <p style="color: #FF0000; font-size: 30px">时间严格控制在 15 分钟以内</p>
- 回课可以讲什么（仅供参考）
  - 梳理知识框架、强调重点知识、讨论有趣的问题、讲一些往年题、……
  - > 这个需要你自行衡量！
- 具体的回课内容？暂

---

# ICS 怎么学
实话说，我也不清楚

ICS 是 5 学分大课，不仅占分高，还是后续很多礼包课程的基础课，大伙肯定都想学好它、拿高分，然而...

- 内容多，难度大，时间紧
- 催命的 lab 们
- 考试命题懂的都懂

尽管如此，我也有一些（不成熟的）建议：

- **<font color="red">好好读 CSAPP</font>**，至少读两遍。大班和小班的课堂时间都有限，主要是讲重点，但内容不可能覆盖到教材的每一行，所以只能靠大家自己逐字逐句慢慢读
- **Coding**，珍惜每一个 lab 提供的 coding 机会，大家会在写 lab 期间积累宝贵的实践经验
- 拟合往年题，~~尽管可能没什么用~~，但**熟练度**在 ICS 相关考试中极为重要，建议大家至少完成 3 套往年题
- 多和助教沟通，我也曾是萌新

---

# 关于答疑

请多提问

- 线上答疑
  - 答疑平台？
  - 在小班微信群中**积极提问、相互答疑**（**<font color="red">推荐！可能视情况有BONUS</font>**）相信问题会得到更快、更好的解决
  - 可以私戳助教提问 (less recommended)，助教会耐心地回答每一个问题，不过回复可能会慢一点
    - 在群里提问的话，大家都可以看到，这样一起讨论对大家的学习都是相当有帮助的
    - 如果助教的回答没有把问题讲明白，请务必当场质疑助教！
- 线下答疑
  - 助教会在每周三的晚上提前 20 分钟左右到达小班教室，欢迎来提问
- 善用搜索
  - Google（**<font color="red">推荐！</font>**），英文搜索可能更能搜到你想要的答案
  - ChatGPT, Gemini, Claude 等大语言模型可以回答你在系统领域的很多问题（**<font color="red">推荐！</font>**），但是要小心幻觉

---

# 关于 lab

- 本学期共设置 8 个 lab，预计期末之前全部截止
  - 平均每 2 周 1 个 lab，大约随大班讲课进度发布 
- **<font color="red">START EARLY!!!</font>**
  - 虽然总共有 5 个 grace day，但非常非常不建议大家当 ddl 战士
  - 否则你的学习生活可能会相当之痛苦
- **认真、独立完成**
  - 按照往年惯例设有查重机制，如果被认定为抄袭（网络、往年代码）会被请喝茶
    - 可能会被处本次 lab 成绩作废或全部 lab 成绩作废的惩罚
    - ~~去年就有活生生的案例~~
    - Datalab 抄袭也是抄袭
  - 抄课本代码不算抄袭（proxylab 等）

---

# 如何完成 lab

https://clab.pku.edu.cn/ 

- **ICS 所有的 lab** 都最好在类 UNIX 环境下完成，Windows 环境大概率无法使用。
- 如果你是 Mac 或者 Linux 系统，你可以在本地完成 lab 的代码编写。
- 如果你是 Windows 系统，**强烈建议配置一个 WSL (Windows Subsystem for Linux)**
  - 实际体验还是相当之香的
  - 可以参考[《北京大学计算机基础科学与开发手册》by 臧炫懿](https://github.com/ZangXuanyi/getting-started-handout) 中的第 8.1.4 节相关内容
- 你也可以（且推荐）在 Linux 俱乐部提供的 Clab 上进行完成。
  - > Bomblab 和 Attacklab 必须在 Clab 上完成
  - 关于 Clab 的配置与使用，请参考说明文档，助教稍后也会进行演示
  - 关于 ssh 连接主机以及 Linux 常见命令的使用，请参考[《北京大学计算机基础科学与开发手册》by 臧炫懿](https://github.com/ZangXuanyi/getting-started-handout) 中的第 5.3/7.2/8.1-8.3 节相关内容

---

# 一些心得

- **强烈建议对 Linux 不太熟悉的同学们抽空读一下[《北京大学计算机基础科学与开发手册》by 臧炫懿](https://github.com/ZangXuanyi/getting-started-handout)**
  - 在大家今后的学习/科研/工作中大概率是绕不开的
  - 这是一个很好的熟悉相关科技树的机会！
- 在完成 lab（以及其他课程的大作业）时**强烈建议用 Git 进行版本管理**
  - 可以参考[《北京大学计算机基础科学与开发手册》by 臧炫懿](https://github.com/ZangXuanyi/getting-started-handout) 的第 3.5 节以及 7.1 节相关内容以及 *Progit* 的前三章
  - Git 也是大家以后学业/职业生涯中绕不开的重要工具，强烈建议大家掌握！
- 课程节奏（个人体验）
  - 刚开始的几周（Chap 2，Chap 3）节奏稍慢
  - 从 Chap 4 开始，节奏会变快，在期中考附近迎来一波小高潮。Chap 4 是全书最难的章节之一。
  - 8 个 lab 的难度和任务量整体递增
  - 大家及时调整，安排好自己的学习节奏，**但是 ICS 其实也没有那么可怕，只要调整好学习节奏，肯花时间，结果也不会很差**
  

---

# 大家可能需要的链接

- [助教自己的 Github 仓库](https://github.com/Cgfyufsygsm/ICS24-Introduction-to-Computer-System-2024Fall-PKU)
  - 包含往年题、课件、2024 年的所有 lab 的 writeup 以及 handout（代码什么的自然是没有的）
  - 以及一些相当之有用的链接汇总
  - 大家可以 clone 到本地以供随时参阅
- [助教的小班课课件仓库](https://github.com/Cgfyufsygsm/ICS25-Slides)
  - 可以在助教部署的 Github Pages 上在线观看
  - 也可以根据仓库中的指引 clone 到本地部署后观看
- 课程相关官方链接
  - [AutoLab](https://autolab.pku.edu.cn/)：lab 的在线评测平台
  - [Clab](https://clab.pku.edu.cn/)：Linux 俱乐部搭建的云计算平台，可在上面完成 lab 的代码编写
  - 答疑平台？TODO
  
---
layout: center
class: text-center
---

# 配置环境/答疑时间

---
layout: cover
class: text-center
---

# Thank you for your listening!

祝大家学有所成！

Cat$^2$Fish❤