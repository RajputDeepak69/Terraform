terraform {
  #required_version = "6.57.1"
  required_providers {
    aws = {
       source = "hashicorp/aws"
       version = "6.57.1"
    }
    vault = {
       source = "hashicorp/vault"
      version = ">=4.0.0"
    }
   }
}

provider "aws" {
    alias = "default"
    region = "us-east-1"
}
provider "vault" {
  address = var.address
  token = var.token
}