variable "profile" {}

variable "team" {
  default = "atlas"
}

variable "aws_account" {}

# set a System ID
variable "system_id" {
  description = "SystemID in AWS"
}

variable "key_name" {
    description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "eu-central-1"
}

variable "route53_zone_id" {
  default = "your-zone-id"
}

variable "aws_access_key" {
    description = "AWS Access Key"
    default = ""
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
    default = ""
}

variable "instance_type" {
    description = "Instance type"
    default = "t2.large"
}

variable "instance_name" {
    description = "Instance Name"
}

variable "ebs_volume" {
  description = "Graphite's EBS Volume (e.g. vol-038df3a13c510a0cf)"
}

variable "iam_instance_profile" {
}

variable "aws_ami_id" {}

variable "subnets" {
}

variable "vpc" {
}

variable "vpc_id" {
  default = ""
}

variable "datadog_monitoring" {
  default = "enabled"
}