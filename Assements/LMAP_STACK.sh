#!/usr/bin/bash

# Installs LMAP STACK Setup based On Linux Distros.
SAMPLE_APP_REPO="https://github.com/SPR-Ideas/sample-app.git"
SAMPLE_APP="/tmp/sample-app"
APP_URL="localhost/php"
APACHE_2_SERVICE=""
MYSQL_SERVICE=""
APPACHE_CONFIG=""

if [ -f "/etc/redhat-release" ]
then
    APACHE_2_SERVICE='httpd'
    MYSQL_SERVICE="mysqld"
    APPACHE_CONFIG="httpd/conf/httpd.conf"
else
    APACHE_2_SERVICE='apache2'
    MYSQL_SERVICE="mysql"
    APPACHE_CONFIG="apache2/apache2.conf"
fi


function create_mysql_user(){
        start_LAMP
        echo "================ CREATING USER FOR MYSQL SERVER ============================"
        read -p "ENTER YOUR USERNAME FOR MYSQL_SERVER : "  USERNAME
        read -s -p "ENTER PASSWORD FOR YOUR USERNAMe  $USERNAME  : " PASSWORD
        sudo mysql -e "CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASSWORD';"
        touch "/var/www/html/.htaccess"
        # sudo echo "export MYSQL_USERNAME=$USERNAME" |sudo tee -a /etc/$APACHE_2_SERVICE/envvars
        # sudo echo "export MYSQL_PASSWORD=$PASSWORD" | sudo tee -a /etc/$APACHE_2_SERVICE/envvars
        sudo echo "SetEnv MYSQL_USERNAME $USERNAME" | sudo tee -a /var/www/html/.htaccess
        sudo echo "SetEnv MYSQL_PASSWORD $PASSWORD" | sudo tee -a /var/www/html/.htaccess
}


function  install_LAMP() {
        if [ -f "/etc/redhat-release" ] # Checks weather RedHat Based Distro
    then
        sudo yum update
        sudo yum install php -y
        sudo yum install php-mysqli  -y
        sudo yum install $APACHE_2_SERVICE -y
        sudo yum install mysql-server -y
        sudo mkdir /var/www/html/php
        create_mysql_user
        echo -e "<Directory /var/www/html>\n    AllowOverride All\n</Directory>" | sudo tee -a /etc/$APPACHE_CONFIG


    else
        sudo apt update
        sudo apt install php -y
        sudo apt install php-mysql -y
        sudo apt install apache2 -y
        sudo apt install mysql-server -y
        sudo mkdir /var/www/html/php
        create_mysql_user
        echo -e "<Directory /var/www/html>\n    AllowOverride All\n</Directory>" | sudo tee -a /etc/$APPACHE_CONFIG
    fi
}

function  remove_LAMP() {
        if [ -f "/etc/redhat-release" ] # Checks weather RedHat Based Distro
    then
        sudo yum remove php -y
        sudo yum remove $APACHE_2_SERVICE -y
        sudo yum remove mysql-server -y
        sudo rm -rf /var/lib/mysql
    else
        sudo apt purge php -y
        sudo apt purge apache2 -y
        sudo apt purge mysql-server -y
        sudo rm -rf /var/lib/mysql

        sudo apt autoremove -y
    fi
}

function check_and_install(){
    command -v $MYSQL_SERVICE &> /dev/null
    mysql=$?
    commad -v $APACHE_2_SERVICE &>/dev/null
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

    msql=$(systemctl is-active $MYSQL_SERVICE)
    apache=$(systemctl is-active $APACHE_2_SERVICE)

    if [ "$msql" == "inactive" ]
    then

        sudo systemctl start $MYSQL_SERVICE
    fi

    if [ "$apache" == "inactive" ]
    then
        sudo systemctl start $APACHE_2_SERVICE
    fi
}

# show the status of the LMAP Stack
function status(){
    check_and_install

    mysql=$(systemctl is-active $MYSQL_SERVICE)
    apache=$(systemctl is-active $APACHE_2_SERVICE)

    echo Mysql Status : "$mysql"
    echo apache Status : "$apache"
}

# It stops the LMAP Stack
function stop_LAMP(){

    msql=$(systemctl is-active $MYSQL_SERVICE)
    apache=$(systemctl is-active $APACHE_2_SERVICE)

    if [ "$msql" == "active" ]
    then
        sudo systemctl stop $MYSQL_SERVICE
    fi

    if [ "$apache" == "active" ]
    then
        sudo systemctl stop $APACHE_2_SERVICE
    fi
}

function sample_app(){
    if [ -d $SAMPLE_APP ];
    then
        sudo rm -r $SAMPLE_APP
    fi
    git clone "$SAMPLE_APP_REPO" "$SAMPLE_APP"
    sudo cp $SAMPLE_APP/mysql-connection.php /var/www/html/php/index.php
    sudo systemctl restart $APACHE_2_SERVICE

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