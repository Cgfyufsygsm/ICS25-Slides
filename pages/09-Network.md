---
# You can also start simply with 'default'
theme: academic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# background: bg.jpg
# some information about your slides (markdown enabled)
title: "09-Network-Programming"
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
coverBackgroundUrl: /09-Network/cover.jpg
---


# 网络编程

Network Programming

<style>
  div{
   @apply text-gray-2;
  }
</style>

---

# 近期安排

Misc

- 注意 Malloc Lab 的截止时间是 12 月 18 日 23:59
- 预计这周四发 Proxy Lab，~~但是没学过并发的话我也不知道你们能写啥~~
- 关于下周一的 Lab 测验：
  - 具体形式未知，可能为 50 道选择/判断题
  - 不要问助教，助教也不知道，但有最新消息会第一时间告诉大家
  - 考试范围为前 7 个 lab，即从 Data Lab 到 Malloc Lab
- 剩余几次课的安排：
  - 本节课讲网络编程
  - 下节课/下下节课讲并发
  - 建议大家提前阅读 CSAPP 的并发部分，并提前开展期末复习，期末时间为 12.29（考试周第一周周一）
  - *最后一节小班课建议大家都出席，有小惊喜*

---

# 客户端 - 服务端模型

Client - Server Model

![client-server](/09-Network/client_server.png){.mx-auto}

客户端和服务端是 **进程**{.text-sky-5}，而不是 **主机**，它们可以在同一台主机上，也可以在不同的主机上。

<span class="text-sm text-gray-5">

但是一般而言，你可以这么理解网络：到另一台计算机上获取文件（资源）

</span>

---

# 网络

Network

<div grid="~ cols-2 gap-8">
<div>

网络是一种 **I/O**{.text-sky-5} 设备，通常使用 DMA 传输。

网络是按照地理远近组成的层次系统。

</div>

<div>

![network_io](/09-Network/network_io.png){.mx-auto}

</div>
</div>

---

<div grid="~ cols-2 gap-8">
<div text-sm>


# 网络

Network

#### **局域网**（Local Area Network，LAN）

以太网（Ethernet）是一种 LAN 技术

- 主机
- 集线器（Hub）：不加分辨地转发到所有端口
- 桥（Bridge）：存在分配算法，有选择性地转发

LAN 帧 = LAN 帧头 + 互联网络包（有效载荷）

<div mt-4/>

#### **广域网**（Wide Area Network，WAN）

WAN 由路由器连接若干 LAN 组成。

- 路由器（Router）：每台路由器对它所连接到的每个网络都有一个适配器（端口）

互联网络包 = 互联网络包头 + 用户数据（有效载荷）


</div>

<div flex flex-col justify-center items-center h-full>

![lan](/09-Network/lan.png){.mx-auto}

<div class="text-sm text-gray-5 mx-auto">
桥接 LAN
</div>

![wan](/09-Network/wan.png){.mx-auto}

<div class="text-sm text-gray-5 mx-auto">
WAN
</div>

</div>
</div>

---

# 互联网的重要组成部分

Components of the Internet

<div grid="~ cols-2 gap-8">
<div>

可以从“社会”类比理解互联网的构成：

- **实体**：终端主机（PC、手机、服务器）、路由器、交换机、AP 等
- **服务**：Web、视频、邮件、网盘、网游、云服务、物联网……
- **规则**：协议和标准（RFC、IETF），规定这些实体如何通信、协作

一个“Internet” = 实体 + 服务 + 规则 共同构成的“网络社会”。

</div>

<div flex items-center justify-center>

<!-- ![internet-components](/09-Network/internet_components_placeholder.png){.mx-auto} -->

</div>
</div>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q2：基于 ICS22 课件第 5 页，你会怎样用一句话向没学过的同学概括——“互联网都包含了哪些重要组成部分”？试着在纸上画一张你眼中的“网络社会”结构图。

</div>

---

# 互联网

Internet

互联网（<span class="text-sky-5">i</span>nternet）：路由器连接若干 LAN 和 WAN

全球 IP 因特网（<span class="text-sky-5">I</span>nternet）：是互联网（internet）的具体实现

### 协议软件{.mb-2.mt-8}

协议软件：让主机能够跨过不兼容的网络发送数据

- 命名机制
- 传送机制：运行在主机和路由器上，控制主机和路由器协同工作。<br>一个包是由 **包头** 和 **有效载荷** 组成的，包头包括了传输所需信息，如源主机地址、目的主机地址


---

# 讨论：Internet vs internet

Internet vs internet

<v-clicks>

- **internet（小写）**：泛指“由多个网络互联而成的网络之网络”
  - 比如：学校内部把多个院系的 LAN 互联起来，也可以说是一个 internet
- **Internet（大写）**：我们日常说的 **全球 IP 因特网**
  - 使用标准的 TCP/IP 协议族
  - 由全球各地的 ISP、数据中心、路由器共同构成
  - 通过统一的 IP 地址和 DNS 域名系统互联

</v-clicks>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q1：试着举出一个“小写 internet” 的例子（不一定连到全球 Internet）。如果一个局域网 **完全与外界隔绝**，它算 Internet 吗？算 internet 吗？为什么？

</div>

---

# 互联网协议栈：分层结构

Internet protocol stack

<div grid="~ cols-2 gap-8">
<div text-sm>

我们通常用一个 **五层模型** 来理解互联网里的协议是怎么配合工作的：

