provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dynamodb.amazonaws.com"
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "henry_lambda" {
  filename      = "path/to/your/lambda_function.zip"
  function_name = "henry-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      DISCORD_TOKEN = var.discord_token
    }
  }
}

resource "aws_api_gateway_rest_api" "henry_api" {
  name        = "discord-bot-api"
  description = "API Gateway for Discord Bot"
}

resource "aws_api_gateway_resource" "henry_resource" {
  rest_api_id = aws_api_gateway_rest_api.henry_api.id
  parent_id   = aws_api_gateway_rest_api.henry_api.root_resource_id
  path_part   = "commands"
}

resource "aws_api_gateway_method" "discord_bot_method" {
  rest_api_id   = aws_api_gateway_rest_api.henry_api.id
  resource_id   = aws_api_gateway_resource.henry_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "discord_bot_integration" {
  rest_api_id             = aws_api_gateway_rest_api.henry_api.id
  resource_id             = aws_api_gateway_resource.henry_resource.id
  http_method             = aws_api_gateway_method.discord_bot_method.http_method
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

variable "discord_token" {
  description = "Discord bot token"
}
