resource "aws_s3_bucket" "bucket" {
    bucket = "my-bucket-1234"
    tags = {
        Name = "my bucket"
        environment = "testing"
    }
}
resource "aws_vpc" "domain-expansion" {
    cidr_block = "10.0.0.0/20"
}
resource "aws_dynamodb_table" "my-table" {
    name = "state-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
      name = "LockID"
      type = "S"
    }
}