# Uncomment and customize for your usage
# terraform {
#   backend "s3" {
#     bucket         = "astrolabe-tfstate"
#     key            = "astrolabe/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "astrolabe_terraform_state"
#     encrypt        = "true"
#   }
# }