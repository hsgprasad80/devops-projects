-include ../../../../.env

echo:
	echo ${wrkname}
	env | grep "TF"

## Initialize terraform remote state
init:
	[ -f .terraform/terraform.tfstate ] ||  terraform init
	 terraform workspace select ${wrkname} ||  terraform workspace new ${wrkname}

## Clean up the project
clean:
	rm -rf .terraform *.tfstate*

## Pass arguments through to terraform which require remote state
apply console destroy graph plan output providers show: init
	 terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt validate version:
	 terraform $@