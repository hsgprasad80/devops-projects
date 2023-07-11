variable "ami_id" {
  type    = string
  default = "ami-007ec828a062d87a5"
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
variable "efs_mount_point" {
  type    = string
  default = ""
}

locals {
  app_name = "jenkins-controller"
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
  availability_zone = "eu-west-2a"
  source_ami    = data.amazon-ami.base_image.id
  subnet_id     = "subnet-0512f4093561600fe"
  vpc_id        = "vpc-0d68150ce3d6b9d8f"
  ssh_username  = "ubuntu"
  tags = {
    Env  = "dev"
    Name = "${local.app_name}"
  }
}

build {
  sources = ["source.amazon-ebs.jenkins"]

  provisioner "ansible" {
  playbook_file = "ansible/jenkins-controller.yaml"
  extra_arguments = [ "--extra-vars", "ami-id=${var.ami_id} efs_mount_point=${var.efs_mount_point}",
                      "--scp-extra-args", "'-O'", 
                      "--ssh-extra-args", "-o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa" ]
  } 
  
  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }
}

// packer build -var "efs_mount_point=fs-0a39ecdeb452b4444.efs.eu-west-2.amazonaws.com" jenkins-controller.pkr.hcl 
// 'openjdk-17-jdk=17.0.7+7~us1-0ubuntu1~22.04.2'' failed:E: Unable to correct problems, you have held broken packages.\n", "rc": 100, "stderr"