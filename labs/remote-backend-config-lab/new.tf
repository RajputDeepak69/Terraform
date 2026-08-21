# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "my-bucket-123"
resource "aws_s3_bucket" "existing_bucket" {
  bucket              = "my-bucket-123"
  bucket_namespace    = "global"
  bucket_prefix       = null
  force_destroy       = false
  object_lock_enabled = false
  region              = "us-east-1"
  tags = {
    Name        = "my bucket"
    environment = "testing"
  }
  tags_all = {
    Name        = "my bucket"
    environment = "testing"
  }
}
