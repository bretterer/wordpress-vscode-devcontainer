#! /bin/bash

WP_SITE_TITLE="Development Site"
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=password
WP_ADMIN_EMAIL="admin@localhost.com"

# Space seperated list of plugins to install
WP_PLUGINS=

# Set to true to initalize your wordpress install (on the next container rebuild)
WP_INITALIZE=true

# Set to false if you do not want to remove the default plugins with a clean wordpress install
WP_REMOVE_DEFAULT_PLUGINS=true

echo "WP SETUP SCRIPT"

DEVDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd /var/www/html
if $WP_INITALIZE ; then
    echo "INITALIZING WORDPRESS"
    if $WP_REMOVE_DEFAULT_PLUGINS ; then
        wp plugin delete akismet
        wp plugin delete hello-dolly
    fi

    wp db reset --yes
    rm -f wp-config.php
fi

if [ ! -f wp-config.php ]; then
    echo "CONFIGURING WORDPRESS"

    wp config create --dbhost="db" --dbname="wordpress" --dbuser="wp_user" --dbpass="wp_pass" --skip-check
    wp core install --url="http://localhost" --title="$WP_SITE_TITLE" --admin_user="$WP_ADMIN_USER" --admin_email="$WP_ADMIN_EMAIL" --admin_password="$WP_ADMIN_PASSWORD" --skip-email
    if $WP_PLUGINS ; then
        wp plugin install $WP_PLUGINS --activate
    fi

    if [ -d $DEVDIR/sql/ ]; then
        echo "IMPORTING SQL DATA"
        #Data import
        cd $DEVDIR/sql/
        for f in *.sql; do
            wp db import f
        done
    fi

else
    echo "WORDPRESS ALREADY CONFIGURED"
fi