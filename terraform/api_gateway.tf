resource "aws_api_gateway_rest_api" "api" {
  name = "${local.name_tag_prefix}-api"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "{proxy+}"
}

//resource "aws_api_gateway_method" "method" {
//  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
//  resource_id = "${aws_api_gateway_resource.proxy.id}"
//  http_method = "ANY"
//  authorization = "NONE"
//}
//
//resource "aws_api_gateway_integration" "lambda_integration" {
//  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
//  resource_id = "${aws_api_gateway_method.method.id}"
//  http_method = "${aws_api_gateway_method.method.http_method}"
//
//  integration_http_method = "POST"
//  type                    = "AWS_PROXY"
//  uri                     = "${aws_lambda_function.geodpy_web_lambda.invoke_arn}"
//}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.geodepy_web_lambda.invoke_arn}"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
//    "aws_api_gateway_integration.lambda_integration",
    "aws_api_gateway_integration.lambda_root_integration"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "dev"
}

output "endpoint" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}
