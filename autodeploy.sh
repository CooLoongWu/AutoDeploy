#!/bin/bash

AutoDeploy_Ver='1.0'
AutoDeploy_Name='AutoDeploy'

Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Amazon Linux AMI" /etc/issue || grep -Eq "Amazon Linux AMI" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
        DISTRO='Mint'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}


# 安装PHP
Php_Ver="5.5"
Install_PHP_55()
{
    if [ -f /usr/bin/php ]; then
        Echo_Green "[√] PHP have installed !"
    else
        Echo_Yellow "[+] Updating software sources, please wait..."
        # 不打印信息
        apt-get update 1>/dev/null 2>/dev/null
        Echo_Green "[√] Update completed..."

        Echo_Yellow "[+] Installing PHP ${Php_Ver}, please wait..."
        apt-get install -y php5-cli 1>/dev/null 2>/dev/null
            if [ -f /usr/bin/php ]; then
                Echo_Green "[√] PHP installation completed !"
            else
                Echo_Red "[x] PHP installation failed !"
                Echo_Red "[x] AutoDeploy terminate !"
                exit 1
            fi
    fi
}

# 判断并安装PHP pcntl扩展
Check_PHP_Pcntl(){
    modules=(`php -m`)
    if echo "${modules[@]}" | grep -w "pcntl" &>/dev/null; then
        Echo_Green "[√] PHP modules - pcntl have installed !"
    else
        Echo_Yellow "[x] PHP modules - pcntl is missing, please check your PHP modules !"
    fi
}

# 判断并安装PHP posix扩展
Check_PHP_Posix(){
    modules=(`php -m`)
    if echo "${modules[@]}" | grep -w "posix" &>/dev/null; then
        Echo_Green "[√] PHP modules - posix have installed !"
    else
        Echo_Yellow "[x] PHP modules - posix is missing, please check your PHP modules !"
    fi
}

# 判断并安装PHP libevent扩展
Check_PHP_Libevent(){
    modules=(`php -m`)
    if echo "${modules[@]}" | grep -w "libevent" &>/dev/null; then
        Echo_Green "[√] PHP modules - libevent have installed !"
    else
        Echo_Yellow "[+] Installing PHP extension libevent, please wait..."
        apt-get install  php-pear php5-dev libevent-dev expect tcl -y 1>/dev/null 2>/dev/null

        Install_Libevent 1>/dev/null 2>/dev/null
        if [ $? -eq 0 ]; then
            echo extension=libevent.so > /etc/php5/cli/conf.d/libevent.ini
            Echo_Green "[√] PHP modules - libevent installation completed !"
        else
            Echo_Red "[x] PHP modules - libevent installation failed !"
            Echo_Red "[x] AutoDeploy terminate !"
        fi
    fi
}

# 其实还需要判断php.ini中是否禁用了这几个函数："stream_socket_server","stream_socket_client","pcntl_signal_dispatch"。

# 使用expect来自动确认安装libevent，免去手工回车
Install_Libevent(){
expect <<!
set timeout 1000
spawn pecl install channel://pecl.php.net/libevent-0.1.0
expect "autodetect"
send "\n"
expect eof
!
}

# 性能调优，网络，并将原来的配置备份为sysctl.conf_back
Performance_Net(){
    cp -b -S _bak ./sysctl.conf /etc/
    if [ $? -eq 0 ]; then
            Echo_Green "[√] Net performance Tuning completed!"
        else
            Echo_Red "[x] Net performance Tuning failed !"
        fi
}

# 性能调优，打开文件数，并将原来的配置备份为limits.conf_back
Performance_SoftOpenFiles(){
    cp -b -S _bak ./limits.conf /etc/security
    if [ $? -eq 0 ]; then
            Echo_Green "[√] SoftOpenFiles performance Tuning completed!"
        else
            Echo_Red "[x] SoftOpenFiles performance Tuning failed !"
        fi
}

# 得到本机内网IP
IP_This_Inner(){
    ifconfig eth0 |awk -F '[ :]+' 'NR==2 {print $4}'
}

