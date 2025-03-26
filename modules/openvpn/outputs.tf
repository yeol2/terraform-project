output "instance_id" {
  description = "ID of the OpenVPN instance"
  value       = aws_instance.openvpn.id
}

output "public_ip" {
  description = "Public IP of the OpenVPN instance"
  value       = aws_instance.openvpn.public_ip
}
