resource "aws_lb" "default_loadbalancer" {
  name = "default_loadbalancer"
  internal = false 
  load_balancer_type = "application"
  security_groups = var.alb_sg
  subnets = var.alb_subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.default_loadbalancer.arn
  port = "443"
  protocol = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "not found"
      status_code = 404
    }
  }
}

resource "aws_lb_listener_rule" "lb_lister_rule" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority = 100

  action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "301"
    }
  }

  condition {
    http_request_method {
      values = "POST" 
    }
  }
}