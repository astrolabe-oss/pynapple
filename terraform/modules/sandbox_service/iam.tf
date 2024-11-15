resource "aws_iam_policy" "deploy_bucket_read" {
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

resource "aws_iam_policy" "db_init_bucket_rw" {
  name        = "${local.env_app_name}-db-init-bucket-rw"
  description = "Policy that allows read/write access to a the ${local.env_app_name} db init s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject"
        ],
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.db_init_s3_bucket}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::${var.db_init_s3_bucket}"
      },
      {
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
      }
    ]
  })
}