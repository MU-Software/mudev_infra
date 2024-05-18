resource "aws_cloudfront_cache_policy" "cloudfront-cache-policy-caching-disabled" {
  comment     = "Policy with caching disabled"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0
  name        = "Managed-CachingDisabled"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip   = false

    cookies_config { cookie_behavior = "none" }
    headers_config { header_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
  }
}
