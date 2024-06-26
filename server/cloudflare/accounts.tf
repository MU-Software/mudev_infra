resource "cloudflare_account_member" "default_account" {
  account_id    = var.cloudflare_account_id
  email_address = var.cloudflare_email_address
  role_ids      = ["33666b9c79b9a5273fc7344ff42f953d"]
}

resource "cloudflare_access_identity_provider" "default_account_otp" {
  name       = "Default Account OTP"
  account_id = var.cloudflare_account_id
  type       = "onetimepin"
}
