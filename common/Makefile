
all: create

init:
	terraform init
	terraform workspace new common 

create:
	terraform workspace select common 
	terraform plan 
	terraform apply -auto-approve

destroy:
	terraform destroy
