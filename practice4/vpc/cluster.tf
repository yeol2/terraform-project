# SG
resource "aws_security_group" "webserver_sg" {
  name   = "webserver-sg-rowan"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.pub_sub_1.cidr_block, aws_subnet.pub_sub_2.cidr_block]
  }
  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# launch_template
resource "aws_launch_template" "webserver_template" {
  image_id      = "ami-062cddb9d94dcf95d"
  instance_type = "t3.micro"
  key_name      = "keypair-full-master"

  # User Data를 추가하여 웹 서버 실행 설정
  user_data = base64encode(<<-EOF
      #!/bin/bash
      sudo yum update -y
      sudo yum install -y nginx

      # CI/CD 배포 버전 메시지를 Nginx 기본 문서로 설정
      echo "Deployed via CI/CD v1.0.0" | sudo tee /usr/share/nginx/html/index.html

      # Nginx 실행 및 부팅 시 자동 시작
      sudo systemctl enable nginx
      sudo systemctl start nginx
  EOF
  )

  # 보안 그룹 연결
  network_interfaces {
    security_groups = [aws_security_group.webserver_sg.id]
  }
}


# ASG
resource "aws_autoscaling_group" "webserver_asg" {
  vpc_zone_identifier = [aws_subnet.prv_sub_1.id, aws_subnet.prv_sub_2.id]
  target_group_arns   = [aws_lb_target_group.target_asg.arn]
  health_check_type   = "ELB"

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = aws_launch_template.webserver_template.latest_version
  }
  depends_on = [aws_vpc.my_vpc, aws_subnet.prv_sub_1, aws_subnet.prv_sub_2]
}
# ASG policy (cpu > 80%)
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out_policy"
  scaling_adjustment     = 1 # 인스턴스 1개 추가
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webserver_asg.name
}

# CloudWatch 알람 (CPU 80% 초과 시 Auto Scaling 트리거)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_asg.name
  }
}

# ALB connect SG
resource "aws_security_group" "alb_sg" {
  name   = var.alb_security_group_name
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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

# ALB main
resource "aws_lb" "webserver_alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = [aws_subnet.pub_sub_1.id, aws_subnet.pub_sub_2.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

# ALB-tg
resource "aws_lb_target_group" "target_asg" {
  name     = "${var.alb_name}-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.webserver_alb.arn
  port              = var.server_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_asg.arn
  }
}

# ALB listener rule
resource "aws_lb_listener_rule" "webserver_asg_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_asg.arn
  }
}

