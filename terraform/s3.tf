# stores flags to indicate whether db hosts have been set up yet, read in by ec2 instance on boot
resource "aws_s3_bucket" "db_init" {
  bucket = "astrolabe-db-init"
}