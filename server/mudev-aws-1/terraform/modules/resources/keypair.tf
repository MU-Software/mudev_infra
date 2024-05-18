resource "aws_key_pair" "musoftware" {
  key_name   = "MUsoftware"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYX3RQAzwliQMsSXXFtyl6UTRuoOIyO7zuEGWYBjBG/ musoftware@daum.net"
  tags       = { Terraform = "true" }
}
