resource "aws_cloudwatch_event_rule" "run_rebuild" {
  name       = "rss_grid_${var.name}_rebuild"
  is_enabled = true

  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.run_rebuild.name
  arn  = aws_lambda_function.rss_grid.arn
}
