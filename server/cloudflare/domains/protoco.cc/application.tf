resource "cloudflare_web_analytics_site" "protoco_cc_web_analytics_site" {
  account_id   = var.cloudflare_account_id
  host         = "(protoco.pages.dev|protoco.cc)$"
  auto_install = false
}

resource "cloudflare_pages_project" "protoco_cc_pages_project" {
  production_branch = "main"
  account_id        = var.cloudflare_account_id
  name              = "protoco"

  build_config {
    build_caching       = false
    web_analytics_tag   = cloudflare_web_analytics_site.protoco_cc_web_analytics_site.site_tag
    web_analytics_token = cloudflare_web_analytics_site.protoco_cc_web_analytics_site.site_token
  }
}
