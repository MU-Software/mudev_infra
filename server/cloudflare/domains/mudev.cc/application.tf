resource "cloudflare_web_analytics_site" "mudev_cc_web_analytics_site" {
  account_id   = var.cloudflare_account_id
  host         = "(mudev.pages.dev|mudev.cc)$"
  auto_install = false
}

resource "cloudflare_pages_project" "mudev_cc_pages_project" {
  name              = "mudev"
  production_branch = "main"
  account_id        = var.cloudflare_account_id

  build_config {
    build_caching       = false
    web_analytics_tag   = cloudflare_web_analytics_site.mudev_cc_web_analytics_site.site_tag
    web_analytics_token = cloudflare_web_analytics_site.mudev_cc_web_analytics_site.site_token
  }
}
