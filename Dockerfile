FROM debian:stretch
MAINTAINER Jan Köster <dasmaeh@cbjck.de>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Update System and install dependencies
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install apache2 libapache2-mod-php php php-dev php-gd php-mysql subversion vim \
                       imagemagick ghostscript antiword xpdf mysql-client \
                       libav-tools postfix libimage-exiftool-perl cron wget \
                       ffmpeg zip php-imap libphp-phpmailer

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable apache mods.
RUN a2enmod php7.0 && \
    a2enmod rewrite

# Modify php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 1G/g" /etc/php/7.0/apache2/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 1G/g" /etc/php/7.0/apache2/php.ini&& \
    sed -i -e "s/max_execution_time\s*=\s*30/max_execution_time = 1000/g" /etc/php/7.0/apache2/php.ini && \
    sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 1G/g" /etc/php/7.0/apache2/php.ini

# Setup site
WORKDIR /var/www/html
RUN rm index.html && \
    svn co http://svn.resourcespace.org/svn/rs/trunk . && \
    mkdir filestore && \
    chmod 777 filestore && \
    chmod -R 777 include

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

