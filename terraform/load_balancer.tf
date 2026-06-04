# S3 bucket for ALB access logs
resource "aws_s3_bucket" "alb_logs" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = "${var.project_name}-alb-logs-${data.aws_caller_identity.current.account_id}"

  tags = var.tags

  lifecycle {
    ignore_changes = [bucket]
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  count  = var.enable_static_assets ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs[0].arn}/*"
      }
    ]
  })
}

# Application Load Balancer
resource "aws_lb" "main" {
  name                       = "${var.project_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = aws_subnet.public[*].id
  drop_invalid_header_fields = true
  enable_deletion_protection = var.environment == "prod" ? true : false

  dynamic "access_logs" {
    for_each = var.enable_static_assets ? [1] : []
    content {
      bucket  = aws_s3_bucket.alb_logs[0].bucket
      prefix  = "alb"
      enabled = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb"
  })
}

# Target Group for the ALB
resource "aws_lb_target_group" "web_tg" {
  name        = "${var.project_name}-web-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  deregistration_delay = 30

  tags = merge(var.tags, {
    Name = "${var.project_name}-web-tg"
  })
}

# HTTP Listener (always created; HTTPS listener added below if domain_name set)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.domain_name != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.domain_name != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.domain_name != "" ? null : aws_lb_target_group.web_tg.arn
  }
}

# Optional HTTPS listener (requires ACM cert + domain_name)
resource "aws_acm_certificate" "main" {
  count                     = var.domain_name != "" ? 1 : 0
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]
  tags                      = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "https" {
  count             = var.domain_name != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.main[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
