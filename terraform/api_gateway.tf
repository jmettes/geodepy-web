resource "aws_api_gateway_rest_api" "api" {
  name = "${local.name_tag_prefix}-api"
}

resource "aws_api_gateway_resource" "vincenty" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "vincenty"
}

resource "aws_api_gateway_method" "vincenty" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.vincenty.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.vincenty.resource_id}"
  http_method = "${aws_api_gateway_method.vincenty.http_method}"

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.geodepy_web_lambda.invoke_arn}"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda_root_integration"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "dev"

  variables {
    hash = "${md5(file("./api_gateway.tf"))}"  # force redeployment
  }
}

output "endpoint" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}
