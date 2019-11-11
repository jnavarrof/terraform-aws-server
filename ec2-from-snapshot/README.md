# EC2 instance with EBS volume attachment

Configuration in this directory creates EC2 instances, EBS volume and attach it together.

Unspecified arguments for security group id and subnet are inherited from the default VPC.

This example outputs instance id and EBS volume id.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run terraform destroy when you don't need these resources.

## Inputs

```bash
Name	Description	Type	Default	Required
instances_number		string	"1"	no
```

## Outputs

```bash
Name	Description
ebs_volume_attachment_id	The volume ID
ebs_volume_attachment_instance_id	The instance ID
instances_public_ips	Public IPs assigned to the EC2 instance
```
