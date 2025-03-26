output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "launch_template_id" {
  value = aws_launch_template.lt.id
}
output "asg_sg_id" {
  value = aws_security_group.asg_ec2_sg.id
}
output "asg_ec2_sg_id" {
  value = aws_security_group.asg_ec2_sg.id
}
