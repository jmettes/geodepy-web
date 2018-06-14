resource "aws_s3_bucket_object" "geodepy_web_source_object" {
  bucket = "${aws_s3_bucket.lambda_source_bucket.id}"
  key    = "${local.name_tag_prefix}/geodepy-web-lambda.zip"
  source = "../packaging/package_scipy.zip"
  etag   = "${md5(file("../packaging/package_scipy.zip"))}"
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

resource "aws_lambda_function" "geodepy_web_lambda" {
  s3_bucket         = "${aws_s3_bucket_object.geodepy_web_source_object.bucket}"
  s3_key            = "${aws_s3_bucket_object.geodepy_web_source_object.key}"
  function_name     = "${local.name_tag_prefix}-lambda"
  role              = "${aws_iam_role.lambda_role.arn}"
  handler           = "handler.handler"
  runtime           = "python3.6"
  timeout           = "300"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.geodepy_web_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.api.id}/*/*/*"
}
