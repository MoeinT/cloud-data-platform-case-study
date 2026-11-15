data "aws_s3_bucket" "partner_inbound" {
  bucket = "partner-inbound-${var.env}"
}

# The Lambda's role signs the links, so it needs PutObject on the application partners' folders
data "aws_iam_policy_document" "lambda_assume_role" {
  # Only the Lambda service can use this role
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "upload_link" {
  name               = "upload-link-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "upload_link" {
  # Links are signed with this role, so it needs PutObject; limited to the app partners' folders (never SFTP or AWS partners')
  statement {
    sid       = "SignUploadLinksForAppPartners"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [for folder in values(var.partner_folders) : "${data.aws_s3_bucket.partner_inbound.arn}/${folder}/*"]
  }
}

resource "aws_iam_role_policy" "upload_link" {
  role   = aws_iam_role.upload_link.id
  policy = data.aws_iam_policy_document.upload_link.json
}

# Called by API Gateway (not shown) after it authenticates the partner
resource "aws_lambda_function" "upload_link" {
  function_name = "upload-link-${var.env}"
  role          = aws_iam_role.upload_link.arn
  runtime       = "python3.12"
  handler       = "handler.handler"
  filename      = "${path.module}/handler.zip" # zip of handler.py, built in CI
  environment {
    variables = {
      BUCKET          = data.aws_s3_bucket.partner_inbound.id
      PARTNER_FOLDERS = jsonencode(var.partner_folders)
    }
  }
}