- **应用层**（Application）传什么样的数据？要完成什么应用功能？例：HTTP/HTTPS、SMTP、IMAP、DNS 等。
- **传输层**（Transport）在“哪两个进程之间”传？要不要确认、要不要可靠？例：TCP、UDP。
- **网络层**（Network）在“哪两台主机之间”传？中间经过哪些路由器？例：IP 以及各种路由协议。
- **链路层**（Link）在“相邻节点之间”传一帧数据，用的是有线还是无线链路？例：以太网、WiFi（802.11）、4G/5G、PPP。
- **物理层**（Physical）比特到底是怎么变成电信号 / 光脉冲 / 无线电波在介质上传输的？例：双绞线、同轴电缆、光纤、无线电。

每一层都向上一层提供一个 **抽象服务**，向下一层请求“帮我把这些比特送到某个地方”。

</div>

<div>

<!-- 占位图，后面可以换成 ICS22 那张五层图 -->
![layers](/09-Network/layers.png){.mx-auto}

<div class="text-sm text-gray-5 mt-2">
示意图：从上到下依次是 应用 / 传输 / 网络 / 链路 / 物理 五层
</div>

</div>
</div>

<div class="text-sm text-gray-5 mt-4">
后面出现的“传输层 TCP/UDP”、“网络层 IP”、“链路层 以太网 / WiFi”等术语，都是这个分层模型中的角色。
</div>


---

# 什么是网络协议？

What is a protocol?

<div grid="~ cols-2 gap-8">
<div text-sm>

类比“人类协议”：

- “老师点名 → 学生回答在 / 到”
- “提问时先举手，再发言”

**网络协议**：

- 参与者：主机、路由器上的程序（网络实体）
- 内容：规定
  - **报文格式**（有哪些字段、以什么顺序出现）
  - **发送顺序**（什么时候发、先发谁后发谁）
  - **收到后的动作**（丢弃 / 回复 / 建立连接 / 记录日志……）

</div>

<div text-sm>

日常上网常见协议（按层大致分类）：

- 应用层：HTTP/HTTPS（浏览网页）、SMTP/IMAP（邮件）、DNS（域名解析）
- 传输层：TCP（可靠字节流）、UDP（尽力而为数据报）
- 链路层：以太网、WiFi（802.11）、4G/5G 蜂窝网络

</div>
</div>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q3：回忆你今天使用手机 / 电脑做过的 3 件事（比如刷小红书、打网游、视频会议），分别涉及到了哪些网络协议？试着按层把它们归类。

</div>


---

# 居家访问互联网：典型拓扑


<div grid="~ cols-2 gap-8">
<div text-sm>

Home network

典型家庭 / 宿舍网络中常见设备：

1. **终端设备**  
   电脑、手机、平板、智能电视、游戏机、IoT 设备等
2. **无线路由器（家用“路由器”一体机）**
   - 以太网交换机：负责有线 LAN
   - WiFi 接入点（AP）：负责无线 LAN
   - NAT + 简单防火墙：把家里的私有地址映射到运营商给的公网地址
3. **宽带调制解调器（Modem / 光猫）**
   - 光纤到户：光猫连接到运营商（ISP）的接入网
   - 或者 Cable / DSL Modem

数据路径大致是：**终端 → 路由器/AP → Modem/光猫 → ISP → 互联网**。

</div>

<div>

![home-network](/09-Network/home_network.png){.mx-auto}

</div>
</div>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q4：画出你自己家里（或寝室）的网络拓扑图，标出每类设备。想一想：如果路由器坏了 / 光猫断电了 / 运营商侧出现故障，各自会带来什么现象？

</div>

---

# 连接到网络的物理媒介

Physical media

<div grid="~ cols-2 gap-8">
<div text-sm>

常见链路物理媒介：

- **双绞线（Twisted Pair）**
  - 两根铜线绞在一起，抗干扰
  - 常见于以太网网线（Cat5e/Cat6），1Gbps / 10Gbps
- **同轴电缆（Coaxial Cable）**
  - 有线电视、Cable 宽带常用
  - 可做频分复用，一根线多个“频道”
- **光纤（Fiber Optic）**
  - 用光脉冲传输，带宽高、损耗低、抗电磁干扰
  - 城域网 / 骨干网 / 数据中心中广泛使用


</div>

<div text-sm>

- **无线电（Radio）**
  - WiFi、4G/5G、蓝牙、卫星通信等
  - 不需要线缆，但受噪声、遮挡、干扰影响

一些小观察：

- 家里“最后一段”通常是 **铜线 + WiFi**，
  学校 / 机房常用 **光纤 + 以太网**
- 物理媒介决定了链路的
  **带宽、误码率、覆盖范围和成本**

</div>
</div>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q5：你日常使用的终端，从你手里到最近的路由器 / 交换机之间，使用的是哪种物理媒介？再往后的几跳（到宿舍楼机房 / 校园骨干网 / ISP）呢？

</div>


---

# 互联网络传输

internet transfer

<div flex gap-4>

<div>

你可能会疑惑：“网络”在哪里？

注意这是一个 internet 而不是 Internet，它只有两个 LAN。

- 帧的有效载荷是互联网络包
- 互联网络包的有效载荷是数据


</div>

<img src="/09-Network/internet_transfer.png" class="h-80 shrink-0"/>

</div>


---

# 全球 IP 因特网

Internet

<div grid="~ cols-2 gap-8">
<div>


### TCP / IP 协议

- 内核模式运行
- 是协议族，提供不同的功能

Key points：

