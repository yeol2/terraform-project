output "instance_id" {
  description = "ID of the OpenVPN instance"
  value       = aws_instance.openvpn.id
}

output "public_ip" {
  description = "OpenVPN의 퍼블릭 IP"
  value       = aws_eip.openvpn_eip.public_ip
}
