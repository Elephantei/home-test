# Create VPC and public subnet
resource "aws_vpc" "default_vpc" {
  for_each = toset(local.environments)

  cidr_block           = "10.0.0.0/16" # Adjust if needed per environment
  enable_dns_support   = true
  enable_dns_hostnames = true
}
resource "aws_subnet" "public" {
  for_each = toset(local.environments)

  count                   = 2
  vpc_id                  = aws_vpc.default_vpc[each.key].id
  cidr_block              = cidrsubnet(aws_vpc.default_vpc[each.key].cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

# Create aws gw and add a route table
resource "aws_internet_gateway" "gw" {
  for_each = toset(local.environments)

  vpc_id = aws_vpc.default_vpc[each.key].id
}

resource "aws_route_table" "public" {
  for_each = toset(local.environments)

  vpc_id = aws_vpc.default_vpc[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[each.key].id
  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(local.environments)

  count          = 2
  subnet_id      = element(aws_subnet.public[each.key].*.id, count.index)
  route_table_id = aws_route_table.public[each.key].id
}

# Security group for ALB
resource "aws_security_group" "alb_sg" {
  for_each = toset(local.environments)

  name   = "${each.key}-allow_http"
  vpc_id = aws_vpc.default_vpc[each.key].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["86.168.21.174/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ALB and tg
resource "aws_lb" "default_alb" {
  for_each = toset(local.environments)

  name               = module.eg_alb_label[each.key].id
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg[each.key].id]
  subnets            = aws_subnet.public[each.key].*.id
}

resource "aws_lb_target_group" "default_alb_tg" {
  for_each = toset(local.environments)

  name     = "${module.eg_alb_label[each.key].id}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.default_vpc[each.key].id
}

resource "aws_lb_listener" "default_alb_listener" {
  for_each = toset(local.environments)

  load_balancer_arn = aws_lb.default_alb[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_alb_tg[each.key].arn
  }
}

# NOTE
# In order to handle internal HTTPS traffic, listener would need to be using 443 and HTTPS, and will need an SSL policy with certificate ARN.