- 主机集合被映射为一组 32 位的 **IP 地址**{.text-sky-5}
- 这组 IP 地址被映射为一组称为因特网 **域名**{.text-sky-5}（Internet domain name）的标识符
- 因特网主机上的进程能够通过连接（connection）和任何其他因特网主机上的进程通信。

</div>

<div>


![internet](/09-Network/internet.png){.mx-auto}


</div>
</div>

---

# 全球 IP 因特网

Internet


**IP协议**（Internet Protocol，互联网协议）：

- 它提供了一种基本的命名方法和传递机制（给每台电脑分配一个唯一的 32 位 IP 地址，并负责把数据包（或者叫数据宝，Datagram）送到正确的地址）
- 它是不可靠的（不保证数据包一定会到达目的地，也不负责重传丢失的数据包）

**UDP协议**（User Datagram Protocol，用户数据报协议）是对 IP 协议的扩展：

- 它允许数据包在不同的进程之间传送（就像允许不同的程序之间直接发送数据）
- 它也不保证数据的可靠传输

**TCP协议**（Transmission Control Protocol，传输控制协议）是构建在 IP 协议之上的更复杂的工具：

- 它提供了可靠的 **全双工连接**（就像在两个程序之间建立一条可靠的双向通道，确保数据准确无误地传输）

---

# TCP vs UDP


![tcp_vs_udp](/09-Network/tcp_vs_udp.png){.mx-auto}

---

# IP 协议：尽力而为的分组转发

IP protocol

<div grid="~ cols-2 gap-8">
<div text-sm>

**层次位置**：网络层（host-to-host）

核心功能：

- 给每台主机分配 **IP 地址**
- 根据“目的 IP 地址”在路由器之间 **转发数据报（datagram）**
- 负责把一个数据报从源主机送到目的主机

特点：

- **无连接**：每个 IP 数据报彼此独立，网络不维护“会话状态”
- **不可靠**：可能丢包、乱序、重复，不重传、不排序
- **尽力而为（best effort）**：能送则送，送不到就丢

IP 只负责“送到那台主机”，不关心“送到主机上的哪一个进程”。

</div>

<div text-sm>

一些重要观念（概念级）：

- IP 头里有：源 IP、目的 IP、TTL、上层协议号等字段
- 路由器根据路由表和目的 IP 选择“下一跳”
- **上层协议号** 告诉操作系统：这个数据报的内容应该交给 TCP / UDP / ICMP 等哪一层继续处理

</div>
</div>

---

# UDP 协议：无连接的尽力而为服务

UDP protocol

<div grid="~ cols-2 gap-8">
<div text-sm>

**层次位置**：传输层（process-to-process）

功能：

- 在 IP 之上加上 **端口号**，把数据交给正确的进程
- 提供简单的 **数据报服务（datagram service）**

特点：

- **无连接**：发送前无需握手，`sendto()` 直接发
- **不可靠**：不重传、不排序、不去重
- **保留报文边界**：一次发送对应一次接收（要么整条报文到，要么整个丢）


</div>

<div text-sm>


适合场景：

- DNS 查询（53/UDP）
- 语音 / 视频实时通话、直播
- 网络游戏等对延迟敏感的应用
- 简单的请求-应答协议（DHCP、TFTP 等）

使用 UDP 的典型理由：

- 头部开销小，处理开销也小
- 可以让应用“自己决定”重传策略、超时时间
- 某些场景下，“偶尔丢几个包”比“增加延迟和抖动”更可以接受

</div>
</div>

---

# TCP 协议：面向连接的可靠字节流

TCP protocol

<div grid="~ cols-2 gap-8">
<div text-sm>

**层次位置**：传输层（process-to-process）

对应用程序抽象出一条：

- **面向连接** 的
- **可靠、有序、不重复**
- **全双工** 的
- **字节流** 通道

内部机制（概念级）：

- 序号（sequence number） + 确认号（ACK）
- 超时重传、重排序、去重
- 接收窗口 / 发送窗口 → 流量控制
- 拥塞窗口 → 拥塞控制（慢启动、拥塞避免等）

</div>

<div text-sm>

常见使用场景：

- HTTP / HTTPS（Web）
- SMTP / IMAP / POP3（邮件）
- SSH（远程登录）
- 各种数据库连接、RPC、文件传输等

注意：TCP 看到的是“字节流”，一次 `write()` 和对方的几次 `read()` 不一定一一对应。

</div>
</div>

---

# TCP 连接建立与终止

TCP handshake & teardown

<div grid="~ cols-2 gap-8">
<div text-sm>

### 建立连接：三次握手

1. **SYN**：客户端 → 服务器  
   `SYN = 1, Seq = x`

2. **SYN + ACK**：服务器 → 客户端  
   `SYN = 1, ACK = 1, Seq = y, Ack = x + 1`

3. **ACK**：客户端 → 服务器  
   `ACK = 1, Seq = x + 1, Ack = y + 1`

此时双方确认：

- 对方“收得到”自己的报文
- 双方都同意了起始序号（x 和 y）

</div>

<div text-sm>

### 终止连接：四次挥手（以客户端主动关闭为例）

1. 客户端发送 `FIN`，表示“我这边不再发送了”
2. 服务器回 `ACK`，确认客户端这个方向关闭
3. 服务器在发送完剩余数据后，也发送 `FIN`
4. 客户端回 `ACK`，确认服务器这个方向关闭

主动关闭的一方会进入 **TIME\_WAIT** 状态一段时间：

- 防止旧的重复报文影响后续“新连接”
- 确保对方确实收到了最后一个 ACK

