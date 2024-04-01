module "pynapple1" {
  source = "./modules/sandbox_service"

  # app
  env_name       = local.env_name
  app_name       = "pynapple1"

  # networking
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  public_subnets     = module.vpc.public_subnets
  private_subnets    = module.vpc.private_subnets
  database_subnets   = module.vpc.database_subnets
  security_group_ids = [
    aws_security_group.allow_ssh.id,
    module.vpc.default_security_group_id
  ]
  key_pair_name      = aws_key_pair.infra_2024_1_30_1.key_name
  ip_addresses_devs  = local.ip_addresses_devs

  # components
  create_redis         = true
  app_db_name          = "pynapple"
  app_db_pw_secret_arn = "arn:aws:secretsmanager:us-east-1:517988372097:secret:sandbox1/pynapple1/app_db_pw-*"
  # tags
  common_tags    = local.common_tags

  # user data
  ec2_user_data = base64encode(<<-EOF
    #!/bin/bash -x

    ### UPDATE AWS CLI
    sudo yum -y remove awscli
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

    ### GET DEPLOY FILES ###
    cd /home/ec2-user
    mkdir pynapple
    cd pynapple
    aws s3 cp s3://guruai-sandbox1-pynapple1-deploy/pynapple_latest.tar.gz .
    tar -xzf pynapple_latest.tar.gz
    chown -R ec2-user:ec2-user pynapple
    chmod +x pynapple/scripts/install_and_run.sh

    ### CONFIGURE ###
    sudo su ec2-user
    SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id sandbox1/pynapple1/app_db_pw --query SecretString --output text)
    echo "PYNAPPLE_DATABASE_URI=postgresql://pynapple:$SECRET_VALUE@sandbox1-pynapple1-db.chqoygiays09.us-east-1.rds.amazonaws.com:5432/pynapple" >> /home/ec2-user/pynapple.env
    echo "PYNAPPLE_REDIS_HOST=sandbox1-pynapple1-cache.aklxnu.0001.use1.cache.amazonaws.com" >> /home/ec2-user/pynapple.env

    ### INSTALL AND RUN ###
    cd pynapple
    ./scripts/install_and_run.sh

    ### SETUP SSM SSH ###
    sudo systemctl start amazon-ssm-agent
  EOF
  )

}
