###################
### MYSQL SETUP ###
###################
if ! brew list | grep "mysql"; then
    brew install mysql
else
    echo "MySQL is already installed."
fi

if ! brew services list | grep -q "mysql.*started"; then
    brew services start mysql
else
    echo "MySQL service is already running."
fi

MYSQL_DB="pynapple"
MYSQL_USER="pynapple"
MYSQL_PASS="ripe"

# Check for existence of the database
if ! mysql -uroot -e "USE $MYSQL_DB;" 2>/dev/null; then
    echo "Database $MYSQL_DB does not exist. Creating..."
    mysql -uroot -e "CREATE DATABASE $MYSQL_DB;"
    mysql -uroot -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASS';"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO '$MYSQL_USER'@'localhost';"
    mysql -uroot -e "FLUSH PRIVILEGES;"
    echo "MySQL setup completed."
else
    echo "Database $MYSQL_DB already exists."
fi

#######################
### MEMCACHED SETUP ###
#######################
# Check if Memcached is installed, install if not
if ! brew list 2>&1 | grep -q "^memcached"; then
    echo "Memcached is not installed. Installing..."
    brew install memcached
else
    echo "Memcached is already installed."
fi

# Check if the Memcached service has started, start if not
if ! brew services list | grep -q "memcached.*started"; then
    echo "Starting Memcached service..."
    brew services start memcached
else
    echo "Memcached service is already running."
fi

echo "Memcached setup is complete."

######################
### PYNAPPLE SETUP ###
######################
cd pynapple
VENV_DIR="venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv $VENV_DIR
else
    echo "Virtual environment already exists."
fi

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Run pynapple
# Adjust the database URI for MySQL
export PYNAPPLE_DATABASE_URI="mysql+pymysql://pynapple:ripe@localhost/pynapple"
export PYNAPPLE_MEMCACHED_HOST="localhost:11211"
unset PYNAPPLE_REDIS_HOST
env | grep PYNAPPLE
PYTHONPATH=.. FLASK_APP=run.py flask run