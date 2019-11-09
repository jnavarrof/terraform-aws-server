provider "aws" {
  # ... other configuration ...
  skip_requesting_account_id = true
  version = "~> 2.0"
  region = "eu-west-1"
}
