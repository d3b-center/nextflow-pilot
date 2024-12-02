resource "aws_instance" "nextflow_ec2" {
  ami                    = var.ami
  instance_type          = var.nextflow_ec2_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ecs_instance_role.name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  subnet_id              = var.vpc_private_subnet_ids[0]
  key_name               = "devops"
  ebs_optimized          = true
  monitoring             = true
  volume_tags = {
    Name              = "${var.project}-ec2-${var.environment}-volume"
    Application       = var.project
    Description       = "Instance for ${var.project}"
    BootstrapInstance = "true"
  }
  root_block_device {
    volume_type = "standard"
    volume_size = var.nextflow_root_volume_size
    encrypted   = "true"
  }
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = "standard"
    volume_size           = var.nextflow_volume_size
    encrypted             = "true"
    kms_key_id            = data.aws_kms_key.ebs_kms_key.arn
    delete_on_termination = true
  }
  instance_initiated_shutdown_behavior = "terminate"
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = {
    Name                 = "${var.project}-ec2-${var.environment}"
    Application          = var.project
    Description          = "Instance for ${var.project}"
    BootstrapInstance    = "true"
    Project              = var.project
  }
}

data "aws_kms_key" "ebs_kms_key" {
  key_id = "alias/aws/ebs"
}

resource "aws_security_group" "ec2-sg" {
  name        = "${var.project}-${var.environment}-sg"
  description = "Default security group that allows no inbound and outbound traffic from all instances in the VPC"
  vpc_id      = var.vpc_id

  egress {
    description = "Allows egress traffic from instance"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                 = "${var.project}-${var.environment}-ec2"
    Workgroup            = var.project
    Project              = "ec2"
  }
}