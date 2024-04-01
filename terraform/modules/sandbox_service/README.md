## Usage
### EC2
* apply it without EC2 User Data
* ```sh
  aws secretsmanager get-secret-value --secret-id sandbox1/pynapple/app_db_pw --query SecretString --output text
  psql -h sandbox1-pynapple1-db.chqoygiays09.us-east-1.rds.amazonaws.com -U dbadmin -d postgres
  CREATE USER pynapple WITH PASSWORD 'PW';
  GRANT ALL PRIVILEGES ON DATABASE pynapple TO pynapple;
  ```
* get the cache host and db host:port, manually update user data - apply again
* build and push application tarball to s3 bucket
* update manually in Route53 the pretty A records pointing to the load balancer
### EKS
* apply it without k8s deployment
* build & deploy to ecr
* deploy k8s (script also creates secrets)


# Requirements
* Plaintext Application Database user password stored in AWS Secrets Manager at: `sandbox1/${var.app_name}/app_db_pw`
* Tarball of the application to be uploaded to `${var.app_name}_latest.tar.gz"` upon module bucket creation (deploy will fail until such)
* ENV Vars will be written to `/home/ec2-user/${var.app_name}.env` - process management should read from here