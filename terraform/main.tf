provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

locals {
  name_tag_prefix = "${var.application}"
}

resource "aws_s3_bucket" "lambda_source_bucket" {
  bucket = "${local.name_tag_prefix}-lambda-source"
}

data "archive_file" "geodepy_web_source" {
  type        = "zip"
  source_file = "handler.py"
  output_path = "geodepy-web-lambda.zip"
}

resource "aws_s3_bucket_object" "geodepy_web_source_object" {
  bucket = "${aws_s3_bucket.lambda_source_bucket.id}"
  key    = "${local.name_tag_prefix}/geodepy-web-lambda.zip"
  source = "${data.archive_file.geodepy_web_source.output_path}"
  etag   = "${data.archive_file.geodepy_web_source.output_md5}"
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.name_tag_prefix}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_lambda_policy" {
  name = "${local.name_tag_prefix}-cloudwatch"
  role = "${aws_iam_role.lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_lambda_function" "geodpy_web_lambda" {
  s3_bucket         = "${aws_s3_bucket_object.geodepy_web_source_object.bucket}"
  s3_key            = "${aws_s3_bucket_object.geodepy_web_source_object.key}"
  s3_object_version = "${aws_s3_bucket_object.geodepy_web_source_object.version_id}"
  source_code_hash  = "${data.archive_file.geodepy_web_source.output_md5}"
  function_name     = "${local.name_tag_prefix}-lambda"
  role              = "${aws_iam_role.lambda_role.arn}"
  handler           = "handler.handler"
  runtime           = "python3.6"
}
