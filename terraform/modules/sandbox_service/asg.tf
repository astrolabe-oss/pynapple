module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = local.env_app_name

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.public_subnets
  key_name                  = var.key_pair_name

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
      max_healthy_percentage = 100
    }
    triggers = ["tag"]
  }

  # Traffic source attachment
  create_traffic_source_attachment = true
  traffic_source_identifier        = module.alb.target_groups["asg"].arn
  traffic_source_type              = "elbv2"

  # Launch template
  launch_template_name        = local.env_app_name
  launch_template_description = "${"Launch template for "}${local.env_app_name}"
  update_default_version      = true

  image_id          = "ami-0440d3b780d96b29d"
  instance_type     = "t2.micro"
  ebs_optimized     = false # t2.micro does not allow ebs optimized
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "${local.env_app_name}${"_asg"}"
  iam_role_path               = "/ec2/"
  iam_role_description        = "${"IAM role for "}${local.env_app_name}${" ASG"}"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    PynappleDeployBucket         = aws_iam_policy.deploy_bucket_read.arn
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = concat(var.security_group_ids,[
        aws_security_group.instances_default.id,
        aws_security_group.alb_to_asg.id
      ])
      associate_public_ip_address = true
    }
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash -x
    # PWD
    cd /home/ec2-user

    # DB INIT SCRIPTS
    cat <<'SCRIPT' > ./db_init_pg.sh
    ${templatefile("${path.module}/files/db_init_pg.sh.tpl",{
        app_user=var.app_name,
        app_user_pw=aws_secretsmanager_secret_version.application_db_user_pass.secret_string,
        db_admin=local.db_admin,
        db_admin_pw=jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"],
        db_host=module.rdbms.db_instance_address,
        db_name=var.app_db_name
    })}
    SCRIPT
    chmod 700 db_init_pg.sh
    cat <<'SCRIPT' > ./db_init_mysql.sh
    ${templatefile("${path.module}/files/db_init_mysql.sh.tpl",{
        app_user=var.app_name,
        app_user_pw=aws_secretsmanager_secret_version.application_db_user_pass.secret_string,
        db_admin=local.db_admin,
        db_admin_pw=jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"],
        db_host=module.rdbms.db_instance_address,
        db_name=var.app_db_name
    })}
    SCRIPT
    chmod 700 db_init_mysql.sh

    ### UPDATE AWS CLI
    sudo yum -y remove awscli
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

    ### GET DEPLOY FILES ###
    mkdir ${var.app_name}
    cd ${var.app_name}
    aws s3 cp s3://${aws_s3_bucket.deploy.bucket}/deploy_latest.tar.gz .
    tar -xzf deploy_latest.tar.gz
    chown -R ec2-user:ec2-user *
    chmod +x deploy/install_and_run.sh

    ### CONFIGURE ###
    echo "SANDBOX_APP_NAME=${var.app_name}" >> /etc/environment
    echo "export SANDBOX_APP_NAME=${var.app_name}" >> /etc/profile
    sudo su - ec2-user
    echo "SANDBOX_APP_NAME=${var.app_name}" >> /home/ec2-user/${var.app_name}.env
    echo "SANDBOX_DATABASE_URI=${local.database_conn_str}" >> /home/ec2-user/${var.app_name}.env
    ${var.cache_engine == "redis" ? "echo \"SANDBOX_REDIS_HOST=${module.cache.cluster_cache_nodes[0].address}\" >> /home/ec2-user/${var.app_name}.env" : ""}
    ${var.cache_engine == "memcached" ? "echo \"SANDBOX_MEMCACHED_HOST=${module.cache.cluster_cache_nodes[0].address}:11211\" >> /home/ec2-user/${var.app_name}.env" : ""}

    ### INSTALL AND RUN ###
    export SANDBOX_APP_NAME="${var.app_name}"  # couldn't figure out how to make su ec2-user read this!
    ./deploy/install_and_run.sh

    ### SETUP SSM SSH ###
    sudo systemctl start amazon-ssm-agent
  EOF
  )

  tags = var.common_tags
}
