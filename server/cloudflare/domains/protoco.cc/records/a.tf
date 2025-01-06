resource "cloudflare_record" "protoco_cc_record_api" {
  name    = "api"
  proxied = true
  ttl     = 1
  type    = "A"
  content = var.mudev_aws_1_instance_ipv4
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "protoco_cc_record_status" {
  name    = "status"
  proxied = true
  ttl     = 1
  type    = "A"
  content = var.mudev_vultr_1_instance_ipv4
  zone_id = var.cloudflare_zone_id
}
