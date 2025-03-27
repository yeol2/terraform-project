# Launch Template 생성
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.servicename}-${var.stage}-lt-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.asg_ec2_sg.id]

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.servicename}-${var.stage}-asg"
    }
  }
}

# Auto Scaling Group 생성
resource "aws_autoscaling_group" "asg" {
	name                      = "${var.servicename}-${var.stage}-asg"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300
  
  launch_template {
	  id = aws_launch_template.lt.id
	  version = aws_launch_template.lt.latest_version
  }


  # 태그
  tag {
	  key = "Name"
	  value = "${var.servicename}-${var.stage}-asg"
	  propagate_at_launch = true
  }
  
  lifecycle {
	  create_before_destroy = true
  }
}

# Target Tracking Auto Scaling Policy (CPU 기준)
resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "${var.servicename}-${var.stage}-scale-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value       = 70.0  # 평균 CPU가 70% 넘으면 인스턴스 자동 증가
    disable_scale_in   = false
  }
  depends_on = [aws_autoscaling_group.asg]
}

# EC2용 Security Group (ALB에서만 허용)
resource "aws_security_group" "asg_ec2_sg" {
  name   = "aws-sg-${var.stage}-${var.servicename}-asg"
  vpc_id = var.vpc_id

  ingress {
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_groups = [var.openvpn_sg_id]
  description     = "Allow SSH from OpenVPN"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "Allow HTTP from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-sg-${var.stage}-${var.servicename}-asg"
  }
}
