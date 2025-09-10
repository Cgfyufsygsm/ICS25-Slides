# ICS 2025 Fall Slides

我的 2025 年秋季学期 ICS 小班课的课件。

基于 [Slidev](https://sli.dev/) 构建，利用 Github Pages 部署[于此](https://blog.imyangty.com/ICS25-Slides/)

编写和部署参考了 [Arthals-ICS-Slides](https://github.com/zhuozhiyongde/Arthals-ICS-Slides)。

## 使用

你需要首先安装 git 和 npm。

```bash
git clone https://github.com/Cgfyufsygsm/ICS25-Slides.git
cd ICS25-Slides
npm install
```

如想看某一章的内容，可将（如第 00 章 Introduction 部分）复制到 `./slides.md`，然后运行 `npm run dev`。比如

```bash
cp pages/00-Introduction.md slides.md
npm run dev
```