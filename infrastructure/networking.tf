# VPC

resource "aws_vpc" "default_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.default_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "default_gw" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_route_table" "default_rt_public" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_gw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.default_rt_public.id
}

# ALB Security group
# In order to handle internal HTTPS traffic, listener would need to be using 443 and HTTPS, and will need an SSL policy with certificate ARN.

resource "aws_security_group" "alb_sg" {
  name   = "allow_http"
  vpc_id = aws_vpc.default_vpc.id

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


resource "aws_lb" "default_lb" {
  name               = module.eg_staging_alb_label.id
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "default_tg" {
  name     = "${module.eg_staging_alb_label.id}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.default_vpc.id
}

resource "aws_lb_listener" "default_lb_listener" {
  load_balancer_arn = aws_lb.default_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_tg.arn
  }
}
