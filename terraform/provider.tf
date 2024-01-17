terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = "<AWS_ACCESS_KEY>"
  secret_key = "<AWS_SECRET_ACCESS_KEY>"
}

