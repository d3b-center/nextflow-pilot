resource "aws_key_pair" "bastion" {
  public_key = var.bastion_public_key

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

#
# Security Group resources
#
resource "aws_security_group" "batch" {
  name_prefix = "sgBatchContainerInstance-"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "sgBatchContainerInstance"
    Project     = var.project
    Environment = var.environment
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}



#
# Batch resources
#
resource "aws_launch_template" "default" {
  name_prefix = "ltBatchContainerInstance-${var.environment}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.batch_root_block_device_size
      volume_type = var.batch_root_block_device_type
    }
  }


  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_batch_compute_environment" "default" {
  compute_environment_name_prefix = "${var.project}-"
  type                            = "MANAGED"
  state                           = "ENABLED"
  service_role                    = aws_iam_role.batch_service_role.arn

  compute_resources {
    type                = "SPOT"
    allocation_strategy = var.batch_spot_fleet_allocation_strategy
    bid_percentage      = var.batch_spot_fleet_bid_percentage

    ec2_configuration {
      image_type = "ECS_AL2023"
    }

    ec2_key_pair = aws_key_pair.bastion.key_name

    min_vcpus = var.batch_min_vcpus
    max_vcpus = var.batch_max_vcpus

    launch_template {
      launch_template_id = aws_launch_template.default.id
      version            = aws_launch_template.default.latest_version
    }

    spot_iam_fleet_role = aws_iam_role.spot_fleet_service_role.arn
    instance_role       = aws_iam_instance_profile.ecs_instance_role.arn

    instance_type = var.batch_instance_types

    security_group_ids = [aws_security_group.batch.id]
    subnets            = var.vpc_private_subnet_ids

    tags = {
      Name        = "BatchWorker"
      Project     = var.project
      Environment = var.environment
    }
  }

  depends_on = [aws_iam_role_policy_attachment.batch_service_role_policy]

  tags = {
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_batch_job_queue" "default" {
  name                 = "${var.project}-queue"
  priority             = 1
  state                = "ENABLED"
  compute_environments = [aws_batch_compute_environment.default.arn]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_batch_job_definition" "default" {
  name = "${var.project}-job"
  type = "container"

  container_properties = templatefile("${path.module}/job-definitions/etl-pipeline.json.tmpl", {
    
    image_url = "${var.image_name}:${var.image_tag}"


    environment = var.environment
 
    batch_vcpus = var.batch_vcpus
    batch_memory = var.batch_memory

    ecs_execution_role_arn = aws_iam_role.ecs_instance_role.arn
  })

  platform_capabilities = ["EC2"]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}