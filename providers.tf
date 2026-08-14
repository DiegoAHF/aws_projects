terraform {
  required_version = "1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57"
    }
  }

  backend "s3" {
  bucket = "example-state-444832973357" #Replace with your own S3 bucket name
  key    = "State/terraform.tfstate"
  region = "us-east-2"
  use_lockfile = true
  encrypt      = true
}
}

provider "aws" {
  region = "us-east-2"
}



