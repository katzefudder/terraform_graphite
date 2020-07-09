# Sepcify the backend to use to store terraform's state
terraform {
  backend "s3" {
  }
}

# The various ${var.foo} come from variables.tf

# Specify the provider and access details
provider "aws" {
    region     = "${var.aws_region}"
    profile    = "${var.profile}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

resource "aws_security_group" "ssh_access" {
  name = "ssh_access"
  description = "Allow SSH"
  vpc_id = "${var.vpc}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2003
    to_port = 2004
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2013
    to_port = 2014
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2023
    to_port = 2024
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8125
    to_port = 8125
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8126
    to_port = 8126
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable icmp
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    "Name" = "${var.instance_name}"
    "Team" = "${var.team}"
    "SystemID" = "${var.system_id}"
  }
}

data "template_file" "provision_graphite_node" {
  template = "${file("${path.module}/cloud_init/init_instance.sh.tpl")}"

  vars {
    node_type = "master"
  }
}

resource "aws_instance" "graphite" {
  # provide the subnet id for your account
  subnet_id = "${var.subnets}"

  # what instance type would like to run
  instance_type = "${var.instance_type}"

  iam_instance_profile = "${var.iam_instance_profile}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

  # Lookup the correct AMI based on the region we specified
  ami = "${var.aws_ami_id}"

  # the key's name to be provided to the instance
  key_name = "${var.key_name}"

  # we only define one security group to this instance
  vpc_security_group_ids = ["${aws_security_group.ssh_access.id}"]
  private_ip = "10.236.24.86"

  user_data = "${data.template_file.provision_graphite_node.rendered}"

  tags {
    "Name" = "${var.instance_name}"
    "Team" = "${var.team}"
    "SystemID" = "${var.system_id}"
    "Datadog" = "enabled"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${var.ebs_volume}"
  instance_id = "${aws_instance.graphite.id}"
  skip_destroy = true
}

resource "aws_route53_record" "app" {
  zone_id = "${var.route53_zone_id}"
  name = "graphite"
  type = "A"
  ttl = "60"
  records = ["${aws_instance.graphite.private_ip}"]
}