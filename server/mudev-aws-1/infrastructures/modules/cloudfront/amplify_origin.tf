resource "aws_cloudfront_cache_policy" "cloudfront-cache-policy-amplify-origin" {
  comment     = "Policy for Amplify Origin"
  default_ttl = 2
  max_ttl     = 600
  min_ttl     = 2
  name        = "Managed-Amplify"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["Authorization", "CloudFront-Viewer-Country", "Host"]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}
