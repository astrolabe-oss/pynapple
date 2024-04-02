#!/bin/bash -ex

# INSTALL PSQL (psql is not installed by default on amazon linux)
sudo yum -y install postgresql15

# ARGS
export PGPASSWORD="${db_admin_pw}"
DB_ADMIN="${db_admin}"
DB_HOST="${db_host}"
DB_NAME="${db_name}"
ROLE_NAME="${app_user}"
USER_PASSWORD="${app_user_pw}"

# DO THE DEED
if ! psql -U postgres -h "$DB_HOST" -U "$DB_ADMIN" -d "$DB_NAME" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$ROLE_NAME'" | grep -q 1; then
  psql -U postgres -h "$DB_HOST" -U "$DB_ADMIN" -d "$DB_NAME" -c "CREATE USER $ROLE_NAME WITH PASSWORD '$USER_PASSWORD';"
  psql -U postgres -h "$DB_HOST" -U "$DB_ADMIN" -d "$DB_NAME" -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $ROLE_NAME;"
  echo "PostgreSQL user and privileges setup completed."
else
  echo "User/grants already set up!"
fi