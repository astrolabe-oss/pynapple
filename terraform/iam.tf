resource "aws_iam_policy" "pynapple_deploy_bucket_read" {
  name        = "${local.env_app_name}-deploy"
  description = "Policy that allows read access to a the ${local.env_app_name} deploy s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::guruai-${local.env_app_name}-deploy/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::guruai-${local.env_app_name}-deploy"
      },
      {
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "pynapple_access_app_db_secret" {
  name        = "${local.env_app_name}-access-app-db-secret"
  description = "Policy that allows read access to a the ${local.env_app_name} app user db password"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue",
        Resource = "arn:aws:secretsmanager:us-east-1:517988372097:secret:sandbox1/pynapple/app_db_pw-*",
        Effect   = "Allow"
      }
    ]
  })
}
