#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

echo "SIMPLE TOOLS PTRODACTYLE"
echo ""
echo "Select a tool:"
echo "1. Repair Panel"
echo "2. Exit"
echo ""

read -p "Enter your choice [1/2]: " choice

case $choice in
    1)
        echo "Starting panel repair..."
        cd /var/www/pterodactyl || { echo "Failed to navigate to /var/www/pterodactyl"; exit 1; }

        php artisan down
        rm -rf /var/www/pterodactyl/resources
        curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
        chmod -R 755 storage/* bootstrap/cache
        composer install --no-dev --optimize-autoloader
        php artisan view:clear
        php artisan config:clear
        php artisan migrate --seed --force
        chown -R www-data:www-data /var/www/pterodactyl/*
        php artisan queue:restart
        php artisan up

        echo "Panel repair completed successfully."
        ;;
    2)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option. Please run the script again and choose 1 or 2."
        exit 1
        ;;
esac
