locals {
  microservice_prefix = "test"
}

terraform {
  backend "s3" {
    region = "us-west-2"
    bucket = "replicon-ti-calendar-sync-dev"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = "1.26.0"
}
