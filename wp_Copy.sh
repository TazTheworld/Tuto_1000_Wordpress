#!/bin/bash

echo "========== Informations nécessaires =========="
read -p "Mot de passe de la base de données ( et du VPS par défaut ) : " Input_Mot_passe_DB
read -p "Le nom de l'utilisateur admin à créer sur les WordPress : " Input_nom_utilisateur_admin
read -p "L'email de l'utilisateur admin : " Input_email_utilisateur_admin
read -p "Le nom des WordPress à créer, il sera utilisé comme nom de dossier sur le serveur et comme nom du site (ex. wordpress) : " Input_nom_dossier_wordpress
read -p "Le mot de passe de l'amdin ? " Input_Mot_passe_admin
read -p "Le nombre de départ du compteur ( 10 pour que le premier wordpress créeé soit wordpress10 par ex. ) : " Input_nombre_depart_compteur
read -p "Le nombre de fin du compteur ( 100 pour le dernier Wordpress créé soit Wordpress100 par ex. ) : " Input_nombre_wordpress_max


echo "------ Move to /tmp folder"

echo "========== Installation/mise à jour de wp CLI =========="

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

php wp-cli.phar --info

chmod +x wp-cli.phar

sudo mv wp-cli.phar /usr/local/bin/wp

wp plugin install --activate

wp cli update

wp --info

echo "========== Installation/mise à jour des packets PHP habituels =========="

apt-get update -y
apt-get upgrade -y

apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip unrar -y

cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<Directory /var/www/html/wordpress/>
    AllowOverride All
</Directory>
EOF

cd /etc/apache2/sites-available/
a2ensite wordpress.conf
systemctl restart apache2
a2enmod rewrite
systemctl restart apache2

<<<<<<< HEAD

cd 
=======
wp core download
wp core config --dbname=mydbname --dbuser=mydbuser --dbpass=mydbpass --dbhost=localhost --dbprefix=whebfubwef_ --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP
wp db create
wp core install --url=http://siteurl.com --title=SiteTitle --admin_user=username --admin_password=mypassword --admin_email=my@email.com
>>>>>>> 51e891ed69b2394437d88828209b01d31c3c6a35

wp core download --locale=fr_FR --allow-root

wp config create --dbname=wordpress --dbuser=root --dbpass=Input_Mot_passe_DB --allow-root

wp db create --allow-root

wp core install --title=Input_nom_dossier_wordpress --admin_user=Input_nom_utilisateur_admin --admin_password=Input_Mot_passe_admin --admin_email=Input_email_utilisateur_admin --allow-root




