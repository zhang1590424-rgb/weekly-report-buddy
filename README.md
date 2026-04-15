# weekly-report-buddy Marketplace

> 飞书周报助手 Claude Code 插件市场

---

## 安装方式（供 Agent 使用）

其他 Claude Code Agent 通过以下两步安装本插件：

```bash
# 第一步：添加 marketplace
/plugin marketplace add zhang1590424-rgb/weekly-report-buddy

# 第二步：安装插件
/plugin install weekly-report-buddy@weekly-report-buddy-marketplace
```

**或一行命令**（如果 Claude Code 版本支持）：

```bash
claude plugin marketplace add zhang1590424-rgb/weekly-report-buddy && claude plugin install weekly-report-buddy@weekly-report-buddy-marketplace
```

---

## 插件功能

| 组件 | 名称 | 触发方式 |
|---|---|---|
| **Command** | `weekly-report-buddy:weekly-report` | 输入 `/weekly-report-buddy:weekly-report` |
| **Skill** | `weekly-report-buddy:progress-summary` | 说"帮我写周报"自动触发 |
| **Agent** | `weekly-report-buddy:insight-advisor` | 主代理生成周报后自动委派审查 |
| **Hook** | `sensitive-scan` | Stop 事件触发，扫描敏感信息 |

---

## 前置依赖

```bash
# 1. 安装飞书 CLI
npm install -g @larksuite/cli

# 2. 安装飞书 Skills
npx skills add larksuite/cli -y -g

# 3. 初始化配置
lark-cli config init --new

# 4. 登录授权
lark-cli auth login --recommend
```

---

## 飞书 CLI 命令依赖

| 命令 | 用途 | 所需 scope |
|---|---|---|
| `lark-cli calendar +agenda` | 获取日历日程 | `calendar:calendar.event:read` |
| `lark-cli task +list` | 获取任务列表 | `task:task:read` |
| `lark-cli docs +search` | 搜索文档 | `docs:document.content:read` |
| `lark-cli docs +create` | 创建飞书文档 | `docx:document:create`, `docx:document:write_only` |

---

## 目录结构

```
weekly-report-buddy/
├── .claude-plugin/
│   ├── marketplace.json          # 本文件定义 marketplace
│   └── (plugin.json 移至下方的 plugins/ 目录)
├── plugins/
│   └── weekly-report-buddy/      # 实际插件
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       ├── skills/
│       ├── hooks/
│       ├── agents/
│       └── scripts/
└── README.md
```

---

## Hook 说明

`hooks/hooks.json` 配置了 `Stop` 事件钩子，在 Claude 完成回复后自动调用 `scripts/sensitive-scan.sh` 扫描敏感信息（营收、GMV、DAU、HC、OKR 等关键词），发现后通过 `additionalContext` 反馈给 Claude 进行标红标注。

脚本路径使用 `${CLAUDE_PLUGIN_ROOT}` 环境变量引用插件根目录。
