variable "ebs_name" {
  default = "graphite_ebs"
}

variable "profile" {}

variable "availability_zone" {
  default = "eu-central-1a"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  default = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  default = ""
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "eu-central-1"
}

variable "team" {}

variable "system_id" {}