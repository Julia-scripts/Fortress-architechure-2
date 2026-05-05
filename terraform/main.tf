# 1. VPC & Networking
resource "aws_vpc" "fortress_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "Fortress-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.fortress_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.fortress_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "Private-Subnet"
  }
}

# 1.5 Internet Gateway & Public Route
resource "aws_internet_gateway" "fortress_igw" {
  vpc_id = aws_vpc.fortress_vpc.id
  tags   = { Name = "Fortress-IGW" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fortress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fortress_igw.id
  }

  tags = { Name = "Public-Route-Table" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 2. Security Groups
resource "aws_security_group" "alb_sg" {
  name   = "fortress-alb-sg"
  vpc_id = aws_vpc.fortress_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name   = "fortress-app-sg"
  vpc_id = aws_vpc.fortress_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. WAF (Cleaned up visibility blocks)
resource "aws_wafv2_web_acl" "fortress_waf" {
  name  = "fortress-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "fortress-waf-metrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "fortress-waf-overall"
    sampled_requests_enabled   = true
  }
}

# 4. Load Balancer & Target Group
resource "aws_lb" "fortress_alb" {
  name               = "fortress-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
}

resource "aws_lb_target_group" "fortress_tg" {
  name     = "fortress-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.fortress_vpc.id
}

resource "aws_lb_listener" "fortress_listener" {
  load_balancer_arn = aws_lb.fortress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fortress_tg.arn
  }
}

# 5. EC2 Instance
resource "aws_instance" "fortress_app" {
  ami                    = var.main_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "Fortress-App-Server"
  }
}

# 6. Attachments
resource "aws_wafv2_web_acl_association" "waf_assoc" {
  resource_arn = aws_lb.fortress_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.fortress_waf.arn
}

resource "aws_lb_target_group_attachment" "fortress_attachment" {
  target_group_arn = aws_lb_target_group.fortress_tg.arn
  target_id        = aws_instance.fortress_app.id
  port             = 80
}