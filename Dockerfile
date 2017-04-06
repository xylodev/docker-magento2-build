FROM php:7.0-fpm

USER root
RUN echo 'mariadb-server-10.0 mysql-server/root_password password root' | debconf-set-selections && \
    echo 'mariadb-server-10.0 mysql-server/root_password_again password root' | debconf-set-selections && \
    apt-get update -y && apt-get install -y \
        cron \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxslt1-dev \
        zip \
        openssh-server \
        mariadb-client \
        mariadb-server \
        python \
        python-mysqldb \
        git

RUN docker-php-ext-configure \
        gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
        bcmath \
        gd \
        intl \
        mbstring \
        mcrypt \
        pdo_mysql \
        soap \
        xsl \
        zip

RUN curl -sS https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir /var/run/sshd /root/.ssh && \
    ln -s /var/jenkins_home/.ssh/id_rsa /root/.ssh/id_rsa && \
    ln -s /var/jenkins_home/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub && \
    ln -s /var/jenkins_home/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    ssh-keyscan -H github.com >> /root/.ssh/known_hosts && \
    ssh-keyscan -H bitbucket.org >> /root/.ssh/known_hosts && \
    echo "[client]\nuser=root\npassword=root" > /root/.my.cnf

COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
COPY bin/* /usr/local/bin/

EXPOSE 22
CMD "/usr/local/bin/start.sh"
