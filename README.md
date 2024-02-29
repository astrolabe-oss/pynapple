### PynApple

pynapple is a simple Python Application... (Py)n(App)le.  It is a dummy service used for the magellan sandbox. The first of it's kind.


### Deploy Pynapple to S3

To deploy pynapple to s3, run the following script:
```bash
./deploy_to_s3.sh
```

The script will tarball up the relevant pynapple files, and upload it to the configured S3 bucket.  On next launch of pynapple ec2 machines they will pick up the latest tarball

### Local Database
```shell
brew install postgresql
brew services start postgresql
psql postgres
CREATE DATABASE pynapple;
CREATE USER pynapple WITH PASSWORD 'ripe';
GRANT ALL PRIVILEGES ON DATABASE pynapple TO pynapple;
```

### Run Local
```shell
export PYNAPPLE_DATABASE_URI=postgresql://pynapple:ripe@localhost:5432/pynapple
PYTHONPATH=. FLASK_APP=pynapple/run.py flask run
```