terraform {
    required_providers {
      aws = {
        source ="hashicorp/aws"
        version = "6.57.1"
      }
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

  endpoints {
    s3          = "http://localhost:4566"
    iam         = "http://localhost:4566"
    lambda      = "http://localhost:4566"
    ec2         = "http://localhost:4566"
    dynamodb    = "http://localhost:4566"
  }
}