# create an S3 bucket to store and share data
resource "aws_s3_bucket" "shared-storage-s3" {
    bucket = "shared-storage-s3"
    versioning {
      enabled = false
    }
    lifecycle {
      prevent_destroy = false
    }
    tags = {
      Name = "S3 Shared bucket"
    }      
}