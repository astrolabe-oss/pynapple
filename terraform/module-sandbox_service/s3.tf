################
### NLB LOGS ###
################
## We're not doing NLB logs for cost savings!
# resource "aws_s3_bucket" "nlb_logs" {
#   bucket = "${local.astrolabe_name}-${local.env_app_name}${"-nlb-logs"}"
#   lifecycle {
#     prevent_destroy = "true"
#   }
# }

# data "aws_elb_service_account" "main" {}
#
# resource "aws_s3_bucket_policy" "lb-bucket-policy" {
#   bucket = aws_s3_bucket.nlb_logs.id
#
#   policy = <<POLICY
# {
#   "Id": "nlb_write_policy_pynapple",
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "nlb_write_policy_pynapple",
#       "Action": [
#         "s3:PutObject",
#         "s3:GetBucketAcl"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#           "${aws_s3_bucket.nlb_logs.arn}/*",
#           "${aws_s3_bucket.nlb_logs.arn}"
#       ],
#       "Principal": {
#         "AWS": [
#           "${data.aws_elb_service_account.main.arn}"
#         ]
#       }
#     }
#   ]
# }
# POLICY
# }

##############################
### PYNAPPLE DEPLOY BUCKET ###
##############################
resource "random_string" "deploy_bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "deploy" {
  bucket = "${local.astrolabe_name}-${local.env_app_name}-deploy-${random_string.deploy_bucket_suffix.result}"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.deploy.id
  versioning_configuration {
    status = "Enabled"
  }
}
