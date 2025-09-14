data "aws_ami" "example" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  tags = var.default_tags
}

resource "aws_instance" "example" {
  ami       = data.aws_ami.example.id
  user_data = var.user_data
  count     = var.ec2_count
  # subnet_id   = var
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = 0.0031
    }
  }
  instance_type = "t4g.nano"
  tags          = var.default_tags
}
