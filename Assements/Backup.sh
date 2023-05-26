#!/bin/bash
BACKUP_DIR="/opt/backup"

echo ===============================================================================
time_stamp=$(date "+%Y-%m-%d-%H:%M:%S")
echo -e "\t\t\t Backup On : $time_stamp "
echo
sudo systemctl stop mysql
if [ ! -d $BACKUP_DIR ]
then
    sudo mkdir $BACKUP_DIR
fi
if [ ! -f "$BACKUP_DIR/backuplog.log" ]
then
    touch "$BACKUP_DIR/backuplog.log"
fi
sudo tar -cvf "$BACKUP_DIR/$time_stamp-backup.tar"  /var/lib/mysql/
sudo systemctl start mysql
echo ================================================================================