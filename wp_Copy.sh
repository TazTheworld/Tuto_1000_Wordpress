echo "========== Informations nécessaires =========="
echo "Mot de passe de la base de données ( et du VPS par défaut ) :"
read Input_Mot_passe_DB
echo "Faire la copie d'un WordPress déjà installé (y/n) ?"
read Input_faire_copy_installé
echo "Le nom de l'utilisateur admin à créer sur les WordPress : "
read Input_nom_utilisateur_admin
echo "L'email de l'utilisateur admin : "
read Input_email_utilisateur_admin
echo "Le nom des WordPress à créer, il sera utilisé comme nom de dossier sur le serveur et comme nom du site (ex. wordpress) : "
read Input_nom_dossier_wordpress
echo "Le mot de passe de l'amdin ? "
read Input_Mot_passe_admin
echo "Le nombre de départ du compteur ( 10 pour que le premier wordpress créeé soit wordpress10 par ex. ) : "
read Input_nombre_depart_compteur
echo "Le nombre de fin du compteur ( 100 pour le dernier Wordpress créé soit Wordpress100 par ex. ) : "
read Input_nombre_wordpress_max

cd /tmp/

echo "------ Move to /tmp folder"

echo "========== Installation/mise à jour de wp CLI =========="

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

php wp-cli.phar --info

chmod +x wp-cli.phar

sudo mv wp-cli.phar /usr/local/bin/wp

wp cli update

wp --info

echo "========== Installation/mise à jour des packets PHP habituels =========="

apt-get update -y
apt-get upgrade -y

apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip unrar -y

systemctl restart apache2

sudo -u USER -i -- wp core download --allow-root

sudo -u USER -i -- wp db create --dbhost=localhost --dbuser=root --dbpass=Input_Mot_passe_DB --dbcharset=utf8 --dbcollate=utf8_unicode_ci --allow-root

sudo -u USER -i -- wp config create --dbname=wordpress --dbuser=root --dbpass=Input_Mot_passe_DB --allow-root

sudo -u USER -i -- wp core install --title=Input_nom_dossier_wordpress --admin_user=Input_nom_utilisateur_admin --admin_password=Input_Mot_passe_admin --admin_email=Input_email_utilisateur_admin --allow-root

sudo -u USER -i -- wp post delete $(wp post list --post_type=page --format=ids --post_status=publish) --force --allow-root



