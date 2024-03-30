### PynApple

pynapple is a simple Python Application... (Py)n(App)le.  It is a dummy service used for the magellan sandbox. The first of it's kind.


### Deploy Pynapple to S3

To deploy pynapple to s3, run the following script:
```bash
./deploy_to_s3.sh
```

The script will tarball up the relevant pynapple files, and upload it to the configured S3 bucket.  On next launch of pynapple ec2 machines they will pick up the latest tarball

### Local Database

### Run Local PostgreSQL and Redis
```shell
./run_local_pg.sh
```

### Run Local MySQL and Memcached
```shell
./run_local_mysql.sh
```