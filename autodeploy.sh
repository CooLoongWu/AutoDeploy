#!/bin/bash

# 引入工具文件
. auto_utils.sh
#chmod 777 ./auto_utils.sh

AutoDeploy_Ver='1.0'
AutoDeploy_Name='AutoDeploy'

# 检查是否是root用户
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ${AutoDeploy_Name}"
    exit 1
fi

# 判断主机系统
Get_Dist_Name
if [ "${DISTRO}" != "Ubuntu" ]; then
    Echo_Red "We are NOT support the current distribution."
    exit 1
fi

Echo_Blue "+----------------------------------------------------------------------------------+"
Echo_Blue "|----------${AutoDeploy_Name} V${AutoDeploy_Ver} for ${DISTRO} Linux Server, Written by CooLoongWu----------|"
Echo_Blue "+----------------------------------------------------------------------------------+"
Echo_Blue "|---------------A tool to auto-compile & install ${AutoDeploy_Name} on Linux---------------|"
Echo_Blue "+----------------------------------------------------------------------------------+"

Echo_Blue
Echo_Blue "Step 1、Check PHP environment"
Install_PHP_55
Check_PHP_Pcntl
Check_PHP_Posix
Check_PHP_Libevent

Echo_Blue
Echo_Blue "Step 2、Check system environment"
Performance_Net
Performance_SoftOpenFiles

Echo_Blue
Echo_Blue "Step 3、Modify AutoDeploySystem configuration "

Reboot

# 安装php5-cli
#if [ -f /usr/bin/php ]; then
#    Echo_Green "[√] PHP have installed!"
#else
#    Install_PHP_55
#fi
#


#for 循环遍历
#echo ${#modules[@]}
#for var in ${modules[@]};
#do
#    echo $var
#done

# 解决按下删除按键出现^H却无法删除的情况
#stty erase '^H'
#read -p `Echo_Yellow "请输入姓名："` name
#
#if [ -n "$name" ]; then
#    Replace_Str "$name"
#else
#    echo "选择了默认"
#fi


#php ./check.php
#exit 0