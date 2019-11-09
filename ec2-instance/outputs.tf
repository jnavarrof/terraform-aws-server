output "instances_public_ips" {
  description = "Public IPs assigned to the EC2 instance"
  value       = module.ec2.public_ip
}
