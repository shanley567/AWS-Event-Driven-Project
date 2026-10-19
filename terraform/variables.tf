# This file is used to define the input variables for the Terraform configuration.
variable "project_name" {
  description = "Project name"
  type = string
  default = "flight-events"
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-north-1"
}