resource "aws_network_interface" "mudev-ubuntu-network-interface" {
  description        = "EC2NetworkInterface"
  ipv4_prefix_count  = 0
  ipv6_address_count = 0
  ipv6_prefix_count  = 0
  security_groups    = [var.default_security_group_id]
  source_dest_check  = true
  subnet_id          = var.default_subnet_id
  tags               = { Terraform = "true" }
}

data "aws_ami" "ubuntu" {
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240423"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  tags = { Terraform = "true" }
}

resource "aws_instance" "mudev-ubuntu" {
  ami                                  = data.aws_ami.ubuntu.id
  availability_zone                    = var.default_availability_zone
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = false
  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.micro"
  key_name                             = aws_key_pair.musoftware.key_name
  monitoring                           = false
  placement_partition_number           = 0
  tenancy                              = "default"
  user_data_replace_on_change          = true
  user_data                            = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get upgrade -y
    sed -i 's/#Port\s22/Port 8822/' /etc/ssh/sshd_config
    reboot
    EOF

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  credit_specification {
    cpu_credits = "standard"
  }
  enclave_options {
    enabled = false
  }
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    throughput            = 125
    volume_size           = 30
    volume_type           = "gp3"
    tags                  = { Terraform = "true" }
  }
  network_interface {
    device_index         = 0 # primary interface
    network_interface_id = aws_network_interface.mudev-ubuntu-network-interface.id
  }
  timeouts {}
  tags = { Terraform = "true" }
}

output "mudev_aws_1_public_ip" {
  value = aws_instance.mudev-ubuntu.public_ip
}
