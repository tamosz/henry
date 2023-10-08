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

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../app/deployed/lambda.py"
  output_path = "./zips/lambda_function_payload.zip"
}

resource "aws_lambda_function" "henry_lambda" {
  filename         = "./zips/lambda_function_payload.zip"
  function_name    = "henry_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "python3.9"
  timeout          = 10
  memory_size      = 128
  source_code_hash = filebase64sha256("./zips/lambda_function_payload.zip")

  environment {
    variables = {
      DISCORD_TOKEN = var.discord_token
    }
  }
}

variable "discord_token" {
  description = "Discord bot token"
}
