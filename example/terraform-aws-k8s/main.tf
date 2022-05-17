terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

variable "num_workers" {
  type = number
}

variable "cluster_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "pub_key_path" {
  type = string
}

variable "private_key_path" {
  type = string
}

# get default vpc and load it as a terraform resource
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_key_pair" "dev_key" {
  key_name = format("tf-%s-key", var.cluster_name)
  public_key = file(var.pub_key_path)
}

resource "aws_security_group" "cluster_node_internal" {
  name        = format("tf-%s-node-internal", var.cluster_name)
  description = "allow communication between k8s nodes"

  ingress {
    description = "all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "control_plane" {
  instance_type = "t2.medium"
  ami           = var.ami
  key_name      = aws_key_pair.dev_key.key_name

  tags = {
    Name = format("tf-%s-control-plane", var.cluster_name)
  }

  security_groups = [
    aws_security_group.cluster_node_internal.name
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -s https://raw.githubusercontent.com/mikechesterwang/setup-kubeadm/main/init.sh | bash -s -- -e ${self.private_dns}"
    ]
  }
}

data "external" "kubeadm_secret" {

  depends_on = [
    aws_instance.control_plane
  ]

  program = ["bash", "get_join_info.sh"]

  query = {
    ip               = aws_instance.control_plane.public_ip
    user             = "ubuntu"
    private_key_path = var.private_key_path
  }
}

output "token" {
  value = data.external.kubeadm_secret.result.token
}

output "cert" {
  value = data.external.kubeadm_secret.result.cert
}

output "connection_string" {
  value = format("ssh ubuntu@${aws_instance.control_plane.public_ip} -i ${var.private_key_path}")
}

resource "aws_instance" "worker-node" {
  count = var.num_workers

  instance_type = "t2.medium"
  ami           = var.ami
  key_name      = aws_key_pair.dev_key.key_name

  tags = {
    Name = format("tf-%s-worker-node", var.cluster_name)
  }

  security_groups = [
    aws_security_group.cluster_node_internal.name
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -s https://raw.githubusercontent.com/mikechesterwang/setup-kubeadm/main/join.sh | bash -s -- -e ${aws_instance.control_plane.private_dns} -t ${data.external.kubeadm_secret.result.token} -h ${data.external.kubeadm_secret.result.cert}"
    ]
  }
}
