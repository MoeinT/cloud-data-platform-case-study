variable "env" {
  type = string
}

variable "partner_b_ssh_public_key" {
  description = "Public key sent by partner B, e.g. \"ssh-ed25519 AAAA...\""
  type        = string
}
