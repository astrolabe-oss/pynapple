module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = local.env_app_name

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  vpc_zone_identifier       = module.vpc.public_subnets
  key_name                  = aws_key_pair.infra_2024_1_30_1.key_name

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
  ebs_optimized     = false  # t2.micro does not allow ebs optimized
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
    PynappleDeployBucket = aws_iam_policy.pynapple_deploy_bucket_read.arn
  }

  network_interfaces = [
    {
      delete_on_termination       = true
      description                 = "eth0"
      device_index                = 0
      security_groups             = [
        module.vpc.default_security_group_id,
        aws_security_group.allow_ssh.id,
        aws_security_group.pynapple_alb_to_asg.id
      ]
      associate_public_ip_address = true
    }
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    cd /home/ec2-user
    aws s3 cp s3://guruai-pynapple-deploy/pynapple_latest.tar.gz .
    tar -xzf pynapple_latest.tar.gz
    chown -R ec2-user:ec2-user pynapple
    chmod +x pynapple/scripts/install_and_run.sh
    sudo su ec2-user
    cd pynapple
    ./scripts/install_and_run.sh
  EOF
  )

  tags = local.common_tags
}
