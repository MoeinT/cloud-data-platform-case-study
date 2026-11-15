data "aws_s3_bucket" "partner_inbound" {
  bucket = "partner-inbound-${var.env}"
}

# Trust policy: only partner A's specific role, and only with the external ID we gave them
data "aws_iam_policy_document" "partner_a_assume_role" {
  # Their specific role, not their whole account (:root); the external ID stops another customer of theirs using it (confused deputy)
  statement {
    sid     = "PartnerAAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.partner_a_role_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.partner_a_external_id]
    }
  }
}

resource "aws_iam_role" "partner_a_upload" {
  name               = "partner-a-upload-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.partner_a_assume_role.json
}

# Role policy: write-only, on partner A's folder only
data "aws_iam_policy_document" "partner_a_upload" {
  # Least privilege: write only (no Get, List or Delete), and only under partner-a/
  statement {
    sid       = "WriteOwnFolderOnly"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${data.aws_s3_bucket.partner_inbound.arn}/partner-a/*"]
  }
}

resource "aws_iam_role_policy" "partner_a_upload" {
  role   = aws_iam_role.partner_a_upload.id
  policy = data.aws_iam_policy_document.partner_a_upload.json
}
