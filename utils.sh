#!/bin/bash

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
        Echo_Yellow "[+] Updating software sources..."
        # 不打印信息
        apt-get update 1>/dev/null 2>/dev/null
        Echo_Green "[√] Update completed..."

        Echo_Yellow "[+] Installing PHP ${Php_Ver}..."
        apt-get install -y php5-cli 1>/dev/null 2>/dev/null
            if [ -f /usr/bin/php ]; then
                Echo_Green "[√] PHP installation completed !"
            else
                Echo_Red "[×] PHP installation failed !"
                Echo_Red "[×] AutoDeploy terminate !"
                exit 1
            fi
    fi
}

# 判断并安装PHP Libevent扩展
Install_PHP_Libevent(){
    modules=(`php -m`)
    if echo "${modules[@]}" | grep -w "libevent" &>/dev/null; then
        Echo_Green "[√] libevent have installed !"
    else
        Echo_Yellow "[+] Installing PHP extension libevent..."
        apt-get install -y php-pear php5-dev libevent-dev 1>/dev/null 2>/dev/null
        pecl install channel://pecl.php.net/libevent-0.1.0 1>/dev/null 2>/dev/null
        echo extension=libevent.so > /etc/php5/cli/conf.d/libevent.ini
        Echo_Green "[√] libevent installation completed !"
    fi
}

# 替换字符串
TEMP='xxx'
Replace_Str(){
    if [ $#>0 ]; then
        echo $1
        #sed -i 's/$TEMP=.*/$TEMP="Hello"' ./test.php
        sed -i "s/TEMP = '$TEMP'/TEMP = '$1'/g" ./test.php
        #同时也要修改本文件中的地址，保证不是其他地方的相同字符串被修改
        sed -i "s/TEMP='$TEMP'/TEMP='$1'/g" ./utils.sh
    fi
}