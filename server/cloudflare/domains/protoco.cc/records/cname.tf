resource "cloudflare_record" "protoco_cc_record_cname_all" {
  name    = "*"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "protoco.cc"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_cname_pages" {
  name    = "protoco.cc"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "protoco.pages.dev"
  zone_id = var.cloudflare_zone_id
}
