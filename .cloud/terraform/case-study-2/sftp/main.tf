data "aws_s3_bucket" "partner_inbound" {
  bucket = "partner-inbound-${var.env}"
}

# One managed SFTP server, shared by all partners
resource "aws_transfer_server" "sftp" {
  protocols              = ["SFTP"]
  identity_provider_type = "SERVICE_MANAGED"
}

# Role used by Transfer Family to write on partner B's behalf
data "aws_iam_policy_document" "transfer_assume_role" {
  # Only the Transfer Family service can use this role, to write on partner B's behalf
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sftp_partner_b" {
  name               = "sftp-partner-b-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.transfer_assume_role.json
}

data "aws_iam_policy_document" "sftp_partner_b" {
  # Least privilege: write only, and only under partner-b/ (the second layer after the home directory mapping)
  statement {
    sid       = "WriteOwnFolderOnly"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${data.aws_s3_bucket.partner_inbound.arn}/partner-b/*"]
  }
  # SFTP clients list the folder they land in (like ls), so they need List.
  statement {
    sid       = "ListOwnFolderOnly"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.partner_inbound.arn]
    # the s3:prefix condition narrows it back to partner-b/
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["partner-b/*"]
    }
  }
}

resource "aws_iam_role_policy" "sftp_partner_b" {
  role   = aws_iam_role.sftp_partner_b.id
  policy = data.aws_iam_policy_document.sftp_partner_b.json
}

# Partner B's user: sees partner-b/ as "/" and nothing else
resource "aws_transfer_user" "partner_b" {
  server_id           = aws_transfer_server.sftp.id
  user_name           = "partner-b"
  role                = aws_iam_role.sftp_partner_b.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${data.aws_s3_bucket.partner_inbound.id}/partner-b"
  }
}

# Partner B keeps the private key; we only register the public key
resource "aws_transfer_ssh_key" "partner_b" {
  server_id = aws_transfer_server.sftp.id
  user_name = aws_transfer_user.partner_b.user_name
  body      = var.partner_b_ssh_public_key
}
