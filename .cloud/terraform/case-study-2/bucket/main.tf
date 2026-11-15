resource "aws_s3_bucket" "partner_inbound" {
  bucket = "partner-inbound-${var.env}"
}

# ACLs disabled: we own every file, whoever uploads it
# (the default for new buckets since April 2023; set explicitly so it can't be switched back, and for older buckets)
resource "aws_s3_bucket_ownership_controls" "partner_inbound" {
  bucket = aws_s3_bucket.partner_inbound.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "partner_inbound" {
  bucket                  = aws_s3_bucket.partner_inbound.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Guardrail for everyone: refuse anything not sent over HTTPS
data "aws_iam_policy_document" "partner_inbound" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.partner_inbound.arn, "${aws_s3_bucket.partner_inbound.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "partner_inbound" {
  bucket = aws_s3_bucket.partner_inbound.id
  policy = data.aws_iam_policy_document.partner_inbound.json
}
