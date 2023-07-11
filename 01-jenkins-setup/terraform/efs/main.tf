data "terraform_remote_state" "network" {   
  backend = "s3"
   
  config = {
    bucket = "guru-prod-terraform-state"

    key     = "env:/${terraform.workspace}/vpc-module/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

locals {
  private_subnet_ids = [data.terraform_remote_state.network.outputs.private_subnets[0],
                    data.terraform_remote_state.network.outputs.private_subnets[1],
                    data.terraform_remote_state.network.outputs.private_subnets[2]
              ]
}
module "efs_module" {
  source = "../modules/efs"
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = local.private_subnet_ids 
}

output "efs_dsn_name" {
  value = module.efs_module.dns_name
}