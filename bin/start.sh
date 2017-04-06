#!/bin/sh

service mysql start
service php-fpm start

/usr/sbin/sshd -D
