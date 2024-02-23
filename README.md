### Deploy Pynapple to S3

To deploy pynapple to s3, run the following script:
```bash
./deploy_to_s3.sh
```

The script will tarball up the relevant pynapple files, and upload it to the configured S3 bucket.  On next launch of pynapple ec2 machines they will pick up the latest tarball
