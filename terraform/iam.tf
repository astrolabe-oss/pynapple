resource "aws_iam_policy" "pynapple_deploy_bucket_read" {
  name        = "${local.app_name}-deploy"
  description = "Policy that allows read access to a the ${local.app_name} deploy s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::guruai-${local.app_name}-deploy/*"
      },
      {
        "Effect": "Allow",
        "Action": "s3:ListBucket",
        "Resource": "arn:aws:s3:::guruai-${local.app_name}-deploy"
      },
      {
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
      }
    ]
  })
}
