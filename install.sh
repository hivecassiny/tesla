#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认语言设置为中文
LANG="en"

# 检查语言参数
if [ "$1" = "lang=en" ]; then
    LANG="en"
elif [ "$1" = "lang=zh" ]; then
    LANG="zh"
fi

# 获取版本号
VERSION=$2

# 多语言文本定义 - 按语言分组
declare -A TEXTS

# 英文文本
TEXTS+=(
    # 公共文本
    ["error_root_en"]="Error: This script must be run as root!"
    ["menu_title_en"]="Teslaminer Service Management Script"
    ["press_any_key_en"]="Press any key to continue..."
    ["invalid_option_en"]="Invalid option, please try again!"
    ["exit_en"]="Exiting script."
    
    # 菜单选项
    ["menu_install_en"]="Install TeslaMiner service"
    ["menu_start_en"]="Start TeslaMiner service"
    ["menu_stop_en"]="Stop TeslaMiner service"
    ["menu_restart_en"]="Restart TeslaMiner service"
    ["menu_status_en"]="View service status"
    ["menu_uninstall_en"]="Uninstall TeslaMiner service"
    ["menu_exit_en"]="Exit"
    
    # 安装相关
    ["socket_limit_en"]="Setting system socket connection limit..."
    ["socket_set_en"]="System socket connection limit set to 1048576"
    ["socket_ok_en"]="Socket connection limit is already high enough (current: %s)"
    ["downloading_en"]="Downloading TeslaMiner..."
    ["download_fail_en"]="Download failed! Please check network connection or URL."
    ["extracting_en"]="Extracting files..."
    ["error_inner_tar_en"]="Error: Inner package teslaminerkernellinux.tar.gz not found"
    ["error_bin_en"]="Error: Executable file %s not found"
    ["installing_en"]="Installing TeslaMiner service..."
    ["install_done_en"]="TeslaMiner service installed successfully!"
    ["install_dir_en"]="Installation directory:"
    ["service_status_en"]="Service status:"
    ["already_installed_en"]="Error: TeslaMiner service is already installed!"
    ["uninstall_first_en"]="Please uninstall first or use restart/stop functions"
    
    # 卸载相关
    ["uninstalling_en"]="Uninstalling TeslaMiner service..."
    ["uninstalled_en"]="TeslaMiner service uninstalled!"
    ["not_installed_en"]="Error: TeslaMiner service is not installed, nothing to uninstall!"
    
    # 服务控制
    ["starting_en"]="Service started!"
    ["already_running_en"]="Service is already running!"
    ["stopping_en"]="Service stopped!"
    ["already_stopped_en"]="Service is already stopped!"
    ["restarting_en"]="Service restarted!"
)

# 中文文本
TEXTS+=(
    # 公共文本
    ["error_root_zh"]="错误: 此脚本必须以root用户身份运行!"
    ["menu_title_zh"]="TeslaMiner 服务管理脚本"
    ["press_any_key_zh"]="按任意键继续..."
    ["invalid_option_zh"]="无效选项，请重新输入!"
    ["exit_zh"]="退出脚本."
    
    # 菜单选项
    ["menu_install_zh"]="安装 TeslaMiner 服务"
    ["menu_start_zh"]="启动 TeslaMiner 服务"
    ["menu_stop_zh"]="停止 TeslaMiner 服务"
    ["menu_restart_zh"]="重启 TeslaMiner 服务"
    ["menu_status_zh"]="查看服务状态"
    ["menu_uninstall_zh"]="卸载 TeslaMiner 服务"
    ["menu_exit_zh"]="退出"
    
    # 安装相关
    ["socket_limit_zh"]="正在设置系统socket连接上限..."
    ["socket_set_zh"]="系统socket连接上限已设置为1048576"
    ["socket_ok_zh"]="系统socket连接上限已经足够高 (当前: %s)"
    ["downloading_zh"]="正在下载TeslaMiner..."
    ["download_fail_zh"]="下载失败! 请检查网络连接或URL是否正确."
    ["extracting_zh"]="正在解压文件..."
    ["error_inner_tar_zh"]="错误: 未找到内部压缩包teslaminerkernellinux.tar.gz"
    ["error_bin_zh"]="错误: 未找到可执行文件 %s"
    ["installing_zh"]="正在安装TeslaMiner服务..."
    ["install_done_zh"]="TeslaMiner服务安装完成!"
    ["install_dir_zh"]="安装目录:"
    ["service_status_zh"]="服务状态:"
    ["already_installed_zh"]="错误: TeslaMiner服务已经安装!"
    ["uninstall_first_zh"]="请先卸载或使用重启/停止功能"
    
    # 卸载相关
    ["uninstalling_zh"]="正在卸载TeslaMiner服务..."
    ["uninstalled_zh"]="TeslaMiner服务已卸载!"
    ["not_installed_zh"]="错误: TeslaMiner服务未安装，无需卸载!"
    
    # 服务控制
    ["starting_zh"]="服务已启动!"
    ["already_running_zh"]="服务已经在运行中!"
    ["stopping_zh"]="服务已停止!"
    ["already_stopped_zh"]="服务已经停止!"
    ["restarting_zh"]="服务已重启!"
)

