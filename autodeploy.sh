#!/bin/bash

# 引入工具文件
. utils.sh

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

# 安装php5-cli
if [ -f /usr/bin/php ]; then
    Echo_Green "You have installed PHP!"
    php -v
else
    Install_PHP_55
fi

php ./check.php
exit 0