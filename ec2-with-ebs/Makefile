
all: create

init:
	terraform init
	terraform workspace new $(USER) 

create:
	terraform workspace select $(USER) 
	terraform plan 
	terraform apply

destroy:
	terraform destroy
