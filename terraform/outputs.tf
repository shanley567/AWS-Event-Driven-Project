# This file is used to define the output values for the Terraform configuration.
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.region
}