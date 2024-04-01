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
    PynappleDeployBucket         = aws_iam_policy.deploy_bucket_read.arn,
    PynappleAppDbSecret          = aws_iam_policy.access_app_db_secret.arn
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

  user_data = base64encode(var.ec2_user_data)

  tags = var.common_tags
}
