terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.57.1"
    }
  }
}

provider "aws" {
  alias = "mera-region"
  region = "us-east-1"
}