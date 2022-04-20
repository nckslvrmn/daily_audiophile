# lambda role
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "bucket_access" {
  statement {
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.rss_grid.arn}/*"]
  }
}

resource "aws_iam_role" "rss_grid" {
  name               = "rss_grid_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.rss_grid.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "s3_bucket" {
  name   = "s3_bucket"
  role   = aws_iam_role.rss_grid.id
  policy = data.aws_iam_policy_document.bucket_access.json
}
