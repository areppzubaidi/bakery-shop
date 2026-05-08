variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "bakery-shop"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "bakery-key"
}

variable "docker_image" {
  description = "Docker image to run"
  type        = string
  default     = "your_dockerhub_username/bakery-shop:latest"
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
  sensitive   = true
}
