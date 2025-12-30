#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
ScriptVersion='v1.3.3'

# Default language set to English
LANG="en"
VERSION=""
HIVE_MINER_HOST=""
UUID=""
DIRECT_ACTION=""  # 新增：用于存储直接执行的步骤

# Parse arguments
for arg in "$@"; do
    if [[ "$arg" == lang=* ]]; then
        LANG="${arg#*=}"
    elif [[ "$arg" == ver=* ]]; then
        VERSION="${arg#*=}"
    elif [[ "$arg" == hive_miner_host=* ]]; then
        HIVE_MINER_HOST="${arg#*=}"
    elif [[ "$arg" == uuid=* ]]; then
        UUID="${arg#*=}"
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then  # 新增：检测数字参数
        DIRECT_ACTION="$arg"
    fi
done

# Check if version number is provided
if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: Version number is required (e.g. ver=v0.1.007@250806)${NC}"
    exit 1
fi

# Check if required parameters are provided
if [ -z "$HIVE_MINER_HOST" ] || [ -z "$UUID" ]; then
    echo -e "${RED}Error: Both hive_miner_host and uuid parameters are required${NC}"
    echo -e "${YELLOW}Example: lang=en ver=v0.1.007@250806 hive_miner_host=192.168.1.41:18383 uuid=605916129097027584${NC}"
    exit 1
fi

# Multilingual text definitions - grouped by language
declare -A TEXTS

# English texts
TEXTS+=(
    # Common texts
    ["error_root_en"]="Error: This script must be run as root!"
    ["menu_title_en"]="Teslaminer Service Management Script"
    ["press_any_key_en"]="Press any key to continue..."
    ["invalid_option_en"]="Invalid option, please try again!"
    ["exit_en"]="Exiting script."
    ["input_option_en"]="Please enter your choice"
    
    # Menu options
    ["menu_install_en"]="Install TeslaMiner service"
    ["menu_start_en"]="Start TeslaMiner service"
    ["menu_stop_en"]="Stop TeslaMiner service"
    ["menu_restart_en"]="Restart TeslaMiner service"
    ["menu_status_en"]="View service status"
    ["menu_uninstall_en"]="Uninstall TeslaMiner service"
    ["menu_update_en"]="Update TeslaMiner"
    ["menu_reboot_en"]="Reboot server"
    ["menu_exit_en"]="Exit"
    ["menu_reinstall_en"]="Reinstall TeslaMiner service"
    
    # Installation related
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
    
    # Uninstallation related
    ["uninstalling_en"]="Uninstalling TeslaMiner service..."
    ["uninstalled_en"]="TeslaMiner service uninstalled!"
    ["not_installed_en"]="Error: TeslaMiner service is not installed, nothing to uninstall!"
    
    # Service control
    ["starting_en"]="Service started!"
    ["already_running_en"]="Service is already running!"
    ["stopping_en"]="Service stopped!"
    ["already_stopped_en"]="Service is already stopped!"
    ["restarting_en"]="Service restarted!"
    
    # Update related
    ["updating_en"]="Updating TeslaMiner..."
    ["update_done_en"]="TeslaMiner updated successfully!"
    ["update_fail_en"]="Update failed!"
    ["not_installed_update_en"]="TeslaMiner is not installed. Please install it first."
    
    # Reboot related
    ["rebooting_en"]="Rebooting server now..."
    ["confirm_reboot_en"]="Are you sure you want to reboot the server? (y/n) "
    ["reboot_canceled_en"]="Reboot canceled."
    
    # Config related
    ["creating_config_en"]="Creating config.rig file..."
    ["config_created_en"]="config.rig file created successfully!"
    
    # Reinstall related
    ["reinstalling_en"]="Reinstalling TeslaMiner service..."
    ["reinstall_done_en"]="TeslaMiner service reinstalled successfully!"
)

