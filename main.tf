resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_block_range
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "myvpc"
    Environment = "mydev"
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name        = "myinternet"
    Environment = "mydev"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.myvpc.id}"
  cidr_block              = var.pub_sub_range
  availability_zone = var.availability_zone["a"]
  tags = {
    Name        = "mypublicsubnet"
    Environment = "mydev"
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.myvpc.id}"
  cidr_block              = var.priv_sub_range
  tags = {
    Name        = "myprivatesubnet"
    Environment = "mydev"
  }
}
resource "aws_nat_gateway" "nat" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.public_subnet.id
}
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name        = "myprivate"
    Environment = "mydev"
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name        = "mypublic"
    Environment = "mydev"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_instance" "ec2_public" {
  count = var.instance_count
  ami                         = var.ami_region["ap-south-1"]
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.key_pair["key_mumbai"]
  subnet_id                   = "${aws_subnet.public_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.SG.id}"]
  user_data = <<-EOF
  #! /bin/bash
  sudo apt update
  sudo apt install -y openjdk-11-jdk
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo apt update
  sudo apt -y install jenkins
  sudo systemctl start jenkins
  sudo systemctl enable jenkins
  EOF 
  tags = {
    "Name" = "Server ${count.index}"
  }

}
resource "aws_security_group" "SG" {
  name                   = "my instances"
  vpc_id                 = "${aws_vpc.myvpc.id}"
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      "Name" = "my_security"
  }
}
