# cd /tmp
# wget -q https://www.cpolar.com/static/downloads/releases/3.3.18/cpolar-stable-linux-amd64.zip -O cpolar.zip && unzip cpolar.zip
# Helper function: "tcp://ip:port" to "ssh -p port ip"
tcp_to_ssh() {
    # 检查参数数量
    if [ "$#" -ne 2 ]; then
        echo "用法: tcp_to_ssh <用户名> <tcp://ip:port>"
        return 1
    fi

    local user=$1
    local url=$2
    local key_option=""

    # 检查环境变量 myssh_privatekey 是否存在且文件可读
    if [[ -v myssh_privatekey ]]; then
        echo "正在尝试使用私钥文件"
        if [ -f "$myssh_privatekey" ]; then
            key_option="-i $myssh_privatekey"
        else
            echo "警告: 私钥文件 $myssh_privatekey 未找到，将不使用私钥。"
        fi
    fi

    # 解析 URL
    local clean_url="${url#tcp://}"

    # 提取 IP 和 端口
    # ${clean_url%:*} 删掉最后一个冒号之后的内容 (提取IP)
    # ${clean_url##*:} 删掉最后一个冒号之前的内容 (提取端口)
    local ip="${clean_url%:*}"
    local port="${clean_url##*:}"

    # 如果没有端口号（即输入不包含冒号），默认设为 22
    if [ "$ip" == "$port" ]; then
        port=22
    fi

    # 构建命令
    # 注意: $key_option 不需要加引号，以便在为空时被忽略
    echo "ssh $key_option -p $port $user@$ip"
}

if ! which cpolar
then
    while ! curl -sL https://git.io/cpolar | sed '/download_cpolar() {/a RELEASE_VERSION=latest' | sudo bash
    do
        sleep 5
    done
fi
mkdir -p ~/.ssh
echo "$MY_SSH_PUB_KEY" >> ~/.ssh/authorized_keys

echo "Starting tunnel..."
env > ~/current_env.txt

if [ "$CPOLAR_TOKEN_TYPE"x = "TOKEN_1"x ]
then
    cpolar authtoken "$CPOLAR_TOKEN_1"
elif [ "$CPOLAR_TOKEN_TYPE"x = "TOKEN_2"x ]
then
    cpolar authtoken "$CPOLAR_TOKEN_2"
elif [ "$CPOLAR_TOKEN_TYPE"x = "TOKEN_3"x ]
then
    cpolar authtoken "$CPOLAR_TOKEN_3"
else
    cpolar authtoken "$CPOLAR_TOKEN_1"
fi

echo "Pleased wait and check tcp tunnel on your dashboard at https://dashboard.cpolar.com/status"

# echo "Remove /tmp/keep-term to continue"
cpolar tcp 22 -daemon on -dashboard on -inspect-addr 0.0.0.0:4040 -log /tmp/cpolar.log -log-level INFO & # tail -F ~/test.log &
echo "当前设置: $CPOLAR $MENUCONFIG_COLOR $CPOLAR_TOKEN_TYPE larger:$USE_LARGER single_thread:$FORCE_SINGLE_THREAD ccache:$USE_CCACHE"
echo "echo \"当前设置: $CPOLAR $MENUCONFIG_COLOR $CPOLAR_TOKEN_TYPE larger:$USE_LARGER single_thread:$FORCE_SINGLE_THREAD ccache:$USE_CCACHE\"" >> ~/.bash_profile
echo "$OPENWRT_PATH/custom_release_notes.txt 写你的自定义发布说明"
echo "echo $OPENWRT_PATH/custom_release_notes.txt 写你的自定义发布说明" >> ~/.bash_profile

# 定义目标源码路径 (根据你提供的容器路径)
TARGET_PATH="/home/runner/work/Actions-immortalwrt/Actions-immortalwrt/openwrt"
echo "Enter source code directory: $TARGET_PATH"

# 写入自动化逻辑到 .bash_profile
cat << 'EOF' >> ~/.bash_profile
# 检查是否在 Remote 会话中，且当前目录是家目录
if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ]; then
    if [ "$PWD" = "$HOME" ]; then
        # 这里的路径会自动替换为上面定义的变量值
        SOURCE_DIR="/home/runner/work/Actions-immortalwrt/Actions-immortalwrt/openwrt"
        if [ -d "$SOURCE_DIR" ]; then
            cd "$SOURCE_DIR"
            echo -e "\033[32m[Cpolar Debug] 已自动跳转至源码目录: $SOURCE_DIR\033[0m"
            echo -e "\033[33m提示: 输入 'make menuconfig' 进行配置，完成后输入 'rm /tmp/keep-term' 退出\033[0m"
        fi
    fi
fi
EOF

# 一键进入 menuconfig
cat << 'EOF' >> ~/.bash_profile
enter_menuconfig() {
    local target="/home/runner/work/Actions-immortalwrt/Actions-immortalwrt/openwrt"
    cd "$target"
EOF
echo "    tmux new-session -A -s config \"make MENUCONFIG_COLOR=$MENUCONFIG_COLOR menuconfig\"" >> ~/.bash_profile
cat << 'EOF2' >> ~/.bash_profile
}

# 执行函数
#enter_menuconfig
EOF2

# 一键 kill Cpolar
cat << 'EOF' >> ~/.bash_profile
kill_cpolar() {
    local kill_cmd="killall cpolar"
    read -e -p "确认杀死 cpolar 进程 (执行命令 $kill_cmd) ? 一旦杀死则无法再重新开启。请输入 \"kill\" 确认: " kill_confirm
    if [ "$kill_confirm"x = "kill"x ]; then
        eval "$kill_cmd"
    fi
}
EOF

sleep 10
if [ "$1"x != "nonblock"x ]
then
    if ! [[ -f /tmp/keep-term ]]
    then
        export KEEPALIVE_FLAG_FILE=/tmp/keep-term
    else
        export KEEPALIVE_FLAG_FILE=$(mktemp)
    fi
    touch "$KEEPALIVE_FLAG_FILE"
    echo "Remove $KEEPALIVE_FLAG_FILE to continue"
    echo "echo Remove $KEEPALIVE_FLAG_FILE to stop blocking next step"  >> ~/.bash_profile
    while true
    do
        if ! [[ -f "$KEEPALIVE_FLAG_FILE" ]]
        then
            echo "Keepalive file removed, continue."
            break
        elif ! pgrep cpolar &>/dev/null
        then
            echo "Cpolar exited, continue."
            break
        fi
        echo "快速连接: $(tcp_to_ssh runner $(grep "Tunnel established at" /tmp/cpolar.log | tail -1 | cut -d " " -f 9 | tr -d \"))"
        sleep 10
    done
fi
