#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

echo "SIMPLE TOOLS PTRODACTYLE"
echo "This tool will help you repair your Pterodactyl panel."
echo ""
echo "Tools:"
echo "1. Repair Panel"
echo ""

repairPanel() {
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
}

while true; do
    read -p "Do you want to run 'Repair Panel'? [y/n]: " yn
    case $yn in
        [Yy]* ) repairPanel; break;;
        [Nn]* ) echo "Operation cancelled."; exit;;
        * ) echo "Please answer y or n.";;
    esac
done
