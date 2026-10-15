# This file is used to configure the AWS provider for Terraform. 
# It specifies the required version of Terraform and the AWS provider, 
# as well as the AWS region to be used for resource creation.
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}