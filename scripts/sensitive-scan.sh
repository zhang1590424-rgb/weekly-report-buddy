#!/bin/bash
# sensitive-scan.sh
# 在 Claude 完成周报生成后，扫描输出中的敏感信息
# Hook 事件：Stop（Claude 完成回复时触发）
# 输入：通过 stdin 接收 JSON（包含 session_id, cwd 等）
# 输出：stdout 输出 JSON，通过 additionalContext 将警告信息注入 Claude 上下文

# 读取 stdin
INPUT=$(cat)

# 定义敏感关键词列表
# 可根据实际情况扩展：内部项目代号、营收数字模式、人事变动关键词等
SENSITIVE_PATTERNS=(
  "营收"
  "GMV"
  "DAU"
  "月活"
  "裁员"
  "HC"
  "headcount"
  "OKR"
  "绩效"
  "年终奖"
  "期权"
  "RSU"
  "内部代号"
  "保密"
  "未发布"
)

# 从 Stop 事件的 tool_output 中提取 Claude 的回复内容
# Stop 事件的 stdin 包含 stop_hook_active_tools 等字段
# 我们主要检查当前工作目录下最近生成的文件
FOUND_ITEMS=""

# 扫描当前目录下最近修改的 md 文件（周报草稿）
for file in $(find "$( echo "$INPUT" | jq -r '.cwd' )" -maxdepth 1 -name "*.md" -mmin -5 2>/dev/null); do
  for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    matches=$(grep -n "$pattern" "$file" 2>/dev/null)
    if [ -n "$matches" ]; then
      FOUND_ITEMS="${FOUND_ITEMS}\n⚠️ 文件 ${file} 中发现敏感词「${pattern}」:\n${matches}\n"
    fi
  done
done

# 如果发现敏感信息，通过 additionalContext 注入警告
if [ -n "$FOUND_ITEMS" ]; then
  WARNING="🔴 敏感信息扫描发现以下问题，请在周报中将相关内容标红提醒用户注意：\n${FOUND_ITEMS}\n请将包含上述敏感词的段落用 **🔴[敏感]** 前缀标记，但不要删除内容。"

  # 输出 JSON，通过 additionalContext 反馈给 Claude
  echo "{\"additionalContext\": \"$(echo -e "$WARNING" | sed 's/"/\\"/g' | tr '\n' ' ')\"}"
  exit 0
fi

# 无敏感信息，正常放行
exit 0