</div>
</div>

---

# 常见应用层协议速览

Application protocols

<div text-sm>

<style scoped>
table {
  line-height: 1.8;
}
th, td {
  padding: 0.25rem 0.5rem;
}
</style>

| 协议  | 端口 (典型) | 传输层 | 主要用途                          |
|-------|-------------|--------|-----------------------------------|
| HTTP  | 80/TCP      | TCP    | Web 浏览、REST API                |
| HTTPS | 443/TCP     | TCP    | 加密的 Web（HTTP over TLS）       |
| SMTP  | 25/587/TCP  | TCP    | 发送电子邮件（客户端/服务器/中继）|
| POP3  | 110/TCP     | TCP    | 客户端从服务器拉取邮件            |
| IMAP  | 143/TCP     | TCP    | 客户端与服务器同步邮件            |
| DNS   | 53/UDP/TCP  | UDP/TCP| 域名解析（查询/区域传输等）       |
| SSH   | 22/TCP      | TCP    | 安全远程登录、命令执行、端口转发  |
| FTP   | 21/TCP      | TCP    | 早期文件传输（明文，现少用）      |

</div>

<div class="text-sm text-gray-5 mt-4">

可以看到：绝大多数“不能丢数据”的应用协议（Web、邮件、远程登录、文件传输）都跑在 **TCP** 上，  
而像 DNS、流媒体、游戏等对延迟敏感、允许少量丢包的场景则更偏好 **UDP** 或在 UDP 上叠加自定义机制。

</div>


---

# 全球 IP 因特网

Internet

网络字节顺序：**大端法**{.text-sky-5}（可能需要相关函数进行转换）

IP 地址：点分十进制表示法（如 `128.2.194.242`）/ 十六进制 IP 地址（`0x8002c2f2`）

Linux 命令 `hostname -i` 可以查看主机的点分十进制地址

注意：**点分十进制表示法是以字符串形式存储的**

---

# 因特网域名

Internet domain name

<div grid="~ cols-2 gap-8">
<div>

域名是多层次的：`blog.imyangty.com` `imyangty.com` `com`

DNS（Domain Name System，域名系统）维护域名集合和 IP 地址的映射

</div>

<div>

![domain](/09-Network/domain.png){.mx-auto}

</div>
</div>

---

# 因特网域名

Internet domain name

<div grid="~ cols-2 gap-8">
<div>

### 域名{.mb-4}

- 一个域名可以解析到多个 IP 地址
- 一个 IP 地址可以对应多个域名
- 某些合法的域名没有映射到任何 IP 地址
- `localhost` 回送地址 `127.0.0.1`

### 端口{.my-4}

表示服务类型，由 `/etc/services` 文件维护

- 22：SSH 远程登录
- 80：HTTP Web 端口
- 443：HTTPS Web 端口

</div>

<div>

![domain](/09-Network/domain.png){.mx-auto}

</div>
</div>


---

# 端口号再理解：服务 vs 进程

Ports in practice

<div grid="~ cols-2 gap-8">
<div text-sm>

- **端口号是 16 位整数**，范围 0–65535
- 在一台主机上：
  - 同一时刻，一个端口号通常只会被一个进程使用
  - 不同进程使用不同端口号来区分自己

常见分类：

- **知名端口（well-known ports）**：0–1023  
  例如 22/ssh，80/http，443/https
- **登记端口（registered ports）**：1024–49151
- **临时端口（ephemeral ports）**：49152–65535  
  客户端发起连接时由内核自动分配，用完就释放

</div>

<div text-sm>

一个 TCP 连接由 **套接字对** 唯一确定：

$$
(\text{客户端 IP} : \text{客户端端口},\; \text{服务器 IP} : \text{服务器端口})
$$

因此：

- 多个客户端可以同时连到同一台服务器的同一端口（例如 80）
- 它们通过 **不同的客户端 IP + 客户端端口** 来区分

这和后面要讲的“监听描述符 vs 已连接描述符”是一致的。

</div>
</div>

---

# 网络安全与常见攻击

Network security

<div grid="~ cols-2 gap-8">
<div text-sm>

典型攻击方式：

- **恶意软件（Malware）**
  - 病毒、蠕虫、木马、间谍软件
  - 感染主机、窃取数据、加入僵尸网络（botnet）
- **窃听与嗅探（Sniffing）**
  - 在共享介质（早期以太网、WiFi）上抓取所有经过的包
  - 未加密的密码、Cookie 等都有可能被看到
- **伪造（Spoofing）**
  - 伪造源 IP 或域名，假装是“可信对象”
- **拒绝服务攻击（DoS / DDoS）**
  - 用大量恶意流量淹没服务器或链路
  - 导致正常请求无法被处理

</div>

<div text-sm>

典型防御手段：

- **机密性**：加密（HTTPS / TLS、VPN）
- **认证**：密码、双因素、数字证书，确认“你是谁”
- **完整性校验**：数字签名、防止内容被悄悄篡改
- **访问控制 / 防火墙**：只允许可信来源 / 端口通过
- **入侵检测 / 流量监控**：及时发现 DoS、扫描等异常行为

</div>
</div>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q6：回想一下最近新闻里的某一次网络攻击事件，你能从上面的分类中，给它“归类”吗？如果你是网站运维，你会采取哪些防御措施？

</div>

---

# 互联网分层协议回顾

Internet protocol stack

<div grid="~ cols-2 gap-8">
<div text-sm>

经典五层模型（自上而下）：

