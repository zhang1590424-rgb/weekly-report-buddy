# weekly-report-buddy

> 飞书周报助手 Claude Code 插件

## 安装方式

```bash
claude --plugin-dir https://github.com/<your-username>/weekly-report-buddy
```

或克隆后本地加载：

```bash
git clone https://github.com/<your-username>/weekly-report-buddy
claude --plugin-dir ./weekly-report-buddy
```

## 功能概览

| 组件 | 名称 | 触发方式 |
|---|---|---|
| **Command** | `weekly-report-buddy:weekly-report` | 输入 `/weekly-report-buddy:weekly-report` |
| **Skill** | `weekly-report-buddy:progress-summary` | 说"帮我写周报"自动触发 |
| **Agent** | `weekly-report-buddy:insight-advisor` | 主代理生成周报后自动委派审查 |
| **Hook** | `sensitive-scan` | Stop 事件触发，扫描敏感信息 |

## 前置依赖

插件需要以下环境配置才能正常使用：

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

## 使用方法

### Command 方式
```
/weekly-report-buddy:weekly-report
```

### Skill 方式（推荐）
```
帮我写一下这周的周报
```

### 查看 Agent 列表
```
/agents
```

## 插件结构

```
weekly-report-buddy/
├── .claude-plugin/
│   └── plugin.json          # 插件清单
├── commands/
│   └── weekly-report.md     # Command 触发器
├── skills/
│   └── progress-summary/
│       └── SKILL.md         # Skill 触发器
├── hooks/
│   └── hooks.json           # Hook 配置（Stop 事件）
├── agents/
│   └── insight-advisor.md   # 子 Agent
├── scripts/
│   └── sensitive-scan.sh    # 敏感信息扫描脚本
└── README.md
```

## 飞书 CLI 命令依赖

| 命令 | 用途 | 所需 scope |
|---|---|---|
| `lark-cli calendar +agenda` | 获取日历日程 | `calendar:calendar.event:read` |
| `lark-cli task +list` | 获取任务列表 | `task:task:read` |
| `lark-cli docs +search` | 搜索文档 | `docs:document.content:read` |
| `lark-cli docs +create` | 创建飞书文档 | `docx:document:create`, `docx:document:write_only` |

## Hook 说明

`hooks/hooks.json` 配置了 `Stop` 事件钩子，在 Claude 完成回复后自动调用 `scripts/sensitive-scan.sh` 扫描敏感信息（营收、GMV、DAU、HC、OKR 等关键词），发现后通过 `additionalContext` 反馈给 Claude 进行标红标注。

脚本路径使用 `${CLAUDE_PLUGIN_ROOT}` 环境变量引用插件根目录。
