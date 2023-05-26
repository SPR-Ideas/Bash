#!/bin/bash
sudo systemctl stop mysql
if [ ! -d "/opt/backup" ]
then
    sudo mkdir "/opt/backup"
fi
offset=$(date "+%Y-%m-%d-%H:%M:%S")
sudo tar -cvf "/opt/backup/$offset-backup.sh"  /var/lib/mysql/
sudo systemctl start mysql