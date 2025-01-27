provider "aws" {
  region = "us-east-1" # Ajuste para a sua região
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

resource "aws_s3_bucket" "bucket_upload" {
  bucket = "fiapx-bucket-upload-2601"
}

resource "aws_sqs_queue" "queue_upload" {
  name = "upload-file-fiapx.fifo"
  fifo_queue                = true
  content_based_deduplication = true
}

output "queue_url" {
  value = aws_sqs_queue.queue_upload.id
}

resource "aws_lambda_function" "example_lambda" {
  function_name    = "lambda-upload-file"
  runtime          = "python3.9"
  role             = "arn:aws:iam::419232333143:role/LabRole"
  handler          = "lambda_handler.lambda_handler"
  filename         = "source/lambda_handler.zip"

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.queue_upload.id
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket_upload.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.example_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_event]
}

resource "aws_lambda_permission" "allow_s3_event" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket_upload.arn
}
