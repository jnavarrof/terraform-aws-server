# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "terraform-state-storage-s3" {
    bucket = "tf-state-storage-001"
    versioning {
      enabled = true
    }
    lifecycle {
      prevent_destroy = true
    }
    tags = {
      Name = "S3 Remote Terraform State Store"
    }      
}

output "terraform-state-storage-s3" {
  description = "S3 Remote Terraform State Store"
  value       = aws_s3_bucket.terraform-state-storage-s3.id
}