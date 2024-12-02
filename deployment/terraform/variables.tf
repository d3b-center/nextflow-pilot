
variable "project" {
  type        = string
  description = "A project namespace for the infrastructure."
  default     = "sfn-template"
}
variable "environment" {
  type        = string
  description = "An environment namespace for the infrastructure."
}

variable "account" {
  type = string
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "image_name" {
  type    = string
  default = "684194535433.dkr.ecr.us-east-1.amazonaws.com/stepfunction-template-worker"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "ami" {
    description = "AMI ID for both the Nextflow EC2"
    default = ""
}

variable "nextflow_ec2_instance_type" {
    default = "c5.large"
}

variable "bastion_public_key" {
  type = string
  sensitive = true
}

variable "vpc_id" {
  type = string
}

variable "nextflow_root_volume_size" {
  default = "25"
}

variable "nextflow_volume_size" {
  default = "100"
}

variable "batch_root_block_device_size" {
  type    = number
  default = 32
}

variable "batch_root_block_device_type" {
  type    = string
  default = "gp3"
}

variable "batch_spot_fleet_allocation_strategy" {
  type    = string
  default = "BEST_FIT"
}

variable "batch_spot_fleet_bid_percentage" {
  type    = number
  default = 64
}

variable "batch_min_vcpus" {
  type    = number
  default = 0
}

variable "batch_max_vcpus" {
  type    = number
  default = 128
}

variable "batch_vcpus" {
  type    = number
  default = 1
}

variable "batch_memory" {
  type    = number
  default = 2048
}

variable "batch_instance_types" {
  type    = list(string)
  default = ["c5d", "m5d", "r5d"]
}

variable "vpc_private_subnet_ids" {
  type = list(string)
}
