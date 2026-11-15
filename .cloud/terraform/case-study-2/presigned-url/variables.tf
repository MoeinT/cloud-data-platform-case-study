variable "env" {
  type = string
}

variable "partner_folders" {
  description = "API Gateway API key ID => partner folder, e.g. { \"k7x9abc\" = \"partner-c\" }"
  type        = map(string)
}
