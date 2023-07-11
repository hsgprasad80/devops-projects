provider "aws" {
  region = "eu-west-2"
}

variable "instance_name" {
  type = string
  default = "live-test-instance"
}

variable "ami_id" {
  type = string
  default = "ami-0eb260c4d5475b901"
}

variable "instance_type" {
  type = string
  default = "t2.small"
}

variable "key_name" {
  type = string
  default = "londonkey"
}

variable "security_group_ids" {
  type    = list(string)
  default = [""]
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type    = list(string)
  default = ["", "", ""]
}

variable "vpc_id" {
  description = "The ID of the VPC to use for the resources."
}
