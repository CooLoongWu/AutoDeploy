<?php

//PHP环境检查，判断版本，以及是否安装pcntl、posix以及libevent扩展

$version_ok = $pcntl_loaded = $posix_loaded = $libevent_loaded = false;
if (version_compare(phpversion(), "5.4", ">=")) {
    $version_ok = true;
}

$extensions = get_loaded_extensions();
if (in_array("pcntl", $extensions)) {
    $pcntl_loaded = true;
}
if (in_array("posix", $extensions)) {
    $posix_loaded = true;
}
if (in_array("libevent", $extensions)) {
    $libevent_loaded = true;
}

function check($val)
{
    if ($val) {
        return "\033[32;40m [OK] \033[0m";
    } else {
        return "\033[31;40m [fail] \033[0m";
    }
}

echo check($version_ok) . "     PHP Version >= 5.4\n";
echo check($pcntl_loaded) . "     Extension pcntl\n";
echo check($posix_loaded) . "     Extension posix\n";
echo check($libevent_loaded) . "     Extension libevent\n";

if (!$libevent_loaded) {
    echo "缺少libevent扩展，正在安装...\n";
    exec("apt-get install -y php-pear php5-dev libevent-dev");
    exec("pecl install channel://pecl.php.net/libevent-0.1.0");
    exec("echo extension=libevent.so > /etc/php5/cli/conf.d/libevent.ini");
    echo "安装完毕\n";
}

$check_func_map = array(
    "stream_socket_server",
    "stream_socket_client",
    "pcntl_signal_dispatch",
);

// 获取php.ini中设置的禁用函数
if ($disable_func_string = ini_get("disable_functions")) {
    $disable_func_map = array_flip(explode(",", $disable_func_string));
}

// 遍历查看是否有禁用的函数
foreach ($check_func_map as $func) {
    if (isset($disable_func_map[$func])) {
        echo "\n\033[31;40mFunction $func may be disabled. Please check disable_functions in php.ini\n";
        echo "see http://doc3.workerman.net/faq/disable-function-check.html\033[0m\n";
        exit;
    }
}
