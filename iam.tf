# -------------------------------------------------------------------------------------
# CREATE IAM ROLE AND POLICIES FOR LAMBDA FUNCTION
# -------------------------------------------------------------------------------------

# Create IAM role
resource "aws_iam_role" "lambda_cloudwatch_logs" {
  name               = local.lambda_prefix_name
  assume_role_policy = data.aws_iam_policy_document.lambda_cloudwatch_logs.json
}

# Add base Lambda Execution policy
resource "aws_iam_role_policy" "lambda_cloudwatch_logs_polcy" {
  name   = local.lambda_prefix_name
  role   = aws_iam_role.lambda_cloudwatch_logs.id
  policy = data.aws_iam_policy_document.lambda_cloudwatch_logs_policy.json
}

# JSON POLICY - assume role
data "aws_iam_policy_document" "lambda_cloudwatch_logs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# JSON POLICY - base Lambda Execution policy
data "aws_iam_policy_document" "lambda_cloudwatch_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}
