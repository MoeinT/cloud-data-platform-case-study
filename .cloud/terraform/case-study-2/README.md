# Case 2 · Terraform examples

Small illustrative examples of the patterns in [case-2-s3-partner-access](../../../case-2-s3-partner-access/README.md). Not a deployable project: each folder is independent and only shows the resources needed to explain one pattern.

| Folder | Pattern |
|---|---|
| [`bucket/`](bucket/) | Inbound bucket and its guardrails (bucket owner enforced, no public access, HTTPS only) |
| [`cross-account-role/`](cross-account-role/) | Partner on AWS: our role, trusting their role + external ID, write-only on their folder |
| [`sftp/`](sftp/) | Partner not on AWS: Transfer Family SFTP server, one user locked to their folder |
| [`presigned-url/`](presigned-url/) | Application partner: Lambda that returns a pre-signed upload link (API Gateway in front, not shown) |