IP_TEMP='xxx'
# 设置Register服务器地址
IP_REGISTER='xxx'
Set_IP_Register(){
    stty erase '^H'
    read -p `Echo_Yellow '请输入Register服务器地址(默认本机内网IP)：'` command

    if [ -z "$command" ]; then
        Echo_Green "您设置的Register服务器IP地址为："`IP_This_Inner`
        IP_TEMP=`IP_This_Inner`
    else
        Echo_Green "您设置的Register服务器IP地址为：$command"
        IP_TEMP="$command"
    fi

    sed -i "s/IP_REGISTER = '$IP_REGISTER'/IP_REGISTER = '$IP_TEMP'/g" ./test.php
    #同时也要修改本文件中的地址，保证不是其他地方的相同字符串被修改
    sed -i "s/IP_REGISTER='$IP_REGISTER'/IP_REGISTER='$IP_TEMP'/g" ./autodeploy.sh
}

# 设置Detection服务器地址
IP_DETECTION='xxx'
Set_IP_Detection(){
    stty erase '^H'
    read -p `Echo_Yellow '请输入Detection服务器地址(默认本机内网IP)：'` command

    if [ -z "$command" ]; then
        Echo_Green "您设置的Detection服务器IP地址为："`IP_This_Inner`
        IP_TEMP=`IP_This_Inner`
    else
        Echo_Green "您设置的Detection服务器IP地址为：$command"
        IP_TEMP="$command"
    fi

    sed -i "s/IP_DETECTION = '$IP_DETECTION'/IP_DETECTION = '$IP_TEMP'/g" ./test.php
    #同时也要修改本文件中的地址，保证不是其他地方的相同字符串被修改
    sed -i "s/IP_DETECTION='$IP_DETECTION'/IP_DETECTION='$IP_TEMP'/g" ./autodeploy.sh
}

# 设置Redis服务器地址
IP_REDIS='xxx'
Set_IP_Redis(){
    stty erase '^H'
    read -p `Echo_Yellow '请输入Redis服务器地址(默认本机内网IP)：'` command

    if [ -z "$command" ]; then
        Echo_Green "您设置的Redis服务器IP地址为："`IP_This_Inner`
        IP_TEMP=`IP_This_Inner`
    else
        Echo_Green "您设置的Redis服务器IP地址为：$command"
        IP_TEMP="$command"
    fi

    sed -i "s/IP_REDIS = '$IP_REDIS'/IP_REDIS = '$IP_TEMP'/g" ./test.php
    #同时也要修改本文件中的地址，保证不是其他地方的相同字符串被修改
    sed -i "s/IP_REDIS='$IP_REDIS'/IP_REDIS='$IP_TEMP'/g" ./autodeploy.sh
}

# 替换字符串
TEMP='xxx'
Replace_Str(){
    if [ $#>0 ]; then
        echo $1
        #sed -i 's/$TEMP=.*/$TEMP="Hello"' ./test.php
        sed -i "s/TEMP = '$TEMP'/TEMP = '$1'/g" ./test.php
        #同时也要修改本文件中的地址，保证不是其他地方的相同字符串被修改
        sed -i "s/TEMP='$TEMP'/TEMP='$1'/g" ./autodeploy.sh
    fi
}

# 服务器重启
Reboot(){
    stty erase '^H'
    read -p `Echo_Yellow '现在重启服务器吗？(y/n)'` command

    if [ "$command" == "n" ]; then
        Echo_Green "好的，稍后请您手动重启！"
    else
        Echo_Green "好的，正在重启..."
        reboot
    fi
}

# ==================================================主代码区==================================================

# 检查是否是root用户
if [ $(id -u) != "0" ]; then
    Echo_Red "警告：请您以root用户权限进行操作！"
    exit 1
fi

# 判断主机系统
Get_Dist_Name
if [ "${DISTRO}" != "Ubuntu" ]; then
    Echo_Red "抱歉：该脚本暂时还不支持除Ubuntu系统外的其他操作系统！"
    exit 1
fi

Echo_Blue "+----------------------------------------------------------------------------------+"
Echo_Blue "|----------${AutoDeploy_Name} V${AutoDeploy_Ver} for ${DISTRO} Linux Server, Written by CooLoongWu----------|"
Echo_Blue "+----------------------------------------------------------------------------------+"
Echo_Blue "|---------------A tool to auto-compile & install ${AutoDeploy_Name} on Linux---------------|"
Echo_Blue "+----------------------------------------------------------------------------------+"

Echo_Blue
Echo_Blue "1、正在检查PHP环境及扩展"
Install_PHP_55
Check_PHP_Pcntl
Check_PHP_Posix
Check_PHP_Libevent

Echo_Blue
Echo_Blue "2、正在进行系统内核调优"
Performance_Net
Performance_SoftOpenFiles

Echo_Blue
Echo_Blue "3、请配置系统各项参数"
Set_IP_Register
Set_IP_Detection
Set_IP_Redis

Reboot