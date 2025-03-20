# SG
resource "aws_security_group" "webserver_sg" {
        name = "webserver-sg-studentN"
        vpc_id = aws_vpc.my_vpc.id

        ingress {
                from_port = var.server_port
                to_port = var.server_port
                protocol = "tcp"
                cidr_blocks = [aws_subnet.pub_sub_1.cidr_block, aws_subnet.pub_sub_2.cidr_block]
        }
}

# launch_template
resource "aws_launch_template" "webserver_template" {
        image_id = "ami-062cddb9d94dcf95d"
        instance_type = "t3.micro"
}

# ASG
resource "aws_autoscaling_group" "webserver_asg" {
        vpc_zone_identifier = [aws_subnet.pub_sub_1.id, aws_subnet.pub_sub_2.id]
        min_size = 2
        max_size = 3
        launch_template {
                id = aws_launch_template.webserver_template.id
                version = aws_launch_template.webserver_template.latest_version
        }
        depends_on = [aws_vpc.my_vpc, aws_subnet.pub_sub_1, aws_subnet.pub_sub_2]
}

# ALB connect SG
resource "aws_security_group" "alb_sg" {
        name = var.alb_security_group_name
        vpc_id = aws_vpc.my_vpc.id

        ingress {
                from_port = var.server_port
                to_port = var.server_port
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

# ALB main
resource "aws_lb" "webserver_alb" {
        name = var.alb_name
        load_balancer_type = "application"
        subnets = [aws_subnet.pub_sub_1.id, aws_subnet.pub_sub_2.id]
        security_groups = [aws_security_group.alb_sg.id]
}

# ALB-tg
resource "aws_lb_target_group" "target_asg" {
    name = "${var.alb_name}-tg"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = aws_vpc.my_vpc.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

# ALB listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.webserver_alb.arn
    port = var.server_port
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_asg.arn
    }
}

resource "aws_autoscaling_attachment" "asg_to_alb" {
    autoscaling_group_name = aws_autoscaling_group.webserver_asg.id
    lb_target_group_arn    = aws_lb_target_group.target_asg.arn
}
