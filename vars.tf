variable "aws_profile" {
  description = "Name of the AWS profile to use when deploying resources to AWS."
  default     = "default"
}
variable "aws_region" {
  description = "The preferred AWS Region into which to launch the resources outlined in this template."
  default     = "us-east-1"
}
variable "vpc_cidr" {
  description = "Network CIDR to be applied to the VPC"
  default     = "10.1.0.0/16"
}
variable "cidrs" {
  description = "CIDR ranges to be applied to public and private subnets"
  type        = "map"
}
variable "tag_prefix" {
  description = "Prefix to prepend to tags in order to uniquely identify resources in the AWS console."
  default     = "demo"
}
variable "key_name" {}
variable "key_path" {}
variable "cluster_name" {
  description = "EKS cluster name."
  default     = "eks_basic_demo"
}
variable "admin_ip" {
  description = "List of CIDRs used for Accessing Bastion Host."
  type        = "list"
}

variable "aws_access_key_id" {
  description = "AWS Access Key"
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
}