1. **应用层（Application）**
   - 定义应用数据长什么样、完成什么任务
   - HTTP、DNS、SMTP、FTP……
2. **传输层（Transport）**
   - 在主机上的 **进程与进程之间** 传输数据
   - TCP（可靠字节流）、UDP（尽力而为数据报）
3. **网络层（Network）**
   - 在 **主机与主机之间** 选路径、转发分组
   - IP、路由协议（OSPF、BGP）

</div>

<div text-sm>

4. **链路层（Link）**
   - 相邻网络节点之间的帧传输
   - 以太网、WiFi、PPP …
5. **物理层（Physical）**
   - 比特在具体媒介上的传输方式
   - 电压、电平、调制方式、光脉冲……

在 CSAPP 的视角下：

- 我们写的 **网络程序** 主要生活在 **应用层**
- 通过 **套接字（socket）** 使用操作系统提供的 **传输层服务（TCP/UDP）**

</div>
</div>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q7（1）：任选一次“从浏览器打开网页”的过程，试着用这五层模型描述一下：每一层大概在做什么事？

</div>

---

# 封装与解封装：数据在层间怎么走？

Encapsulation

<div grid="~ cols-2 gap-8">
<div text-sm>

发送端逐层 **加头部（Header）**：

- 应用层：生成消息 `M`
- 传输层：加上传输头 `Ht` → 段（segment） `[Ht | M]`
- 网络层：加上网络头 `Hn` → 数据报（datagram） `[Hn | Ht | M]`
- 链路层：加上链路头 `Hl` → 帧（frame） `[Hl | Hn | Ht | M]`

在每一层，协议只关心自己加的那个头，以及上一层交给它的“有效载荷”。

</div>

<div text-sm flex flex-col justify-center>

接收端反过来做 **解封装**：

- 链路层：检查并去掉 `Hl`，把 `[Hn | Ht | M]` 交给网络层
- 网络层：根据 `Hn` 做路由，最终在目的主机去掉 `Hn`
- 传输层：根据 `Ht` 找到正确的 socket，去掉 `Ht`
- 应用层：拿到原始消息 `M`，交给应用程序处理

这就是 ICS22 里那套“套娃式”封装 / 解封装的过程。

</div>
</div>

<div class="text-sm text-gray-5 mt-4">

研讨题 Q7（2）：结合上一页的五层模型，你能在纸上画出一次从客户端到服务器的“封装 → 路由转发 → 解封装”的流程图吗？

</div>

---

# 套接字

Socket

套接字（Socket）：提供了一层抽象，让网络 I/O 对于进程而言就像文件 I/O 一样，可以类比文件描述符。

<span class="text-sm text-gray-5">

然而，套接字还是与传统的文件 I/O 有所差异，在使用前需要调用一些特殊函数

</span>

套接字是连接的一个 **端点**{.text-sky-5}，一对套接字组成一个连接。

套接字地址形如 `(IP 地址:端口号)`

套接字对形如 `(客户端 IP:客户端端口, 服务端 IP:服务端端口)`，其唯一确定了一个连接。

![socket_pair](/09-Network/socket_pair.png){.mx-auto.h-30}

<!-- 

展示 Surge

 -->

---

# 套接字接口

Socket interface

<div grid="~ cols-3 gap-6">
<div>

### 类型定义


套接字接口是一组函数，和 Unix I/O 函数结合创建网络应用。

`sin` 前缀：Socket Internet

IP 地址结构中存放的地址总是以（大端法）网络字节顺序存放的

</div>

<div col-span-2>

```c
/* IP 地址结构，2B */
struct in_addr {
    uint32_t  s_addr; /* 网络字节顺序的地址 (大端序) */
}; 

/* 套接字地址结构，16B */
typedef struct sockaddr SA;
struct sockaddr {
    uint16_t sa_family; /* 协议族，2B，如 AF_INET（IPv4）、AF_INET6（IPv6） */
    char sa_data[14];   /* 存储具体的地址数据，14B，与协议族相关 */
}; // 整体 16B

/* 套接字地址结构，16B */
struct sockaddr_in {
    uint16_t sin_family;   /* 协议族 (总是 AF_INET) */
    uint16_t sin_port;     /* 端口号（网络字节序） */
    struct in_addr sin_addr; /* IP 地址（网络字节序） */
    unsigned char sin_zero[8]; /* 填充到 sizeof(struct sockaddr) = 16B */
}; // 兼容 sockaddr，整体 16B

```

</div>
</div>


---

# 套接字接口

Socket interface

<div grid="~ cols-3 gap-8">
<div text-sm>

### 客户端{.mb-4}

- `getaddrinfo`：获取地址信息
- `socket`：创建套接字
- `connect`：连接到服务器
- `rio_writen`：发送 $n$ 字节数据
- `rio_readlineb`：读取一行数据
- `close`：关闭套接字

</div>

<div col-span-2>

![socket_interface](/09-Network/socket_interface.png){.mx-auto}

</div>
</div>

---

# 套接字接口

Socket interface

<div grid="~ cols-3 gap-8">
<div text-sm>

### 服务器{.mb-4}

- `getaddrinfo`：获取地址信息
- `socket`：创建套接字
- `bind`：绑定套接字到地址
- `listen`：监听套接字
- `accept`：接受连接
- `rio_readlineb`：读取一行数据
- `rio_writen`：发送 $n$ 字节数据
- `close`：关闭套接字

</div>

<div col-span-2>

![socket_interface](/09-Network/socket_interface.png){.mx-auto}