# Chinese texts
TEXTS+=(
    # Common texts
    ["error_root_zh"]="错误: 此脚本必须以root用户身份运行!"
    ["menu_title_zh"]="TeslaMiner 服务管理脚本"
    ["press_any_key_zh"]="按任意键继续..."
    ["invalid_option_zh"]="无效选项，请重新输入!"
    ["exit_zh"]="退出脚本."
    ["input_option_zh"]="请输入您的选择"
    
    # Menu options
    ["menu_install_zh"]="安装 TeslaMiner 服务"
    ["menu_start_zh"]="启动 TeslaMiner 服务"
    ["menu_stop_zh"]="停止 TeslaMiner 服务"
    ["menu_restart_zh"]="重启 TeslaMiner 服务"
    ["menu_status_zh"]="查看服务状态"
    ["menu_uninstall_zh"]="卸载 TeslaMiner 服务"
    ["menu_update_zh"]="更新 TeslaMiner"
    ["menu_reboot_zh"]="重启服务器"
    ["menu_exit_zh"]="退出"
    ["menu_reinstall_zh"]="重新安装 TeslaMiner 服务"
    
    # Installation related
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
    
    # Uninstallation related
    ["uninstalling_zh"]="正在卸载TeslaMiner服务..."
    ["uninstalled_zh"]="TeslaMiner服务已卸载!"
    ["not_installed_zh"]="错误: TeslaMiner服务未安装，无需卸载!"
    
    # Service control
    ["starting_zh"]="服务已启动!"
    ["already_running_zh"]="服务已经在运行中!"
    ["stopping_zh"]="服务已停止!"
    ["already_stopped_zh"]="服务已经停止!"
    ["restarting_zh"]="服务已重启!"
    
    # Update related
    ["updating_zh"]="正在更新TeslaMiner..."
    ["update_done_zh"]="TeslaMiner更新成功!"
    ["update_fail_zh"]="更新失败!"
    ["not_installed_update_zh"]="TeslaMiner未安装。请先安装。"
    
    # Reboot related
    ["rebooting_zh"]="正在重启服务器..."
    ["confirm_reboot_zh"]="确定要重启服务器吗? (y/n) "
    ["reboot_canceled_zh"]="已取消重启。"
    
    # Config related
    ["creating_config_zh"]="正在创建config.rig文件..."
    ["config_created_zh"]="config.rig文件创建成功!"
    
    # Reinstall related
    ["reinstalling_zh"]="正在重新安装TeslaMiner服务..."
    ["reinstall_done_zh"]="TeslaMiner服务重新安装成功!"
)

# Get localized text
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

# Variable definitions
SERVICE_NAME="teslaminer"
INSTALL_DIR="/opt/teslaminer"
BIN_NAME="teslaminerkernel"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
DOWNLOAD_URL="https://github.com/hivecassiny/tesla/releases/download/${VERSION}/teslaminerkernellinuxamd64.tar.gz"
TEMP_DIR="/tmp/teslaminer_install"
CONFIG_FILE="${INSTALL_DIR}/config.rig"

# Create config file
create_config() {
    echo -e "${YELLOW}$(text creating_config)${NC}"
    cat > "$CONFIG_FILE" <<EOF
hive_miner_host=${HIVE_MINER_HOST}
#uuid must not be modified - changing it will prevent server connection
uuid=${UUID}
EOF
    echo -e "${GREEN}$(text config_created)${NC}"
}

# Check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}$(text error_root)${NC}"
        exit 1
    fi
}

# Check if service is installed
is_installed() {
    if [ -f "$SERVICE_FILE" ] || [ -d "$INSTALL_DIR" ]; then
        return 0
    else
        return 1
    fi
}

# Check if service is uninstalled
is_uninstalled() {
    if [ ! -f "$SERVICE_FILE" ] && [ ! -d "$INSTALL_DIR" ]; then
        return 0
    else
        return 1
    fi
}

# Check if service is running
is_running() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        return 0
    else
        return 1
    fi
}

