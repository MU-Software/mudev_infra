resource "aws_cloudfront_cache_policy" "cloudfront-cache-policy-compression-disabled" {
  comment     = "Default policy when compression is disabled"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1
  name        = "Managed-CachingOptimizedForUncompressedObjects"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip   = false

    cookies_config { cookie_behavior = "none" }
    headers_config { header_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
  }
}
