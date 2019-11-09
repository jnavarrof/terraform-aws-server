
all: ec2-instance

ec2-instance:
	make -C ec2-instance

common:
	make -C common create

s3-state:
	make -C s3state create

