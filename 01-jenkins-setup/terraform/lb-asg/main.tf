data "terraform_remote_state" "network" {   
  backend = "s3"
   
  config = {
    bucket = "guru-prod-terraform-state"

    key     = "env:/${terraform.workspace}/vpc-module/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

data "aws_ami" "controller_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["jenkins-controller"]
  }
  owners = ["self"]
}

locals {
  private_subnet_ids = [data.terraform_remote_state.network.outputs.private_subnets[0],
                    data.terraform_remote_state.network.outputs.private_subnets[1],
                    data.terraform_remote_state.network.outputs.private_subnets[2]
              ]
}

module "lb-asg" {
  source        = "../modules/lb-asg"
  subnets       = local.private_subnet_ids
  ami_id        = data.aws_ami.controller_ami.id
  instance_type = "t2.small"
  key_name      = "londonkey"
  environment   = "dev"
  vpc_id        = data.terraform_remote_state.network.outputs.vpc_id
}