#
# Batch IAM resources
#
data "aws_iam_policy_document" "batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "batch_service_role" {
  name_prefix        = "sfnTemplateBatchServiceRole-"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "batch_service_role_policy" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

#
# Spot Fleet IAM resources
# Spot instances require extra permissions, 
# but allow us to save money on EC2 instances
#
data "aws_iam_policy_document" "spot_fleet_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "spot_fleet_service_role" {
  name_prefix        = "sfnTemplateFleetServiceRole-"
  assume_role_policy = data.aws_iam_policy_document.spot_fleet_assume_role.json

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "spot_fleet_service_role_policy" {
  role       = aws_iam_role.spot_fleet_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

#
# EC2/ECS IAM resources
# Batch launches an EC2 instance to manage ECS tasks when you request it
# Here we are simplifying the role to cover both the EC2 and ECS use case
#
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com","ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ec2_nextflow_permissions" {
    statement {
      effect = "Allow"
      actions = [
        "batch:DescribeJobQueues",
        "batch:CancelJob",
        "batch:SubmitJob",
        "batch:ListJobs",
        "batch:DescribeComputeEnvironments",
        "batch:TerminateJob",
        "batch:DescribeJobs",
        "batch:RegisterJobDefinition",
        "batch:DescribeJobDefinitions",
        "batch:TagResource",
        "ecs:DescribeTasks",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceAttribute",
        "ecs:DescribeContainerInstances",
        "ec2:DescribeInstanceStatus",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:ListTagsForResource",
        "ecr:DescribeImageScanFindings",
        "logs:GetLogEvents"
      ]
      resources = [ "*" ]
    }
    statement {
        effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:PutObjectTagging",
        "s3:GetObjectTagging",
        "s3:DeleteObjectTagging"
      ]
      resources = [ 
        "arn:aws:s3:::d3b-bix-dev-data-bucket/*",
        "arn:aws:s3:::d3b-bix-dev-data-bucket"
      ]
    }
}

resource "aws_iam_role_policy" "ec2_nextflow_policy" {
  name = "${var.project}-${var.environment}-ec2-policy"
  role = aws_iam_role.ecs_instance_role.name
  policy = data.aws_iam_policy_document.ec2_nextflow_permissions.json
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = aws_iam_role.ecs_instance_role.name
  role = aws_iam_role.ecs_instance_role.name

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name_prefix        = "ecsInstanceRole-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#
# Step Functions IAM resources
# This is everything your step function is allowed to do
#
data "aws_iam_policy_document" "step_functions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "step_functions_service_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      # "lambda:InvokeFunction", # Needed if you use Lambda instead of Batch
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "batch:SubmitJob",
    ]
    resources = [
      aws_batch_job_definition.default.arn,
      aws_batch_job_queue.default.arn
    ]
  }
}

resource "aws_iam_role" "step_functions_service_role" {
  name               = "${var.project}-${var.environment}-role"
  assume_role_policy = data.aws_iam_policy_document.step_functions_assume_role.json
}

resource "aws_iam_role_policy" "step_functions_service_role_policy" {
  name   = "${var.project}-${var.environment}-policy"
  role   = aws_iam_role.step_functions_service_role.name
  policy = data.aws_iam_policy_document.step_functions_service_role_policy.json
}