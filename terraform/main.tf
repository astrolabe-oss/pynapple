terraform {
  backend "s3" {
    bucket         = "magellan-tfstate"
    key            = "sandbox1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "magellan_terraform_state"
    encrypt        = "true"
  }
}