# 如果需要添加第三种语言(如西班牙语)，可以这样添加:
# TEXTS+=(
#    ["error_root_es"]="Error: ¡Este script debe ejecutarse como root!"
#    ["menu_title_es"]="Script de gestión de servicio TeslaMiner"
#    ...
# )

# 获取本地化文本
text() {
    local key=$1
    local lang_key="${key}_${LANG}"
    shift
    
    if [ -n "${TEXTS[$lang_key]}" ]; then
        printf "${TEXTS[$lang_key]}" "$@"
    else
        echo "Missing translation for key: $key"
    fi
}

# 变量定义
SERVICE_NAME="teslaminer"
INSTALL_DIR="/opt/teslaminer"
BIN_NAME="teslaminerkernel"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
DOWNLOAD_URL="https://github.com/hivecassiny/tesla/releases/download/${VERSION}/teslalinuxamd64.tar.gz"
TEMP_DIR="/tmp/teslaminer_install"

# 检查是否root用户
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}$(text error_root)${NC}"
        exit 1
    fi
}

# 检查服务是否已安装
is_installed() {
    if [ -f "$SERVICE_FILE" ] || [ -d "$INSTALL_DIR" ]; then
        return 0
    else
        return 1
    fi
}

# 检查服务是否已卸载
is_uninstalled() {
    if [ ! -f "$SERVICE_FILE" ] && [ ! -d "$INSTALL_DIR" ]; then
        return 0
    else
        return 1
    fi
}

# 检查服务是否正在运行
is_running() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        return 0
    else
        return 1
    fi
}

# 设置socket连接上限
set_socket_limit() {
    echo -e "${YELLOW}$(text socket_limit)${NC}"
    local current_limit=$(ulimit -n)
    local target_limit=1048576
    
    if [ "$current_limit" -lt "$target_limit" ]; then
        echo "* soft nofile 1048576" >> /etc/security/limits.conf
        echo "* hard nofile 1048576" >> /etc/security/limits.conf
        echo "fs.file-max = 1048576" >> /etc/sysctl.conf
        sysctl -p > /dev/null
        ulimit -n 1048576
        echo -e "${GREEN}$(text socket_set)${NC}"
    else
        echo -e "${BLUE}$(text socket_ok "$current_limit")${NC}"
    fi
}

# 下载并解压TeslaMiner
download_and_extract() {
    echo -e "${YELLOW}$(text downloading)${NC}"
    mkdir -p "$TEMP_DIR"
    wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/teslaminer.tar.gz"
    if [ $? -ne 0 ]; then
        echo -e "${RED}$(text download_fail)${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}$(text extracting)${NC}"
    tar -xzf "$TEMP_DIR/teslaminer.tar.gz" -C "$TEMP_DIR"
    
    # 查找内部压缩包和解压
    inner_tar=$(find "$TEMP_DIR" -name "teslaminerkernellinux.tar.gz")
    if [ -z "$inner_tar" ]; then
        echo -e "${RED}$(text error_inner_tar)${NC}"
        exit 1
    fi
    
    tar -xzf "$inner_tar" -C "$TEMP_DIR"
    
    # 查找二进制文件
    BIN_PATH=$(find "$TEMP_DIR" -name "$BIN_NAME" -type f)
    if [ -z "$BIN_PATH" ]; then
        echo -e "${RED}$(text error_bin "$BIN_NAME")${NC}"
        exit 1
    fi
    
    chmod +x "$BIN_PATH"
}

