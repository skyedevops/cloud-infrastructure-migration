# Launch Template for EC2 Instances in Auto Scaling Group
resource "aws_launch_template" "web" {
  name_prefix   = "cloud-migration-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to the Cloud Migration Demo</h1>" > /var/www/html/index.html
              EOF

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "cloud-migration-web"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  name                      = "cloud-migration-web-asg"
  max_size                  = 3
  min_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = aws_subnet.public[*].id
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  health_check_type = "ELB"
  health_check_grace_period = 300

  termination_policies = ["Default"]

  tag {
    key                 = "Name"
    value               = "cloud-migration-web"
    propagate_at_launch = true
  }
}

# Data source for the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}