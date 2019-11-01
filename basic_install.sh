#!/bin/bash

# ############################################################################################# #
# /*-------------------- https://wandu.com.ar | soporte[at]wandu.com.ar ---------------------*/ #
# ############################################################################################# #
# #        /\      /\                                                                         # #
# #       / /\    / /\                                                                        # #
# #      / /%%\  / /##\                                                                       # #
# #     / /%%%%\/ /####\                                                __            (R)     # #
# #    / /%%/\%%//##/\##\                                              |  \                   # #
# #   | |\%/ \\//##/\ \##|      __   __   __   ______   _______    ____| ## __    __          # #
# #   | |#\  / /##/  \ \#|     |  \ |  \ |  \ |      \ |       \  /      ##|  \  |  \         # #
# #    \|##\/ /##//\  /@\|     | ## | ## | ##  \######\| #######\|  #######| ##  | ##         # #
# #     \\##\/##//@@\/@@/      | ## | ## | ## /      ##| ##  | ##| ##  | ##| ##  | ##         # #
# #      \\####/ \\@@@@/       | ##_/ ##_/ ##|  #######| ##  | ##| ##__| ##| ##__/ ##         # #
# #       \\##/   \\@@/         \##   ##   ## \##    ##| ##  | ## \##    ## \##    ##         # #
# #        \\/     \\/           \#####\####   \####### \##   \##  \#######  \######          # #
# #                                                                                           # #
# ############################################################################################# #
# /*--------------------------- MADE IN BUENOS AIRES - ARGENTINA ----------------------------*/ #
# ############################################################################################# #
#
# Welcome to my script!
#
# Author: Alejandro D. Guevara
# Version: 1.0.0
# Release date: 31/10/2019
# Languaje: Spanglish
# Script: basic_install.sh
# 
# "Dedicado a quienes se dedican a expandir el mundo del software libre..."
#          

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo " 
---------------------------------------
--              Wandu ®              --
---------------------------------------
--    `date  +%a' '%F' '%H:%M:%S` hs.    --
---------------------------------------
---------------------------------------
"


if grep "^9\." /etc/debian_version > /dev/null; then
	echo "(INFO) Debian 9 Detectado."
else
    echo "(ERROR) No se encontro una instalacion de debian 9 valida."
    exit 0
fi

cd /root

HOSTNAME=$(</etc/hostname)

## INI - Instalacion de utilidades
    echo "• Instalacion de utilidades."

    echo "> Instalando rsync ..."
    apt install rsync -y

    echo "> Instalando unzip ..."
    apt install unzip -y

    echo "> Instalando locate ..."
    apt install locate



## FIN - Instalacion de utilidades

## INI - Instalacion de WEBMIN
    echo "• Instalacion de webmin."
    
    echo "> Agregando repositorio..."
    wget -q http://www.webmin.com/jcameron-key.asc -O- | apt-key add -
    echo "deb https://download.webmin.com/download/repository sarge contrib" | tee /etc/apt/sources.list.d/webmin.list

    echo "> Instalando dependencias..."
    apt install apt-transport-https -y

    echo "> Actualizando paquetes..."
    apt update

    echo "> Instalando webmin..."
    apt install webmin
## FIN - Instalacion de WEBMIN

## INI - Instalacion de UFW
    echo "• Instalacion de UFW (Firewall)."
    
    echo "> Instalando UFW..."
    apt install ufw -y

    echo "> Por favor, escriba el puerto SSH."
    echo "> ATENCIÓN: Un error en el puerto podría dejarte sin acceso por SSH."
    read SSH_PORT

    echo "> Habilitando puertos..."
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow ${SSH_PORT}/tcp
    ufw allow 10000/tcp

    ufw enable
    ufw status
## FIN - Instalacion de UFW

