resource "cloudflare_record" "protoco_cc_record_mx_mail_1" {
  name     = "protoco.cc"
  priority = 1
  proxied  = false
  ttl      = 3600
  type     = "MX"
  content  = "aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_mx_mail_2" {
  name     = "protoco.cc"
  priority = 5
  proxied  = false
  ttl      = 3600
  type     = "MX"
  content  = "alt1.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_mx_mail_3" {
  name     = "protoco.cc"
  priority = 5
  proxied  = false
  ttl      = 3600
  type     = "MX"
  content  = "alt2.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_mx_mail_4" {
  name     = "protoco.cc"
  priority = 10
  proxied  = false
  ttl      = 3600
  type     = "MX"
  content  = "alt3.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_mx_mail_5" {
  name     = "protoco.cc"
  priority = 10
  proxied  = false
  ttl      = 3600
  type     = "MX"
  content  = "alt4.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_txt_mail_spf" {
  name    = "protoco.cc"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  content = "\"v=spf1 include:_spf.google.com ~all\""
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_txt_google_site_verification" {
  name    = "protoco.cc"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  content = "\"google-site-verification=_U-SGGckRDp3WQ0tkiGDeK-x758J2LAlrQCkBNoHtQs\""
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_txt_dkim" {
  name    = "protoco._domainkey"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlklPVeLKAUtnyaX9jVb47D3yZ9AaWSFIhHcwfHYElIgjkP1a0PLLyR9463HC7LOLidSSq4Gg1KbWrC2kUooLYRu5hYlDCcuGgGwPg2PT31ehs9VLNGk1lqOJkDV2zCvier372FRZwWAdYkPL43SPVfppwlMfDJQLl55J0eF3xWp4+i2U66I7QfrwaGLHpHecv+H4zzZWD0q+gUvdOA82GYXMmC+6BCO+veE0vdPVg4E9YP/wTm7wUZ5Zw83HxXd+ZdOt2rwlQahjAhhxiQe+WS0+eEUF5+Kvji768guiYmvSwPaYtPhA7GGSiiszI25pF79pO5IpqdUVds7ZmTTsUQIDAQAB\""
  zone_id = var.cloudflare_zone_id
}