</div>
</div>

---

# 套接字接口

Socket interface

为什么要搞得这么复杂？

<v-clicks>

网络编程不像文件 I/O 那么 “确定”{.text-sky-5.font-bold}

对于客户端：

</v-clicks>

<v-clicks text-sm>

1. 为了得到连接对方的信息，我们需要先用 `getaddrinfo` 获取对方的网络连接信息。
2. 然后我们需要用 `socket` 创建一个套接字，但是这只是填入了对方的基础信息，我们不确定对方的状态，所以此时套接字是 **不可用**{.text-sky-5} 的。
3. 我们需要调用 `connect` 来尝试建立连接，若能正常建立，则得知此时套接字是 **可用**{.text-sky-5} 的。
4. 然后我们就可以调用 `rio_writen` 和 `rio_readlineb` 来发送和接收数据了。
5. 最后我们调用 `close` 关闭套接字，终止连接，释放描述符使之可以被重用。

</v-clicks>


---

# 套接字接口

Socket interface

对于服务端：

<v-clicks text-sm>

1. 为了能够参与到网络连接，我们需要先用 `getaddrinfo` 获取自己的网络连接信息。
2. 然后我们需要用 `socket` 创建一个套接字，用于监听客户端的连接请求，此时，这个套接字依旧是 **不可用**{.text-sky-5} 的。
3. 调用 `bind` 将套接字绑定到获取到的地址信息上，声明对某个端口（如 HTTP 对 80 端口）的占用，这样套接字就可以使用了。
4. 调用 `listen` 来将之转为监听套接字，这样套接字就可以监听客户端的连接请求了。
5. 接下来，我们调用 `accept` 来从监听序列中取出一个套接字，这代表我们接受了客户端的连接请求，这样，我们就可以使用这个套接字和客户端进行通信了。
6. 调用 `rio_readlineb` 和 `rio_writen` 来发送和接收数据。
7. 当读到客户端调用 `close` 关闭连接的信息后，我们也调用 `close` 关闭套接字，从而允许这个套接字被重用。

</v-clicks>

<div class="text-sm text-gray-5">

<v-clicks>

你可能会疑惑，为什么不能合并 `bind` 和 `listen`？它们似乎都只在服务端使用。

- `bind` 代表绑定，它使得侦听端口固定了下来。在客户端不需要这个过程，每次连接随便分配一个可用端口即可。
- `listen` 代表监听，它让套接字从主动套接字变为被动套接字。


</v-clicks>

</div>

---

# 套接字接口

Socket interface


`getaddrinfo` 函数用于获取地址信息


```c
int getaddrinfo(const char *host, const char *service, const struct addrinfo *hints, struct addrinfo **res);
void freeaddrinfo(struct addrinfo *res);
```

<div grid="~ cols-2 gap-8">
<div text-sm>

- `host`：主机名，可以是 `127.0.0.1` 或 `localhost`，域名或点分制都可以，甚至可以是 `NULL`，代表监听本机通配地址 `0.0.0.0`（监听所有网络接口）
- `service`：服务名，可以是 `80`（十进制端口号）或 `http`，端口号或服务名都可以
- `hints`：提示信息，控制行为
- `res`：地址信息链表，存放结果

`ai` 是 `addrinfo` 的缩写

`canonname` 全称 canonical name，即规范、权威名

</div>

<div>

![getaddrinfo_res](/09-Network/getaddrinfo_res.png){.mx-auto.h-70}

</div>
</div>

---

# 套接字接口

Socket interface

`socket` 函数用于创建可供读写的套接字。

```c
int socket(int domain, int type, int protocol);
```

- `domain`：协议族，如 `AF_INET` / `AF_INET6`
- `type`：套接字类型，如 `SOCK_STREAM` / `SOCK_DGRAM`
- `protocol`：协议，如 `0`

使用 `getaddrinfo` 获取地址信息后，可以自动生成这些所需参数。

---

# 套接字接口

Socket interface

`connect` 函数用于建立和服务器的连接。

```c
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`：套接字描述符
- `addr`：套接字地址
- `addrlen`：套接字地址长度

<div text-sky-5>

注意，`connect` 函数会阻塞，直到连接建立成功或失败。

而且还要注意，`connect` 是否返回，与服务器是否 `accept` 无关。

前者返回 `0` 表明建立了连接，后者代表开始服务器处理这个连接。

</div>

---

# 套接字接口

Socket interface

`bind` 函数用于在服务器将套接字绑定到地址。它声明对某个端口（如 HTTP 对 80 端口）的占用。

```c
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`：套接字描述符
- `addr`：套接字地址
- `addrlen`：套接字地址长度

依旧是最好使用 `getaddrinfo` 获取地址信息后，可以自动生成这些所需参数。

---

# 套接字接口

Socket interface

`listen` 函数用于在服务器将套接字转为监听套接字。该端口必须首先被声明占用（`bind`）。

```c
int listen(int sockfd, int backlog);
```

- `sockfd`：套接字描述符
- `backlog`：连接队列长度，**表示服务器最多可以同时处理多少个连接。**{.text-sky-5}

调用完 `listen` 后，对于连接请求，会放入队列。

回忆：这是一个队列，建立连接后，我们先放进去，但不代表我们立即调用 `accept` 来处理。

监听描述符只被创建一次，存在于整个生命周期。{.text-sky-5}

---

# 套接字接口

Socket interface

`accept` 函数用于在服务器接受连接。

