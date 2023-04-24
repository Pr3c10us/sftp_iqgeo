variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "zone_name" {
  description = "Name of the Route53 DNS zone"
  type        = string
}

variable "server_name" {
  description = "Name of the Transfer server"
  type        = string
}

variable "service_name" {
  description = "Name of the Transfer server"
  type        = string
}

variable "server_domain" {
  description = "Domain name for the Transfer server"
  type        = string
}

variable "transfer_user_names" {
  description = "User name(s) for SFTP server"
  type        = list(string)
}

variable "role_name" {
  description = "Name of the IAM role for the Transfer server"
  type        = string
}

variable "policy_name" {
  description = "Name of the IAM policy for the IAM role"
  type        = string
}

variable "transfer_server_ssh_keys" {
  description = "SSH Key(s) for transfer server user(s)"
  type        = list(string)
}
