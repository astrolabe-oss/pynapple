## Usage
* terraform apply new service - it's not quite seamless
  * terraform apply
    * ec2 will fail because there is no tarball
      * build and deploy the tarball to the CORRECT s3 bucket to proceed!
    * eks will fail because there is no container in the ECR
      * build and deploy the docker container to the CORRECT ECR repo to proceed!
  * 
  * NOW.. ssh to the ec2 instance created
    * run `/home/ec2-user/db_init_pg.sh` or `/home/ec2-user/db_init_mysql.sh`
  * terminate ec2 instance, new one should come up and succeed!
  * k8s deployment should succeed now, restart it if needed
* validate service health manually by ec2 load balancer and k8s load balancer/service
* update `../../../account_cr/route53.tf` with new load balancer values for pretty DNS records 

## Notes
* module creates DB/User/Pass and writes the connection string in the env to
  * SANDBOX_DATABASE_URI (either Postgres or MySQL)
  * SANDBOX_REDIS_HOST (if any)
  * SANDBOX_MEMCACHED_HOST (if any)
  * SANDBOX_APP_NAME
* for EC2: module expects a script to be located at `$TARBALL_ROOT/deploy/install_and_run.sh` and it will run it in user_data script
* Plaintext Application Database user password stored in AWS Secrets Manager at: `sandbox1/${var.app_name}/app_db_pw`
* Tarball of the application to be uploaded to `deploy_latest.tar.gz"` upon module bucket creation (deploy will fail until such)
* ENV Vars will be written to `/home/ec2-user/${var.app_name}.env` - process management should read from here