## INI - Instalacion de LAMP
    echo "• Instalacion de LAMP."
    
    #REF: https://www.howtoforge.com/tutorial/install-apache-with-php-and-mysql-lamp-on-debian-stretch/
    #REF: https://tecadmin.net/install-multiple-php-version-with-apache-on-debian/
    #REF: https://certbot.eff.org/lets-encrypt/debianstretch-apache.html
    
    echo "> Instalando MariaDB..."
    apt install mariadb-server -y
    mysql_secure_installation


    echo "> Instalando PHP-FPM..."
    echo "> Agregando repositorios..."
    apt install ca-certificates -y
    wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
    echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

    echo "> Actualizando paquetes..."
    apt update

    echo "> Instalando PHP 5.6 ..."
    apt install php5.6 php5.6-fpm php5.6-mysql php5.6-curl php5.6-gd php5.6-memcache php5.6-opcache php5.6-apcu php5.6-bz2 php5.6-zip php5.6-mbstring php5.6-xml -y

    echo "> Instalando PHP 7.3 ..."
    apt install php7.3 php7.3-fpm php7.3-mysql php7.3-curl php7.3-gd php7.3-memcache php7.3-opcache php7.3-apcu php7.3-bz2 php7.3-zip php7.3-mbstring php7.3-xml -y

    echo "> Instalando Apache 2 y mod-fcgid para PHP-FPM ..."
    apt install apache2 libapache2-mod-fcgid -y

    echo "> Habilitando mods de Apache ..."
    a2enmod rewrite ssl include headers actions proxy_fcgi alias http2
    a2enconf php7.3-fpm

    echo "> Agregando puerto de escucha 800/tcp ..."
    echo "Listen 800" >> /etc/apache2/ports.conf

    echo "> Creando archivo /var/www/html/info.php de ejemplo ..."
    echo "<?php phpinfo(); ?>" > /var/www/html/info.php

    echo "> Habilitando HTTP/2 ..."
    echo "Protocols h2 h2c http/1.1" >> /etc/apache2/apache2.conf

    echo "> Reiniciando servicio Apache..."
    systemctl restart apache2

    echo "> Instalando phpMyAdmin ..."
    apt install phpmyadmin -y

    echo "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root' AND plugin = 'unix_socket';FLUSH PRIVILEGES;" | mysql -u root -p

    mkdir -m 0755 /var/www/phpmyadmin/

    cat > /var/www/phpmyadmin/.user.ini << EOF
upload_max_filesize = 50M
post_max_size = 50M
display_errors = On
error_reporting = E_ALL
EOF

    echo '<?php header("Location: /phpmyadmin/");' > /var/www/phpmyadmin/index.php

    cat > /etc/apache2/sites-available/phpmyadmin.conf << EOF
<VirtualHost *:800>
    DocumentRoot "/var/www/phpmyadmin"
    <Directory "/var/www/phpmyadmin">
        Allow from all
        Options -Indexes +FollowSymLinks -MultiViews
        Require all granted
    </Directory>
    <FilesMatch ".+\.ph(p[3457]?|t|tml)$">
        SetHandler "proxy:unix:/run/php/php5.6-fpm.sock|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
EOF

    ln -s /usr/share/phpmyadmin /var/www/phpmyadmin/phpmyadmin

    a2ensite phpmyadmin.conf
    systemctl reload apache2

    echo "> Instalando LetsEncrypt ..."
    echo "> Agregando repositorios..."
    echo "deb http://ftp.debian.org/debian stretch-backports main" | tee /etc/apt/sources.list.d/lets-encrypt.list

    echo "> Actualizando paquetes..."
    apt update

    echo "> Instalando certbot ..."
    apt install python-certbot-apache -y -t stretch-backports

## FIN - Instalacion de LAMP

## INI - Instalacion de fail2ban
    echo "• Instalacion de fail2ban."

    echo "> Instalando fail2ban ..."
    apt install fail2ban -y



    cat > /etc/fail2ban/jail.local << EOF
[ssh-with-ufw]
enabled = true
port = $SSH_PORT
filter = sshd
action = ufw[application="OpenSSH", blocktype=reject]
logpath = /var/log/auth.log
maxretry = 3
EOF

    service fail2ban restart
## FIN - Instalacion de fail2ban

## INI - Instalacion de sudo
    echo "• Instalacion de sudo."
    apt install sudo -y

    usermod --shell /bin/bash www-data
## FIN - Instalacion de sudo

## INI - Instalacion de sudo

## INI - Instalacion de Composer
    echo "• Instalacion de composer."

    echo "> Instalando dependencias ..."
    apt install curl php-cli php-mbstring git -y

    echo "> Instalando composer ..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
## FIN - Instalacion de Composer

## INI - Configuraciones
    echo "• Configuracion del sistema."

    echo "> Modificando shell de www-data ..."
    usermod --shell /bin/bash www-data

    echo "> Configurando acceso SSH mediante keys ..."
    ssh-keygen -t rsa
    cp ~/.ssh/id_rsa.pub  ~/.ssh/authorized_keys

    echo "> Copia la clave privada ...
    
    "
    cat ~/.ssh/id_rsa

    echo "
    
    "
    read -p "Presiona [Enter] para continuar..."
## END - Configuraciones
