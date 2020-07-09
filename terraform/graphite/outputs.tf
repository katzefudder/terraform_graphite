output "aws_instance.id" {
  value = "${aws_instance.graphite.id}"
}

output "aws_instance.private_ip" {
  value = "${aws_instance.graphite.private_ip}"
}