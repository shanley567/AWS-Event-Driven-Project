# This file is used to define the input variables for the Terraform configuration.
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-north-1"
}