# This file is used to configure the AWS provider for Terraform.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}