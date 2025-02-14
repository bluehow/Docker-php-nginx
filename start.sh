#!/bin/sh

# 启动PHP-FPM后台服务
php-fpm -D

# 检查PHP-FPM状态
if ! pgrep "php-fpm" > /dev/null
then
    echo "Error: Failed to start PHP-FPM"
    exit 1
fi

# 启动Nginx前台服务
nginx -g "daemon off;"