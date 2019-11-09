
all: create

init:
	terraform init 

create: init
	terraform plan 
	terraform apply -auto-approve

destroy:
	terraform destroy