```c
int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

- `sockfd`：监听套接字描述符
- `addr`：客户端套接字地址会被填写在这里
- `addrlen`：客户端套接字地址长度

从队列取出连接请求，如果决定接受，则为该连接分配新的描述符 `fd`

<div text-sm>

- 多个连接存在时，每个连接有各自的 `fd`，但共用一个端口号，即监听时的端口号。
- 系统内部用 `(源 IP 地址，源端口号，目的 IP 地址，目的端口号)` 区分连接
- 因此，即使多个连接共用服务器端口号，也能区分
- 即使原先监听描述符被提前关闭，也不影响已经建立的连接。

</div>

已连接描述符只存在于为一个客户端服务的过程中。{.text-sky-5}

---

# 监听描述符 vs 已连接描述符

listen fd vs connected fd

![listen_fd_vs_connected_fd](/09-Network/listen_fd_vs_connected_fd.png){.mx-auto}

<!-- 

看 Surge

-->

---

# 套接字接口辅助函数

Socket interface helper functions

<div grid="~ cols-2 gap-8">
<div>

### `open_clientfd`

```c
int open_clientfd(char *hostname, char *port);
```

客户端调用 `open_clientfd` 函数建立与服务器的连接，该服务器运行在主机 `hostname` 上，在端口号 `port` 上监听连接请求。

等价于 `socket` + `connect`

</div>

<div>

### `open_listenfd`

```c
int open_listenfd(char *port);
```

服务端调用 `open_listenfd` 函数，服务器创建一个监听描述符，准备好接收连接请求。

等价于 `socket` + `bind` + `listen`


</div>
</div>


---

# Web 编程与应用层概览

Web application

- 前面我们已经学会了：  
  用 **套接字（socket）+ TCP** 在两端进程之间传字符串、构造 echo server/client。
- 这一节开始，把这些能力“包装”成真正的 **Web 服务**：
  - 使用 **HTTP 协议** 在浏览器与服务器之间传输数据
  - 处理 **静态内容**（HTML / 图片等文件）
  - 生成 **动态内容**（程序运行产生的页面）
  - 理解 **CGI / 代理（proxy）/ 防火墙（firewall）** 等组件在体系结构中的位置
- 你可以把它理解为：  
  > “在我们已经掌握的 TCP 套接字之上，再加一层应用层协议和应用逻辑。”

<!-- :contentReference[oaicite:0]{index=0} -->

---

# Web 服务器的基本工作模式

Basic

> HTTP = 应用层协议；底层还是我们熟悉的 **TCP 字节流**

<div grid="~ cols-2 gap-8">
<div>

典型交互过程：

1. 浏览器（client）向服务器发起 TCP 连接（默认端口 80 / 443）
2. 在这条 TCP 连接上发送 **HTTP 请求报文**
3. 服务器解析请求、找到对应资源（文件 / 程序），生成 **HTTP 响应报文**
4. 把响应发回浏览器，浏览器渲染页面
5. 一段时间后，双方关闭连接（短连接 / 长连接均可）

</div><div>

可以用简单示意图表示：

- Web 客户端（浏览器）
  - 通过 TCP 发送请求
- Web 服务器进程
  - 监听端口，`accept` 连接
  - 解析 HTTP 请求 → 决定返回什么内容 → 通过 `write` 回给客户端

</div></div>
---

# Web 内容与 MIME 类型

Web content and MIME type


<div grid="~ cols-2 gap-8">

<div>

Web 服务器给浏览器返回的是 **一串字节 + 类型描述**：

- 内容本身：任意字节序列
- MIME type：告诉浏览器“这段字节应该怎么解释”

常见 MIME 类型示例：

- `text/html`：HTML 文档
- `text/plain`：纯文本
- `image/png`：PNG 图片
- `image/jpeg`：JPEG 图片
- `application/json`：JSON 数据

</div>

<div>

在 HTTP 响应中，通常通过头部字段声明，例如：

```http
Content-Type: text/html; charset=utf-8
Content-Length: 1234
```



浏览器根据 `Content-Type` 决定是渲染为网页、下载文件，还是交给插件处理。


</div>
</div>

---

# 静态内容

static content 

<div grid="~ cols-2 gap-8">

<div>

* 内容预先存在于服务器的文件系统中
* 请求到来时，只是 **读文件 → 按字节原样发送**
* 例如：

  * `.html` 页面
  * `.css` 样式表
  * `.js` 脚本文件
  * 图片、音频、视频等静态资源

</div>
<div>

在简单 Web 服务器（比如 Tiny）里，典型流程：

1. 解析出 URL 的路径部分，例如 `/img/logo.png`
2. 在配置的根目录（document root）下拼出真实文件路径
3. `open` + `read` / `mmap` 文件
4. 发送 HTTP 头（包含 `Content-Type`, `Content-Length`）
5. 发送文件内容

</div></div>

---

# 动态内容

dynamic content

<div grid="~ cols-2 gap-8">

<div>

* 内容由 **程序在请求到来时现算出来**
* 程序根据请求参数、数据库内容、登录状态等生成 HTML / JSON
* 常见情况：

  * 查询成绩、购物车页面、搜索结果
  * RESTful API 返回的 JSON
  
</div>
<div>

在早期/教学场景下，典型实现方式：**CGI（Common Gateway Interface）**

* Web 服务器作为“父进程”
* 收到某类请求时 `fork` 子进程，执行某个可执行文件
* 把请求相关的信息通过 **环境变量 / 标准输入** 传给子进程
* 子进程把 HTTP body + 部分 header 写到 **标准输出**，父进程再转发给客户端

</div>
</div>

---

# URL

Uniform Resource Locator

一个典型 URL：`http://www.cmu.edu:80/index.html`

