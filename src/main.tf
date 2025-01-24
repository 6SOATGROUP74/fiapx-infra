# Provedor da AWS
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

resource "aws_s3_bucket" "bucket_upload" {
  bucket = "fiapx_bucket_upload"
  tags = {
    Environment = "Upload"
  }
}

##Lambda

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "source/lambda.py"
  output_path = "source/lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {

  filename      = "source/lambda.zip" 
  function_name = "lambda_function_name"
  role          = local.lab_role
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

}

##Queue

resource "aws_sqs_queue" "terraform_queue" {
  name                      = "queue-upload"
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  tags = {
    Environment = "fiapx"
  }
}