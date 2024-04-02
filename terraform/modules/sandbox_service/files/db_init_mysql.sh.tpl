#!/bin/bash -ex

# INSTALL MYSQL (not installed on amazon linux by default)
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
dnf install mysql80-community-release-el9-1.noarch.rpm -y
dnf install mysql-community-server -y

# ARGS
export MYSQL_PWD="${db_admin_pw}"
DB_ADMIN="${db_admin}"
DB_HOST="${db_host}"
DB_NAME="${db_name}"
USER_NAME="${app_user}"
USER_PASSWORD="${app_user_pw}"

# DO THE DEED
if ! mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "SELECT 1 FROM mysql.user WHERE user = '$USER_NAME' AND host = '%';" | grep -q 1; then
    mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "CREATE USER '$USER_NAME'@'%' IDENTIFIED BY '$USER_PASSWORD';"
    mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$USER_NAME'@'%';"
    mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "FLUSH PRIVILEGES;"
    echo "MySQL user and privileges setup completed."
else
    echo "User $USER_NAME already exists."
fi