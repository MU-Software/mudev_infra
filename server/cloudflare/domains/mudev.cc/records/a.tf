resource "cloudflare_record" "mudev_cc_record_a_api" {
  name    = "api"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = var.mudev_aws_1_instance_ipv4
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_a_status" {
  name    = "status"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = var.mudev_vultr_1_instance_ipv4
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_a_grafana" {
  name    = "grafana"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = var.mudev_vultr_1_instance_ipv4
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "mudev_cc_record_a_jupyterlab" {
  name    = "jupyterlab"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = var.mudev_vultr_1_instance_ipv4
  zone_id = var.cloudflare_zone_id
}
