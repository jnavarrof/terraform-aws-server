output "instances_public_ips" {
  description = "Public IPs assigned to the EC2 instance"
  value       = module.ec2.public_ip
}

# output "comon_ebs_volume_attachment_id" {
#   description = "The volume ID"
#   value       = aws_volume_attachment.this_ec2.*.volume_id
# }

# output "common_ebs_volume_attachment_instance_id" {
#   description = "The instance ID"
#   value       = aws_volume_attachment.this_ec2.*.instance_id
# }

output "data_ebs_volume_attachment_id" {
  description = "The volume ID"
  value       = aws_volume_attachment.data_ec2.*.volume_id
}

output "data_ebs_volume_attachment_instance_id" {
  description = "The instance ID"
  value       = aws_volume_attachment.data_ec2.*.instance_id
}