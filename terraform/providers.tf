terraform {
    required_version = "~> 1.1.3"

    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
    }

    backend "s3" {
        bucket = "{BUCKET NAME}"
        key = "prod/terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

provider "aws" {
    alias = "acm_provider"
    region = "us-east-1"
}