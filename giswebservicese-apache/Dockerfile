FROM registry.astralinux.ru/library/astra/ubi18-apache24:latest

ENV DEBIAN_FRONTEND=noninteractive

# 1. Установка требуемых системных и PHP-пакетов
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        udev \
        libcurl3-gnutls \
        libgl1 \
        libjpeg62-turbo \
        libpng16-16 \
        libpq5 \
        libqtcore4 \
        libqtgui4 \
        libsasl2-2 \
        libsasl2-modules-gssapi-mit \
        libstdc++6 \
        libxft2 \
        zlib1g \
        libqt5opengl5 \
        ghostscript \
        libastraevents \
        php \
        php-cli \
        php-pdo \
        php-mysql \
        php-zip \
        php-gd \
        php-mbstring \
        php-curl \
        php-xml \
        php-pear \
        php-bcmath \
        php-ldap \
        php-pgsql \
        php-imagick \
        php-sqlite3 \
        libapache2-mod-php \
        libglu1-mesa

# 2. Копирование и установка основного приложения
COPY giswebservicese.deb /tmp/
RUN apt-get update && \
    apt-get install -y /tmp/giswebservicese.deb && \
    rm /tmp/giswebservicese.deb && \
    rm -rf /var/lib/apt/lists/*

# 3. Настройка модулей Apache
RUN a2dismod -q mpm_event || true && \
    a2enmod mpm_prefork rewrite

# 4. Правка /etc/apache2/apache2.conf
RUN sed -i 's/^#AstraMode on/AstraMode off/' /etc/apache2/apache2.conf && \
    sed -i 's/^#AccessFileName .htaccess/AccessFileName .htaccess/' /etc/apache2/apache2.conf

# 5. Правка /etc/apache2/sites-available/000-default.conf
RUN sed -i '/<\/VirtualHost>/i\<Directory /var/www/html/>\n        Options -Indexes +FollowSymLinks +Includes\n        AllowOverride All\n        Order allow,deny\n        Allow from All\n</Directory>' /etc/apache2/sites-available/000-default.conf

# 6. Правка /etc/apache2/envvars
RUN sed -i 's/^# *\(\. \/etc\/default\/locale\)/\1/' /etc/apache2/envvars

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 80

#CMD ["/usr/sbin/apache2", "-DFOREGROUND"]
CMD /usr/appservice/startgis.bat & /usr/sbin/apache2 -DFOREGROUND
