##Provider block

terraform {
  required_version = "1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

##S3 Bucket configuration

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "example-state-${data.aws_caller_identity.current.account_id}"

  force_destroy = true
  tags = {
    Name = "Bucket to store Terraform state"
  }
}

##S3 Bucket Versioning

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

##S3 Bucket Output

output "state_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.state_bucket.bucket
}

