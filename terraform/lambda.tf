resource "aws_lambda_function" "rss_grid" {
  filename      = "${path.module}/placeholder.zip"
  function_name = "rss_grid_${var.name}"
  role          = aws_iam_role.rss_grid.arn
  handler       = "lambda.handler"
  runtime       = "python3.9"
  memory_size   = 2048
  timeout       = 90

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.rss_grid.id
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rss_grid.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.run_rebuild.arn
}
