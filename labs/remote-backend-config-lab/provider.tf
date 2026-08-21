terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.57.1"
        }
    }
    backend "s3" {
        bucket = "my-bucket-123"
        encrypt = true
        region = "us-east-1"
        key = "deepak/terraform.tfstate"
        use_path_style = true 
    }
}
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_region_validation      = true 
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

  endpoints {
    s3          = "http://localhost:4566"
    iam         = "http://localhost:4566"
    lambda      = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    dynamodb    = "http://localhost:4566"
  }
}