
resource "cloudflare_record" "mudev_cc_record_cname_all" {
  name    = "*"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "mudev.cc"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_cname_www" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "mudev.cc"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_cname_pages" {
  name    = "mudev.cc"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "mudev.pages.dev"
  zone_id = var.cloudflare_zone_id
}
