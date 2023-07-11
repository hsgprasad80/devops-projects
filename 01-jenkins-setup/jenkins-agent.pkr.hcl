variable "ami_id" {
  type    = string
  default = "ami-0eb260c4d5475b901"
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "public_key_path" {
    type = string
    default = "/devops-tools/jenkins/id_rsa.pub"
}

locals {
  app_name = "jenkins-agent"
}

data "amazon-ami" "base_image" {
  filters = {
    architecture        = "x86_64"
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
}

source "amazon-ebs" "jenkins" {
  ami_name      = "${local.app_name}"
  instance_type = "t2.micro"
  region        = "eu-west-2"
  subnet_id     = "subnet-0512f4093561600fe"
  vpc_id        = "vpc-0d68150ce3d6b9d8f"
  source_ami    = data.amazon-ami.base_image.id
  ssh_username  = "ubuntu"
  availability_zone    = "eu-west-2a"
  iam_instance_profile = "jenkins-instance-profile"
  tags = {
    Env  = "dev"
    Name = "${local.app_name}"
  }
}

build {
  sources = ["source.amazon-ebs.jenkins"]

  provisioner "ansible" {
  playbook_file = "ansible/jenkins-agent.yaml"
  extra_arguments = [ "--extra-vars", "public_key_path=${var.public_key_path}", 
                      "--scp-extra-args", "'-O'", 
                      "--ssh-extra-args", "-o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa" ]
  } 
  
  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }
}
