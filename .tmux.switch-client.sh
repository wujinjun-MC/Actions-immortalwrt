#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# 切换到列表中的上一个/下一个 tmux 会话 (按创建时间排序)
# 灵感来自：https://mskelton.dev/bytes/20240902085609
# -----------------------------------------------------------------------------

# 检查是否在 tmux 会话内部
if [ -z "$TMUX" ]; then
    echo "错误：此脚本必须在 tmux 会话内部运行。" >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# 获取当前 tmux 信息，用于确保操作正确的服务器
# TMUX 变量格式通常为 /tmp/tmux-1000/default,PID,0
# -----------------------------------------------------------------------------
# 从 $TMUX 变量中提取 socket 路径 (或使用默认值)
TMUX_SOCKET_PATH=""
if [[ "$TMUX" =~ ^([^,]+), ]]; then
    TMUX_SOCKET_PATH="-S ${BASH_REMATCH[1]}"
fi
# 如果需要，可以从环境变量中获取 TMUX_PANE 的 PID
# 并在 tmux 命令中添加 -u (如果需要用户名隔离，但通常 socket 路径已处理)
# 这里的重点是使用 TMUX_SOCKET_PATH 来保证操作正确。

# 获取输入参数: 1 为下一个会话，-1 为上一个会话
DIRECTION="$1"

if [ "$DIRECTION" != "1" ] && [ "$DIRECTION" != "-1" ]; then
    echo "用法: $0 [1|-1]" >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# 核心逻辑
# -----------------------------------------------------------------------------

# 1. 列出所有会话，按创建时间排序，只保留名称 (会话名称不能包含空格)
# 格式: #{session_created} #{session_name}
sessions=$(tmux $TMUX_SOCKET_PATH list-sessions -F "#{session_created} #{session_name}" | sort -n | awk '{print $2}')

# 2. 获取当前会话名称
current_session=$(tmux $TMUX_SOCKET_PATH display-message -p '#{session_name}')

# 3. 将会话列表转换为 bash 数组
#mapfile -t session_array <<< "$sessions"
session_array=()
while IFS= read -r line; do
    session_array+=("$line")
done <<< "$sessions"
total_sessions=${#session_array[@]}

# 4. 查找当前会话在数组中的索引
current_index=-1
for i in "${!session_array[@]}"; do
    if [[ "${session_array[$i]}" == "$current_session" ]]; then
        current_index=$i
        break
    fi
done

# 5. 计算目标索引 (使用模运算实现循环)
if [ "$current_index" -eq -1 ]; then
    # 如果找不到当前会话，这通常不应该发生
    exit 0
fi

if [ "$DIRECTION" == "1" ]; then
    # 下一个会话: (当前索引 + 1) % 总数
    next_index=$(( (current_index + 1) % total_sessions ))
else
    # 上一个会话: (当前索引 - 1 + 总数) % 总数
    next_index=$(( (current_index - 1 + total_sessions) % total_sessions ))
fi

# 6. 获取目标会话名称
target_session="${session_array[$next_index]}"

# 7. 切换到目标会话
if [ -n "$target_session" ]; then
    tmux $TMUX_SOCKET_PATH switch-client -t "$target_session"
fi
