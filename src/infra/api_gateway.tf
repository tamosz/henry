resource "aws_api_gateway_rest_api" "henry_api" {
  name        = "henry_api"
  description = "API Gateway for Discord Bot"
}

resource "aws_api_gateway_resource" "henry_resource" {
  rest_api_id = aws_api_gateway_rest_api.henry_api.id
  parent_id   = aws_api_gateway_rest_api.henry_api.root_resource_id
  path_part   = "commands"
}

resource "aws_api_gateway_method" "henry_bot_method" {
  rest_api_id   = aws_api_gateway_rest_api.henry_api.id
  resource_id   = aws_api_gateway_resource.henry_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "henry_integration" {
  rest_api_id             = aws_api_gateway_rest_api.henry_api.id
  resource_id             = aws_api_gateway_resource.henry_resource.id
  http_method             = aws_api_gateway_method.henry_bot_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.henry_lambda.invoke_arn
}

resource "aws_lambda_permission" "henry_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.henry_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_rest_api.henry_api.execution_arn
}
