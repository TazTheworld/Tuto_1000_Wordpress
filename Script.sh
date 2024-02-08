#!/bin/bash

apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip unrar

systemctl restart apache2


cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<Directory /var/www/html/wordpress/>
    AllowOverride All
</Directory>
EOF

cd /etc/apache2/sites-available/

# Activer le site WordPress
a2ensite wordpress.conf

# Redémarrer Apache pour appliquer les changements
systemctl restart apache2

# Activer le module rewrite d'Apache
a2enmod rewrite

# Redémarrer Apache à nouveau
systemctl restart apache2


cd /tmp;
curl -O https://wordpress.org/latest.tar.gz;
tar xzvf latest.tar.gz;
touch /tmp/wordpress/.htaccess;
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php;
if [ ! -d "/tmp/wordpress/wp-content/upgrade" ]; then
    mkdir /tmp/wordpress/wp-content/upgrade
fi
cp -a /tmp/wordpress/. /var/www/html/wordpress;
chown -R www-data:www-data /var/www/html/wordpress;
cp -r /var/www/html/wordpress/ /var/www/html/wordpress2;
rm -rf /var/www/html/wordpress2/wp-content/plugins/;
rm -rf /var/www/html/wordpress2/wp-content/themes/;
ln -s /var/www/html/wordpress/wp-content/plugins/ /var/www/html/wordpress2/wp-content/;
ln -s /var/www/html/wordpress/wp-content/themes/ /var/www/html/wordpress2/wp-content/;

# Exécuter la commande mysql avec le mot de passe
motdepasse="Nostale159951"
nom_utilisateur="root"

# Exécution des commandes MySQL avec le mot de passe automatique
mysql --user="$nom_utilisateur" --password="$motdepasse" <<EOF
CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
EOF

# Édition du fichier de configuration de WordPress
sed -i "s/database_name_here/wordpress/g" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/root/g" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/Nostale159951/g" /var/www/html/wordpress/wp-config.php

# Configuration du serveur pour supporter les uploads volumineux
sed -i '/file_uploads/c\file_uploads = On' /etc/php/7.4/apache2/php.ini
sed -i '/upload_max_filesize/c\upload_max_filesize = 200M' /etc/php/7.4/apache2/php.ini
sed -i '/max_file_uploads/c\max_file_uploads = 2000' /etc/php/7.4/apache2/php.ini
sed -i '/memory_limit/c\memory_limit = 128M' /etc/php/7.4/apache2/php.ini
sed -i '/max_input_time/c\max_input_time = 60000' /etc/php/7.4/apache2/php.ini
# Redémarrage de PHP-FPM
systemctl restart php7.4-fpm

# Exécution des commandes MySQL avec le mot de passe automatique
mysql --user="$nom_utilisateur" --password="$motdepasse" <<EOF
USE mysql;
UPDATE user SET plugin='mysql_native_password' WHERE User ='root';
FLUSH PRIVILEGES;
EOF

apt-get install phpmyadmin 

cd /etc/apache2/sites-available/
# Configuration de phpMyAdmin dans Apache
cat <<EOF > /phpmyadmin.conf
<Directory /var/www/html/phpmyadmin/>
    AllowOverride All
</Directory>
EOF

# Activation du virtualhost pour phpMyAdmin et redémarrage d'Apache
a2ensite /etc/apache2/sites-available/phpmyadmin.config

systemctl restart apache2

ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Création de 1000 instances de WordPress
for ((i=2;i<=1000;i++)); do
    if [ ! -d "/var/www/html/wordpress$i" ]; then
        # Création de copies de WordPress
        cp -r /var/www/html/wordpress2/ /var/www/html/wordpress$i

        # Modification des autorisations
        chown -R www-data:www-data /var/www/html/wordpress$i

        # Modification des liens symboliques et des configurations
        if [ ! -e "/var/www/html/wordpress$i/wp-content/plugins" ]; then
            ln -s /var/www/html/wordpress/wp-content/plugins/ /var/www/html/wordpress$i/wp-content/
        fi
        if [ ! -e "/var/www/html/wordpress$i/wp-content/themes" ]; then
            ln -s /var/www/html/wordpress/wp-content/themes/ /var/www/html/wordpress$i/wp-content/
        fi

        # Modification des fichiers de configuration
        sed -i "s/wordpress$i/g" /etc/apache2/sites-available/wordpress.conf
        sed -i "s/wordpress$i/g" /etc/apache2/sites-available/phpmyadmin.conf
        sed -i "s/wordpress$i/g" /var/www/html/wordpress$i/wp-config.php

        echo "wordpress$i"
    fi
done

a2ensite wordpress*.config;
systemctl restart apache2

echo "FINISH"