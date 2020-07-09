# Sepcify the backend to use to store terraform's state
terraform {
  backend "s3" {
  }
}

# Specify the provider and access details
provider "aws" {
  region     = "${var.aws_region}"
  profile    = "${var.profile}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

# Storage device not to be destroyed when the ec2 instance goes away
resource "aws_ebs_volume" "graphite_storage" {
  availability_zone = "${var.availability_zone}"
  size              = "20"

  tags {
    "Name" = "${var.ebs_name}",
    "Team" = "${var.team}"
    "SystemID" = "${var.system_id}",
  }
}

resource "aws_ebs_snapshot" "graphite_snapshot" {
  volume_id = "${aws_ebs_volume.graphite_storage.id}"

  tags {
    "Name" = "${var.ebs_name}",
    "Team" = "${var.team}"
    "SystemID" = "${var.system_id}",
  }
}