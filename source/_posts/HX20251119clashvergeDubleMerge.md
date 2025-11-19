---
title: Clash Verge 进阶玩法：双机场合并 + AI 专线精准分流指南
tags:
  - vpn
categories:
  - technique
  - vpn
poster:
  topic: 双机场合并与AI精准分流
  headline: Clash Verge 进阶玩法
  caption: 自动化分流，告别手动切换
  color: blue
description: 本文介绍如何在 Clash Verge 中合并双机场订阅，实现自动化分流，确保 AI 服务稳定访问。
abbrlink: 45371
date: 2025-11-19 19:24:45
cover:
banner:
sticky:
mermaid:
katex:
mathjax:
topic:
author:
references:
comments:
indexing:
breadcrumb:
leftbar:
rightbar:
h1:
type:
---


---


**背景需求：**
很多朋友手头都有两个机场订阅：
1.  **主力机场（如pianyijichang）：** 流量大、便宜，台湾/香港节点速度快，适合看 YouTube、Netflix 和日常冲浪。
2.  **备用/高端机场（如 AIjichangCloud）：** 拥有原生 IP，能解锁各种 AI 限制，适合专门访问 Google AI Studio、Gemini、OpenAI。

**痛点：** 简单的合并订阅会导致节点混杂，如果不手动切换，AI 请求很容易走到台湾节点导致报错（如 Region not supported）。

今天分享一个在 **Clash Verge (Rev)** 中实现“双订阅合并 + 自动化分流”的完美方案。

---

### 第一步：创建本地配置，合并并标记节点

要在脚本中区分两个机场，最稳妥的办法是在拉取订阅时给节点加上“前缀标签”。

新建一个 **Local** 类型的配置，使用 `proxy-providers` 引入订阅，并利用 `override` 功能强行加前缀：

```yaml
proxy-providers:
  # 机场 A：主力流量
  pianyijichang:
    type: http
    url: "你的订阅链接"
    path: ./profiles/pianyijichang.yaml
    override:
      additional-prefix: "[pianyijichang]" # 关键步骤：给它打上标签

  # 机场 B：AI 专用
  AIjichang:
    type: http
    url: "你的订阅链接"
    path: ./profiles/AIjichang.yaml
    override:
      additional-prefix: "[AIjichang]"   # 关键步骤：给它打上标签
```

### 第二步：使用脚本进行正则筛选

在 Clash Verge 的 **全局扩展脚本** 中，利用正则表达式根据刚才的标签把节点分配给不同的策略组。

**核心逻辑：**
*   **YouTube/通用组**：只允许名字里含 `[pianyijichang]` 的节点进入。
*   **AI 组**：只允许名字里含 `[AIjichang]` 且含 `美国` 的节点进入。

代码片段（修改 `config["proxy-groups"]` 部分）：

```javascript
// YouTube 或 通用 策略组
{
  "name": "YouTube",
  "type": "select",
  // 正则：必须包含 [pianyijichang]
  "filter": "(?i)\\[pianyijichang\\]", 
  ...
},

// AI 专用策略组
{
  "name": "AI",
  "type": "url-test",
  // 正则：必须包含 [AIjichang] 并且是 美国 节点
  "filter": "(?i)\\[AIjichang\\].*(美国|US|United States)", 
  ...
}
```

### 第三步：填补规则漏洞（关键！）

很多规则集（Rule Provider）对 Google AI Studio 的覆盖并不完全。你会发现主页走了 AI 节点，但后台 API 请求（`alkalimakersuite` 等）却走了普通节点，导致跨区报错。

需要在脚本的 `myProxyRules` 中手动补全这些“漏网之鱼”：

```javascript
const myProxyRules = [
  // 强制 Google AI Studio 后端走 AI 组
  "DOMAIN-KEYWORD,alkalimakersuite,AI",
  "DOMAIN-KEYWORD,developerprofiles,AI",
  // 强制生成式 AI API
  "DOMAIN-SUFFIX,generativelanguage.googleapis.com,AI",
  // 强制 Gemini/Bard
  "DOMAIN-SUFFIX,gemini.google.com,AI",
  "DOMAIN-SUFFIX,bard.google.com,AI"
];
```

### 效果总结

配置完成后，你的 Clash 面板将非常清爽：
*   看 YouTube 自动走pianyijichang（台湾），速度快且省钱。
*   一旦打开 aistudio.google.com 或调用 Gemini API，自动无感切换到 AIjichangCloud（美国），极其稳定。
*   再也不用手动切来切去了！