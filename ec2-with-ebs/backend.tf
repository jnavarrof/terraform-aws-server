terraform {
 backend "s3" {
 encrypt = true
 bucket = "tf-state-storage-001"
 region = "eu-west-1"
 key = "tf-state"
 }
}