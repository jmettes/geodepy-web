provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_tag_prefix = "${var.application}"
  account_id  = "${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "lambda_source_bucket" {
  bucket = "${local.name_tag_prefix}-lambda-source"
}
