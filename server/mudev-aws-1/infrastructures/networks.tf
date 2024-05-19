# I know VPC Flow Logs are important, but I'm disabling them for cost saving.
#trivy:ignore:AVD-AWS-0178
resource "aws_vpc" "default_vpc" {
  assign_generated_ipv6_cidr_block     = false
  cidr_block                           = "172.31.0.0/16"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"
  tags                                 = { Terraform = "true" }
}

resource "aws_vpc_dhcp_options" "default_dhcp_options" {
  domain_name         = "ap-northeast-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = { Terraform = "true" }
}

resource "aws_vpc_dhcp_options_association" "default_dhcp_options_association" {
  vpc_id          = aws_vpc.default_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.default_dhcp_options.id
}

resource "aws_security_group" "default_security_group" {
  description = "default VPC security group"
  vpc_id      = aws_vpc.default_vpc.id

  egress {
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-egress-sgr
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    description = "Allow inbound traffic from the same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow inbound SSH traffic"
    # TODO: FIXME: This is a security risk. Please restrict the source IP range.
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    from_port   = 8822
    to_port     = 8822
    protocol    = "tcp"
  }

  ingress {
    description = "Allow inbound HTTP traffic"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    description = "Allow inbound HTTPS traffic"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  tags = { Terraform = "true" }
}

resource "aws_subnet" "default_subnets" {
  for_each                                       = toset(var.aws_regions)
  assign_ipv6_address_on_creation                = false
  cidr_block                                     = cidrsubnet(aws_vpc.default_vpc.cidr_block, 4, index(var.aws_regions, each.key))
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_native                                    = false
  map_public_ip_on_launch                        = true #trivy:ignore:AVD-AWS-0164
  private_dns_hostname_type_on_launch            = "ip-name"
  vpc_id                                         = aws_vpc.default_vpc.id
  availability_zone                              = each.key

  tags = { Name = each.key, Terraform = "true" }
}

resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = aws_vpc.default_vpc.default_network_acl_id
  subnet_ids             = [for subnet in aws_subnet.default_subnets : subnet.id]

  egress {
    # Allow all outbound traffic
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
  }

  ingress {
    # Allow inbound traffic from the same security group
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
  }

  tags = { Terraform = "true" }
}

resource "aws_internet_gateway" "default_internet_gateway" {
  vpc_id = aws_vpc.default_vpc.id
  tags   = { Terraform = "true" }
}

resource "aws_route_table" "default_route_table" {
  vpc_id = aws_vpc.default_vpc.id
  tags   = { Terraform = "true" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_internet_gateway.id
  }
}

resource "aws_main_route_table_association" "default_vpc" {
  route_table_id = aws_route_table.default_route_table.id
  vpc_id         = aws_vpc.default_vpc.id
}
