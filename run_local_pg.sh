#!/bin/bash -ex

######################
### POSTGRES SETUP ###
######################
if ! brew list | grep "^postgresql"; then
    brew install postgresql
else
    echo "PostgreSQL is already installed."
fi

if ! brew services list | grep -q "postgresql.*started"; then
    brew services start postgresql
else
    echo "PostgreSQL service is already running."
fi

if ! psql -U $(whoami) -tAc "SELECT 1 FROM pg_database WHERE datname='pynapple'" | grep -q 1; then
  psql -U $(whoami) -c "CREATE DATABASE pynapple;"
  psql -U $(whoami) -c "CREATE USER pynapple WITH PASSWORD 'ripe';"
  psql -U $(whoami) -c "GRANT ALL PRIVILEGES ON DATABASE pynapple TO pynapple;"
else
  echo "Schema already setup"
fi


###################
### REDIS SETUP ###
###################
if ! brew list 2>&1 | grep -q "^redis"; then
    echo "Redis is not installed. Installing..."
    brew install redis
else
    echo "Redis is already installed."
fi

# Check if the Redis service has started, start if not
if ! brew services list | grep -q "redis.*started"; then
    echo "Starting Redis service..."
    brew services start redis
else
    echo "Redis service is already running."
fi

echo "Redis setup is complete."


######################
### PYNAPPLE SETUP ###
######################
cd pynapple
VENV_DIR=venv
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python -m venv $VENV_DIR
else
    echo "Virtual environment already exists."

fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt


# run pynapple
export SANDBOX_DATABASE_URI=postgresql://pynapple:ripe@localhost:5432/pynapple
export SANDBOX_REDIS_HOST=localhost
unset SANDBOX_MEMCACHED_HOST

PYTHONPATH=.. FLASK_APP=run.py flask run
