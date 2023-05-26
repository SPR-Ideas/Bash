#!/usr/bin/bash

# Installs LMAP STACK Setup based On Linux Distros.
SAMPLE_APP_REPO="https://github.com/SPR-Ideas/sample-app.git"
SAMPLE_APP="/tmp/sample-app"
APP_URL="localhost/php"


function create_mysql_user(){
        echo "================ CREATING USER FOR MYSQL SERVER ============================"
        read -p "ENTER YOUR USERNAME FOR MYSQL_SERVER : "  USERNAME
        read -s -p "ENTER PASSWORD FOR YOUR USERNAMe  $USERNAME  : " PASSWORD
        sudo mysql -u root -p -e "CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASSWORD';"
        sudo echo "export MYSQL_USERNAME=$USERNAME" |sudo tee -a /etc/apache2/envvars
        sudo echo "export MYSQL_PASSWORD=$PASSWORD" | sudo tee -a /etc/apache2/envvars
}


function  install_LAMP() {
        if [ -f "/etc/redhat-release" ] # Checks weather RedHat Based Distro
    then
        sudo yum install php  -y
        sudo yum install httpd -y
        sudo yum install mysql-server -y

    else
        sudo apt update
        sudo apt install php php-mysql -y
        sudo apt install apache2 -y
        sudo apt install mysql-server -y
        sudo mkdir /var/www/html/php
        create_mysql_user

    fi
}

function  remove_LAMP() {
        if [ -f "/etc/redhat-release" ] # Checks weather RedHat Based Distro
    then
        sudo yum remove php -y
        sudo yum remove apache2 -y
        sudo yum remove mysql-server -y
    else
        sudo apt purge php -y
        sudo apt purge apache2 -y
        sudo apt purge mysql-server -y
        sudo rm -rf /var/lib/mysql

        sudo apt autoremove -y
    fi
}

function check_and_install(){
    command -v mysql &> /dev/null
    mysql=$?
    commad -v apache2 &>/dev/null
    apache2=$?

    if [ $mysql == 1 ] ||[ $apache2 == 1 ]
    then
        echo
        echo LAMP Stack is not setup yet, tying to install packages.
        echo

        install_LAMP
    fi
}

    # Start the LAMP Server
function start_LAMP(){

    check_and_install

    msql=$(systemctl is-active mysql)
    apache=$(systemctl is-active apache2)

    if [ "$msql" == "inactive" ]
    then
        systemctl start mysql
    fi
    if [ "$apache" == "inactive" ]
    then
        systemctl start apache2
    fi
}

# show the status of the LMAP Stack
function status(){
    check_and_install

    mysql=$(systemctl is-active mysql)
    apache=$(systemctl is-active apache2)

    echo Mysql Status : "$mysql"
    echo apache Status : "$apache"
}

# It stops the LMAP Stack
function stop_LAMP(){

    msql=$(systemctl is-active mysql)
    apache=$(systemctl is-active apache2)

    if [ "$msql" == "active" ]
    then
        systemctl stop mysql
    fi

    if [ "$apache" == "active" ]
    then
        systemctl stop apache2
    fi
}

function sample_app(){
    if [ -d $SAMPLE_APP ];
    then
        sudo rm -r $SAMPLE_APP
    fi
    git clone "$SAMPLE_APP_REPO" "$SAMPLE_APP"
    sudo cp $SAMPLE_APP/mysql-connection.php /var/www/html/php/index.php
    sudo systemctl restart apache2

}

function test_app(){
    wget --spider $APP_URL &> /dev/null
    if [ $? -eq 0 ]
    then
        echo
        echo "Status of http://$APP_URL : UP "
        echo "sucess"
        echo
    else
        echo
        echo "Status of http://$APP_URL : Down "
        echo 'failed'
        echo
    fi
}


if [ $1 == "install" ]
then
    install_LAMP
elif [ $1 == "start" ]
then
    start_LAMP

elif [ $1 == "stop" ]
then
    stop_LAMP
elif [ $1 == "status" ]
then
    status
elif [ $1 == "remove" ]
then
    remove_LAMP
elif [ $1 == "sample-app" ]
then
    sample_app
elif [ $1 == "check-app" ]
then
    test_app
elif [ $1 == "backup-db" ]
then
    source Backup.sh >> /opt/backup/backuplog.log 2>&1
else
    echo "invalid Argument"
fi