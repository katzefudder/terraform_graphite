output "aws_ebs_volume.id" {
  value = "${aws_ebs_volume.graphite_storage.id}"
}

output "aws_ebs_volume.arn" {
  value = "${aws_ebs_volume.graphite_storage.arn}"
}