# Set socket connection limit
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

# Download and extract TeslaMiner
download_and_extract() {
    echo -e "${YELLOW}$(text downloading)${NC}"
    mkdir -p "$TEMP_DIR"
    wget "$DOWNLOAD_URL" -O "$TEMP_DIR/teslaminer.tar.gz"
    if [ $? -ne 0 ]; then
        echo -e "${RED}$(text download_fail)${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}$(text extracting)${NC}"
    tar -xzf "$TEMP_DIR/teslaminer.tar.gz" -C "$TEMP_DIR"
    
    # Find binary file directly
    BIN_PATH=$(find "$TEMP_DIR" -name "$BIN_NAME" -type f)
    if [ -z "$BIN_PATH" ]; then
        echo -e "${RED}$(text error_bin "$BIN_NAME")${NC}"
        exit 1
    fi
    
    chmod +x "$BIN_PATH"
}

# Install service
install_service() {
    if is_installed; then
        echo -e "${RED}$(text already_installed)${NC}"
        echo -e "$(text uninstall_first)"
        return 1
    fi
    
    echo -e "${YELLOW}$(text installing)${NC}"
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Move files to installation directory
    cp "$BIN_PATH" "$INSTALL_DIR/"
    
    # Create config file
    create_config
    
    # Create service file
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
RestartSec=3s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    
    # Start the service and verify it's running
    if systemctl start "$SERVICE_NAME"; then
        echo -e "${GREEN}$(text install_done)${NC}"
        echo -e "$(text install_dir) ${BLUE}$INSTALL_DIR${NC}"
        
        # Check if service is actually running
        sleep 5 # Give it a moment to start
        if is_running; then
            echo -e "${GREEN}Service is successfully running${NC}"
        else
            echo -e "${YELLOW}Service was started but is not currently running${NC}"
            echo -e "${YELLOW}Checking status for more information...${NC}"
        fi
        
        # Show service status after installation
        status_service
    else
        echo -e "${RED}Failed to start TeslaMiner service${NC}"
        status_service
        return 1
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
}

# Uninstall service
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

# Start service
start_service() {
    if is_running; then
        echo -e "${YELLOW}$(text already_running)${NC}"
        return
    fi
    
    systemctl start "$SERVICE_NAME"
    echo -e "${GREEN}$(text starting)${NC}"
    
    # Show service status after starting
    status_service
}

# Stop service
stop_service() {
    if ! is_running; then
        echo -e "${YELLOW}$(text already_stopped)${NC}"
        return
    fi
    
    systemctl stop "$SERVICE_NAME"
    echo -e "${GREEN}$(text stopping)${NC}"
}

# Restart service
restart_service() {
    systemctl restart "$SERVICE_NAME"
    echo -e "${GREEN}$(text restarting)${NC}"
    
    # Show service status after restarting
    status_service
}

# View service status
status_service() {
    echo -e "\n${YELLOW}$(text service_status)${NC}"
    systemctl status "$SERVICE_NAME" --no-pager -l
}

# Update TeslaMiner
update_service() {
    if ! is_installed; then
        echo -e "${RED}$(text not_installed_update)${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}$(text updating)${NC}"

     # Download and extract new version
    download_and_extract
    
    # Stop service if running
    if is_running; then
        systemctl stop "$SERVICE_NAME"
    fi
    
    # Backup old binary
    mv "$INSTALL_DIR/$BIN_NAME" "$INSTALL_DIR/${BIN_NAME}.bak"
    
    # Copy new binary
    cp "$BIN_PATH" "$INSTALL_DIR/"
    
    # Recreate config file (preserve existing settings)
    if [ ! -f "$CONFIG_FILE" ]; then
        create_config
    fi
    
    # Start service
    systemctl start "$SERVICE_NAME"
    
    # Verify update
    if is_running; then
        echo -e "${GREEN}$(text update_done)${NC}"
        status_service
        # Remove backup if update successful
        rm -f "$INSTALL_DIR/${BIN_NAME}.bak"
    else
        echo -e "${RED}$(text update_fail)${NC}"
        # Restore backup if update failed
        mv "$INSTALL_DIR/${BIN_NAME}.bak" "$INSTALL_DIR/$BIN_NAME"
        systemctl start "$SERVICE_NAME"
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
}