可以拆成几部分：

<div text-sm>

* 协议（scheme）：`http`
* 主机名（host）：`www.cmu.edu`
* 端口号（port）：`80`（省略时 HTTP 默认为 80，HTTPS 默认为 443）
* 路径（path）：`/index.html`

客户端（浏览器）根据前半部分做出的决定：

* 通过 DNS 把 `www.cmu.edu` 解析成 IP 地址
* 使用 TCP 连接到 `(IP, 80)`，说明要用 HTTP 通信

服务器根据后半部分做出的决定：

* 路径 `/index.html` 通常映射为服务器上的某个文件
* 如果路径落在某个“动态目录”（例如 `/cgi-bin/`）下，则启动相应程序生成动态内容

</div>

---

# HTTP 请求报文结构

HTTP Request

<div text-sm>

最简化的 HTTP 请求由三部分组成：

1. **请求行（request line）**

   ```http
   GET /index.html HTTP/1.1
   ```

2. **若干请求头（request headers）**

   ```http
   Host: www.cmu.edu
   User-Agent: Mozilla/5.0 ...
   Accept: text/html, image/*, */*
   ```

3. **空行 + 可选的请求体（body）**

   ```http

   （这里可能是表单数据、JSON 等）
   ```

* 请求方法常见有：`GET`, `POST`, `HEAD`, `PUT`, `DELETE` 等
* 在 HTTP/1.1 中，`Host` 头是必须的（支持虚拟主机）

</div>

---

# HTTP 响应报文结构

HTTP response

<div grid="~ cols-2 gap-8">

<div text-sm>

HTTP 响应也分三块：

1. **状态行（status line）**

   ```http
   HTTP/1.1 200 OK
   ```

2. **若干响应头（response headers）**

   ```http
   Date: Wed, 05 Nov 2014 17:37:26 GMT
   Server: Apache/2.4.10 (Unix)
   Content-Type: text/html; charset=utf-8
   Content-Length: 4096
   ```

3. **空行 + 响应体（body）**

   ```http

   <html>
     ...
   </html>
   ```

</div>

<div>

常见状态码：

* `200 OK`：请求成功
* `301 Moved Permanently`：资源永久重定向到新的 URL
* `404 Not Found`：找不到资源
* `500 Internal Server Error`：服务器内部出错

</div>
</div>

---

# Tiny Web Server

Tiny

<div leading-tight>

Tiny 是教材里的一个极简 Web 服务器（顺序服务器）：

典型处理流程（伪代码）：

1. `listenfd = open_listenfd(port)`
2. 无限循环：
   1. `connfd = accept(listenfd, ...)`
   2. 读取一行请求行：`GET /path/to/resource HTTP/1.0`
   3. 解析出 method / uri / version
   4. 根据 uri 判断：
      * 若是 **静态内容**：调用 `serve_static`
      * 若是 **动态内容**：调用 `serve_dynamic`
   5. 关闭 `connfd`
   
</div>


---

# 代理

Proxy

<div grid="~ cols-2 gap-8">

<div>

**HTTP 代理** 位于客户端与源站服务器之间：

```text
Client  <--HTTP-->  Proxy  <--HTTP/HTTPS-->  Origin Server
```

* 对客户端来说，代理就像是“服务器”
* 对源站来说，代理又表现为“客户端”

</div>

<div text-sm leading-tight>

常见用途：

* **缓存（caching）**
  * 把常用的静态内容缓存在代理本地，下次用户访问可以直接返回
  * 减少跨国/跨运营商访问的延迟和带宽消耗
* **日志与审计（logging）**
  * 记录访问行为，便于统计与安全分析
* **内容过滤（filtering）**
  * 屏蔽某些站点 / URL / 关键字
* **性能优化 / 转码（transcoding）**
  * 压缩图片、改编视频码率，给移动端省流量

</div>
</div>


---

# NAT 与防火墙

NAT and Firewall

<div grid="~ cols-2 gap-8">

<div text-sm>

现实中的互联网已经与最初“所有主机都能互相直连”的理想模型差别很大：

1. **动态地址分配（DHCP）**
   * 家用路由器 / 校园网网关通过 DHCP 给终端临时分配私有地址
   * 例如：`192.168.1.5`, `10.x.y.z` 等，只在本地网络中有效

2. **NAT（Network Address Translation）/ 家用路由器**
   * 内网多台机器共享一个公网地址
   * 出口设备把报文的源地址、源端口改写成自己的公网 IP + 某个端口
   * 回包时再反向映射回去
  
</div>

<div text-sm>

3. **防火墙（Firewall）**
   * 对经过的报文进行 **过滤和策略控制**
   * 典型作用：
     * 对某些端口/协议/目的地址“封堵”或限速
     * 只允许“从内往外”的连接，拒绝外部主动访问内网主机
   * 企业/学校网关上常见：保护内部服务器和终端不被互联网直接攻击

对于应用程序员来说：

* 需要意识到：你的 socket 程序通常跑在“防火墙后面”
* 主动对外“监听”的服务器，常常需要特殊配置（端口映射 / 反向代理 / 云厂商 SLB）

</div>
</div>

---
layout: cover
class: text-center
coverBackgroundUrl: /09-Network/cover.jpg
---

# Thank you for your listening!


Cat$^2$Fish❤

<style>
  div{
   @apply text-gray-2;
  }
</style>
