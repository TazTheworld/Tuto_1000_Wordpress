#!/bin/bash

# Installation des dépendances PHP et redémarrage d'Apache
apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip unrar
systemctl restart apache2

# Configuration du virtualhost pour WordPress
cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<Directory /var/www/html/wordpress/>
    AllowOverride All
</Directory>
EOF

# Modification du fichier de configuration de WordPress
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Activation du virtualhost et redémarrage d'Apache
a2ensite wordpress.conf
systemctl restart apache2

# Téléchargement et extraction de WordPress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/html/wordpress
chown -R www-data:www-data /var/www/html/wordpress

# Connexion à MySQL pour créer la base de données WordPress
echo "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -u root -p

# Édition du fichier de configuration de WordPress
sed -i "s/database_name_here/wordpress/g" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/root/g" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/root_password/g" /var/www/html/wordpress/wp-config.php

# Configuration du serveur pour supporter les uploads volumineux
sed -i '/file_uploads/c\file_uploads = On' /etc/php/7.4/apache2/php.ini
sed -i '/upload_max_filesize/c\upload_max_filesize = 200M' /etc/php/7.4/apache2/php.ini
sed -i '/max_file_uploads/c\max_file_uploads = 200M' /etc/php/7.4/apache2/php.ini
sed -i '/memory_limit/c\memory_limit = 128M' /etc/php/7.4/apache2/php.ini
sed -i '/max_input_time/c\max_input_time = 60000' /etc/php/7.4/apache2/php.ini

# Redémarrage de PHP-FPM
systemctl restart php7.4-fpm

# Installation de phpMyAdmin
echo "Y" | apt-get install phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Configuration de phpMyAdmin dans Apache
cat <<EOF > /etc/apache2/sites-available/phpmyadmin.conf
<Directory /var/www/html/phpmyadmin/>
    AllowOverride All
</Directory>
EOF

# Activation du virtualhost pour phpMyAdmin et redémarrage d'Apache
a2ensite phpmyadmin.conf
systemctl restart apache2

# Création de 1000 instances de WordPress
for ((i=2;i<=1000;i++)); do
    # Création de copies de WordPress
    cp -r /var/www/html/wordpress/ /var/www/html/wordpress$i

    # Modification des autorisations
    chown -R www-data:www-data /var/www/html/wordpress$i

    # Modification des liens symboliques et des configurations
    ln -s /var/www/html/wordpress/wp-content/plugins/ /var/www/html/wordpress$i/wp-content/
    ln -s /var/www/html/wordpress/wp-content/themes/ /var/www/html/wordpress$i/wp-content/

    # Modification des fichiers de configuration
    sed -i "s/wordpress/wordpress$i/g" /etc/apache2/sites-available/wordpress.conf
    sed -i "s/wordpress/wordpress$i/g" /etc/apache2/sites-available/phpmyadmin.conf
    sed -i "s/wordpress/wordpress$i/g" /var/www/html/wordpress$i/wp-config.php
    a2ensite wordpress$i.conf
    systemctl restart apache2
done

echo "FINISH"
