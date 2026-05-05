variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "main_ami" {
  description = "The verified Amazon Linux 2023 AMI"
  type        = string
  default     = "ami-0e96f8459c59b3ff6"
}

variable "instance_type" {
  description = "The size of the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "alb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
  default     = "fortress-alb-tf"
}