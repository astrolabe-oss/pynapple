#!/bin/bash -ex

# ARGS
export MYSQL_PWD='${db_admin_pw}'
DB_ADMIN="${db_admin}"
DB_HOST="${db_host}"
DB_NAME="${db_name}"
USER_NAME="${app_user}"
USER_PASSWORD="${app_user_pw}"
DB_INIT_S3_BUCKET="${db_init_s3_bucket}"

# Check if database setup flag exists in S3
if aws s3 ls "s3://$DB_INIT_S3_BUCKET/$DB_HOST" &>/dev/null; then
    echo "Database setup flag found in S3. Exiting script."
    exit 0
fi

# INSTALL MYSQL (not installed on Amazon Linux by default)
if ! mysql --version &>/dev/null; then
    echo "MySQL not installed. Proceeding with installation."

    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
    wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
    dnf install mysql80-community-release-el9-1.noarch.rpm -y
    dnf install mysql-community-server -y
else
    echo "MySQL is already installed."
fi

# DO THE DEED
if ! mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "SELECT 1 FROM mysql.user WHERE user = '$USER_NAME' AND host = '%';" | grep -q 1; then
    mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "CREATE USER '$USER_NAME'@'%' IDENTIFIED BY '$USER_PASSWORD';"
    mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$USER_NAME'@'%';"
    mysql -u"$DB_ADMIN" -h "$DB_HOST" -e "FLUSH PRIVILEGES;"
    echo "MySQL user and privileges setup completed."
else
    echo "User $USER_NAME already exists."
fi

# VERIFY NEW USER ACCESS
export MYSQL_PWD="$USER_PASSWORD"
if mysql -u"$USER_NAME" -h "$DB_HOST" "$DB_NAME" -e "SELECT 1;" | grep -q 1; then
    echo "Verification success: User $USER_NAME can access the database $DB_NAME."
else
    echo "Verification failed: User $USER_NAME cannot access the database $DB_NAME."
    exit 1
fi

# Create the flag in S3 to indicate the database has been set up
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "Database setup completed at $TIMESTAMP" > /tmp/db_setup_flag
aws s3 cp /tmp/db_setup_flag "s3://$DB_INIT_S3_BUCKET/$DB_HOST"
rm /tmp/db_setup_flag
echo "Database setup flag created in S3 with timestamp."