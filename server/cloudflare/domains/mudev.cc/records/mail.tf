
resource "cloudflare_record" "mudev_cc_record_mx_mail_1" {
  name     = "mudev.cc"
  priority = 1
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_mx_mail_2" {
  name     = "mudev.cc"
  priority = 5
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "alt1.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_mx_mail_3" {
  name     = "mudev.cc"
  priority = 5
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "alt2.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_mx_mail_4" {
  name     = "mudev.cc"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "aspmx2.googlemail.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_mx_mail_5" {
  name     = "mudev.cc"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "aspmx3.googlemail.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_txt_mail_spf" {
  name    = "mudev.cc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=spf1 include:_spf.google.com ~all"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_txt_google_site_verification" {
  name    = "mudev.cc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "google-site-verification=onZQrlwBtM4fB1ZOdniypopXLUEpYBD6lG8TD_MeJ9s"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_txt_google_dkim" {
  name    = "google._domainkey"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAg7XSOfwpPnHyMtTCrxypLt7ds7hvGwxDtVQO901nbsEVeHhr0UnJz4zjaJGKUeKly4NvZ9bYjMkyXO3xnRal/AdxbLF/ISC0IM3b8T4dNVO5o1w1ASkNPIEmhYVeOjVDdOkkHDfEJ/QQ8ZNWXG/M/RspFvuEiUu7A8hkQZoCzs/MK2lONqnNj+GhsgYfpKXpxBBR6kKVixCeg8H46yvmCw7FMH3zMnXlIYJPtca9U74tvly024jMscmV4tkZhkdjYiO63xqqgIpyqQ+nDC4SvLHB/EJlzb0zSnEfeWDeAawJWzWOYZ0mXpfw22Uwemum4uSOaow8DQF06cteJ/kp8QIDAQAB"
  zone_id = var.cloudflare_zone_id
}
