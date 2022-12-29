variable "vpc_block_range" {
description = "cidr_range"
default = "190.20.60.0/24"
}
variable "instance_type" {
description = "instance_size"
default = "t2.micro"
}
variable "ami_region" {
  type = map
  default = {
    "us-east-2" = "ami-0283a57753b18025b"
    "ap-south-1" = "ami-07ffb2f4d65357b42"
  }
}
variable "key_pair" {
  type = map
  default = {
    "key_ohio" = "ohio_dev"
    "key_mumbai" = "java_deploy"
  }
}
variable "region" {
  default = "ap-south-1"
}
variable "availability_zone" {
  type = map
  default = {
    "a" = "ap-south-1a"
    "b" = "ap-south-1b"
    "c" = "ap-south-1c"
 }
}
variable "pub_sub_range" {
description = "cidr_range"
default = "190.20.60.0/25"
}
variable "priv_sub_range" {
description = "cidr_range"
default = "190.20.60.128/25"
}
variable "instance_count" {
description = "no_of_instances"
default = "2"
}