# 安装服务
install_service() {
    if is_installed; then
        echo -e "${RED}$(text already_installed)${NC}"
        echo -e "$(text uninstall_first)"
        return 1
    fi
    
    echo -e "${YELLOW}$(text installing)${NC}"
    
    # 创建安装目录
    mkdir -p "$INSTALL_DIR"
    
    # 移动文件到安装目录
    cp "$BIN_PATH" "$INSTALL_DIR/"
    
    # 创建服务文件
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=TeslaMiner Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/$BIN_NAME
Restart=always
RestartSec=5s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
    
    # 重载systemd
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    systemctl start "$SERVICE_NAME"
    
    echo -e "${GREEN}$(text install_done)${NC}"
    echo -e "$(text install_dir) ${BLUE}$INSTALL_DIR${NC}"
    echo -e "$(text service_status) ${BLUE}systemctl status $SERVICE_NAME${NC}"
}

# 卸载服务
uninstall_service() {
    if is_uninstalled; then
        echo -e "${RED}$(text not_installed)${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}$(text uninstalling)${NC}"
    
    if is_running; then
        systemctl stop "$SERVICE_NAME"
    fi
    
    if systemctl is-enabled --quiet "$SERVICE_NAME"; then
        systemctl disable "$SERVICE_NAME"
    fi
    
    if [ -f "$SERVICE_FILE" ]; then
        rm -f "$SERVICE_FILE"
        systemctl daemon-reload
    fi
    
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi
    
    echo -e "${GREEN}$(text uninstalled)${NC}"
}

# 启动服务
start_service() {
    if is_running; then
        echo -e "${YELLOW}$(text already_running)${NC}"
        return
    fi
    
    systemctl start "$SERVICE_NAME"
    echo -e "${GREEN}$(text starting)${NC}"
}

# 停止服务
stop_service() {
    if ! is_running; then
        echo -e "${YELLOW}$(text already_stopped)${NC}"
        return
    fi
    
    systemctl stop "$SERVICE_NAME"
    echo -e "${GREEN}$(text stopping)${NC}"
}

# 重启服务
restart_service() {
    systemctl restart "$SERVICE_NAME"
    echo -e "${GREEN}$(text restarting)${NC}"
    echo -e "$(text service_status) ${BLUE}systemctl status $SERVICE_NAME${NC}"
}

# 查看服务状态
status_service() {
    systemctl status "$SERVICE_NAME"
}

# 显示菜单
show_menu() {
    clear
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  $(text menu_title) ${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "1. $(text menu_install)"
    echo -e "2. $(text menu_start)"
    echo -e "3. $(text menu_stop)"
    echo -e "4. $(text menu_restart)"
    echo -e "5. $(text menu_status)"
    echo -e "6. $(text menu_uninstall)"
    echo -e "0. $(text menu_exit)"
    echo -e "${GREEN}================================${NC}"
    read -p "$(text input_option) [0-6]: " option
}

# 主函数
main() {
    check_root
    
    while true; do
        show_menu
        case $option in
            1)
                set_socket_limit
                download_and_extract
                install_service
                rm -rf "$TEMP_DIR"
                read -p "$(text press_any_key)"
                ;;
            2)
                start_service
                read -p "$(text press_any_key)"
                ;;
            3)
                stop_service
                read -p "$(text press_any_key)"
                ;;
            4)
                restart_service
                read -p "$(text press_any_key)"
                ;;
            5)
                status_service
                read -p "$(text press_any_key)"
                ;;
            6)
                uninstall_service
                read -p "$(text press_any_key)"
                ;;
            0)
                echo -e "${GREEN}$(text exit)${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}$(text invalid_option)${NC}"
                read -p "$(text press_any_key)"
                ;;
        esac
    done
}

# 执行主函数
main
