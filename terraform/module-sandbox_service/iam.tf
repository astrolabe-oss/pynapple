resource "aws_iam_policy" "deploy_bucket_read" {
  name        = "${local.env_app_name}-deploy"
  description = "Policy that allows read access to a the ${local.env_app_name} deploy s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.deploy.bucket}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.deploy.bucket}"
      },
      {
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
      }
    ]
  })
}
