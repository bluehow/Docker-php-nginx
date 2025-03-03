FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/php:7.3.29-fpm-alpine3.14
ENV TZ="Asia/Shanghai"
# 安装Nginx和PHP扩展依赖
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update \
    && apk add --no-cache $PHPIZE_DEPS \
    && apk add --no-cache libstdc++ libzip-dev vim nginx libpng git supervisor \
    freetype \
    libpng \
    libjpeg-turbo \
    freetype-dev \
    libpng-dev \
    jpeg-dev \
    libjpeg \
    libjpeg-turbo-dev \
    libwebp \
    libwebp-dev \
    gettext-dev \
    && pecl install https://pecl.php.net/get/redis-4.1.1.tgz \
    && pecl install zip \
    && docker-php-ext-install exif bcmath sockets \
    && docker-php-ext-enable redis zip exif bcmath sockets \
    && apk del $PHPIZE_DEPS \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/local/freetype/ --with-jpeg-dir=/usr/local/libjpeg/ --with-png-dir=/usr/local/libpng \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql opcache \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && mkdir /var/log/supervisor

COPY ./supervisor/supervisord.conf /etc/supervisord.conf

# 配置Nginx
COPY nginx/nginx.conf /etc/nginx/http.d/default.conf
# 配置php
COPY php.ini /usr/local/etc/php/conf.d/php.ini

EXPOSE 80

WORKDIR /var/www/html

ENTRYPOINT ["supervisor","-c","/etc/supervisord.conf"]