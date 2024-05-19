resource "aws_cloudfront_cache_policy" "cloudfront-cache-policy-elemental-mediapackage-origin" {
  comment     = "Policy for Elemental MediaPackage Origin"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0
  name        = "Managed-Elemental-MediaPackage"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["origin"]
      }
    }

    query_strings_config {
      query_string_behavior = "whitelist"

      query_strings {
        items = ["aws.manifestfilter", "end", "m", "start"]
      }
    }
  }
}
