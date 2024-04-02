## Usage
* terraform apply new service
  * terraform k8s deployment will take forever and not complete, this is because DB is not set up!, proceed 
  * ssh to the ec2 instance created
  * run `/home/ec2-user/db_init_pg.sh` or `/home/ec2-user/db_init_mysql.sh`
  * k8s deployment should succeed now!
* relaunch EC2 server(s)
* validate service health manually by ec2 load balancer and k8s load balancer/service
* update `../../../account_cr/route53.tf` with new load balancer values for pretty DNS records 

## Notes
* module creates DB/User/Pass and writes the connection string in the env to
  * SANDBOX_DATABASE_URI (either Postgres or MySQL)
  * SANDBOX_REDIS_HOST (if any)
  * SANDBOX_MEMCACHED_HOST (if any)
  * SANDBOX_APP_NAME

# Requirements
* Plaintext Application Database user password stored in AWS Secrets Manager at: `sandbox1/${var.app_name}/app_db_pw`
* Tarball of the application to be uploaded to `deploy_latest.tar.gz"` upon module bucket creation (deploy will fail until such)
* ENV Vars will be written to `/home/ec2-user/${var.app_name}.env` - process management should read from here