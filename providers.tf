terraform {

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.38.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.1"
    }

  }
}

provider "aws" {
  region = "${var.AWS_REGION}"
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
}

provider "tls" {
}