# Reinstall service
reinstall_service() {
    echo -e "${YELLOW}$(text reinstalling)${NC}"
    
    # First uninstall if installed
    if is_installed; then
        uninstall_service
    fi
    
    # Then install fresh
    set_socket_limit
    download_and_extract
    install_service
    
    echo -e "${GREEN}$(text reinstall_done)${NC}"
}

# Reboot server
reboot_server() {
    read -p "$(text confirm_reboot)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}$(text rebooting)${NC}"
        shutdown -r now
    else
        echo -e "${YELLOW}$(text reboot_canceled)${NC}"
    fi
}

# Execute direct action
execute_direct_action() {
    case $1 in
        1)  # Install
            set_socket_limit
            download_and_extract
            install_service
            ;;
        2)  # Start
            start_service
            ;;
        3)  # Stop
            stop_service
            ;;
        4)  # Restart
            restart_service
            ;;
        5)  # Status
            status_service
            ;;
        6)  # Uninstall
            uninstall_service
            ;;
        7)  # Update
            update_service
            ;;
        8)  # Reboot
            reboot_server
            ;;
        9)  # Reinstall
            reinstall_service
            ;;
        *)
            echo -e "${RED}Invalid action number. Please use 1-9.${NC}"
            exit 1
            ;;
    esac
    
    exit 0
}

# Show menu
show_menu() {
    clear
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  $(text menu_title) ${NC}"
    echo -e "${GREEN}  ${ScriptVersion}${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "1. $(text menu_install)"
    echo -e "2. $(text menu_start)"
    echo -e "3. $(text menu_stop)"
    echo -e "4. $(text menu_restart)"
    echo -e "5. $(text menu_status)"
    echo -e "6. $(text menu_uninstall)"
    echo -e "7. $(text menu_update)"
    echo -e "8. $(text menu_reboot)"
    echo -e "9. $(text menu_reinstall)"
    echo -e "0. $(text menu_exit)"
    echo -e "${GREEN}================================${NC}"
    read -p "$(text input_option) [0-9]: " option
}

# Main function
main() {
    check_root
    
    # 如果有直接执行参数，则执行对应操作后退出
    if [ -n "$DIRECT_ACTION" ]; then
        execute_direct_action "$DIRECT_ACTION"
    fi
    
    # 否则进入交互式菜单
    while true; do
        show_menu
        case $option in
            1)  # Install
                set_socket_limit
                download_and_extract
                install_service
                read -p "$(text press_any_key)"
                ;;
            2)  # Start
                start_service
                read -p "$(text press_any_key)"
                ;;
            3)  # Stop
                stop_service
                read -p "$(text press_any_key)"
                ;;
            4)  # Restart
                restart_service
                read -p "$(text press_any_key)"
                ;;
            5)  # Status
                status_service
                read -p "$(text press_any_key)"
                ;;
            6)  # Uninstall
                uninstall_service
                read -p "$(text press_any_key)"
                ;;
            7)  # Update
                update_service
                read -p "$(text press_any_key)"
                ;;
            8)  # Reboot
                reboot_server
                read -p "$(text press_any_key)"
                ;;
            9)  # Reinstall
                reinstall_service
                read -p "$(text press_any_key)"
                ;;
            0)  # Exit
                echo -e "${GREEN}$(text exit)${NC}"
                exit 0
                ;;
            *)  # Invalid option
                echo -e "${RED}$(text invalid_option)${NC}"
                read -p "$(text press_any_key)"
                ;;
        esac
    done
}

# Execute main function
main
