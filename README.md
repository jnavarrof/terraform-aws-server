# AWS EC2 Instance deploy examples

## Prerequesites

### Download Terraform

[Terraform download page](https://www.terraform.io/downloads.html)

### Setup AWS cli credentials

```bash
# Install AWS client
$ pip install aws-cli

# Configure
$ aws configure
WS Access Key ID [None]: XXXXXX
AWS Secret Access Key [None]: XXXXX
Default region name [None]: eu-west-1
Default output format [None]:

# Test 
$ aws s3 ls
2019-11-08 13:02:56 shared-storage-s3
2019-11-08 19:03:41 tf-state-storage-001
```

## Working with Terraform workspaces

Each Terraform configuration has an associated backend that defines how operations are executed and where persistent data such as the Terraform state are stored.

The persistent data stored in the backend belongs to a workspace. Initially the backend has only one workspace, called "default", and thus there is only one Terraform state associated with that configuration.


List available workspaces

```bash
$ terraform workspace list
  default
  common
* jnavarro

$ terraform workspace show
jnavarro
```

Select and switch between workspaces. Show resources.

```bash
# Select this ws and show resources
$ terraform workspace select jnavarro
$ terraform show
# no resources

$ terraform workspace select common
Switched to workspace "common".
$ terraform show

# aws_iam_group.cloud:
resource "aws_iam_group" "cloud" {
    arn       = "arn:aws:iam::6666666:group/Cloud"
[..]
# aws_iam_group.developers:
resource "aws_iam_group" "developers" {
    arn       = "arn:aws:iam::66666666:group/Developers"
[..]
# aws_iam_policy.policy:
resource "aws_iam_policy" "policy" {
    arn         = "arn:aws:iam::666666666:policy/test-policy"
    id          = "arn:aws:iam::666666666:policy/test-policy"
[..]
# aws_iam_role.test_role:
resource "aws_iam_role" "test_role" {
    arn                   = "arn:aws:iam::6666666:role/test_role"
                        Service = "ec2.amazonaws.com"
[..]
# aws_s3_bucket.shared-storage-s3:
resource "aws_s3_bucket" "shared-storage-s3" {
    arn                         = "arn:aws:s3:::shared-storage-s3"
    bucket_domain_name          = "shared-storage-s3.s3.amazonaws.com"
    bucket_regional_domain_name = "shared-storage-s3.s3.eu-west-1.amazonaws.com"
[..]
```

## Deploy a single EC2 instance

```bash
# Select workspace 
$ cd ec2-instance
$ terraform workspace select jnavarro

# Deploy an instance
$ terraform plan -var prefix=server1
[..]

$ terraform apply -var prefix=server1
Plan: 3 to add, 0 to change, 0 to destroy.
Do you want to perform these actions in workspace "jnavarro"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
  Enter a value: yes
aws_key_pair.keypair: Creating...
aws_security_group.server: Creating...
aws_key_pair.keypair: Creation complete after 1s [id=server1-jnavarro-keypair20191109211025215300000001]
aws_security_group.server: Creation complete after 2s [id=sg-05fd998079994b67d]
module.ec2.aws_instance.this[0]: Creating...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:
instances_public_ips = [
  "34.255.192.247",
]

# Show resources
$ terraform show 
[..]
    tags                    = {}
}
Outputs:
instances_public_ips = [
    "34.255.192.247",
]
```

## Create a new workspace and deploy another instance 

```bash
# Create a new workspace 
$ terraform workspace new A
Created and switched to workspace "A"!

You are now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

$ terraform show 
# Nothing deployed in this workspace

# Deploy an instance
$ terraform plan -var prefix=server2
[..]

$ terraform apply -var prefix=server2
[..]
Outputs:
instances_public_ips = [
    "54.255.192.17",
]

# Destroy resources in this workspace
$ terraform destroy -var prefix=server2
Do you really want to destroy all resources in workspace "A"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

# Remove workspace A. Switch to another worspace first.
$ terraform workspace select jnavarro
Switched to workspace "jnavarro"

$ terraform workspace delete A
Deleted workspace "A"!
```

## Test S3 access

```bash
# Login to this instance
$ ssh ubunt@$(terraform output -json | jq -r ".instances_public_ips.value[0]")
Last login: Sun Nov 10 20:37:58 2019 from 80.5.212.139
ubuntu@ip-172-31-5-180 $

# Install the aws cli tool
$ sudo pip install awscli

# List s3 buckets
$ aws s3 ls
2019-11-08 19:16:17 shared-storage-s3
2019-11-08 19:03:41 tf-state-storage-001

# Access to the Terraform state bucket is denied
$ aws s3 ls tf-state-storage-001
An error occurred (AccessDenied) when calling the ListObjectsV2 operation: Access Denied

# Working the share 
$ aws s3 ls shared-storage-s3
$ aws s3 cp NOFILE shared-storage-s3/NOFILE
upload: ./NOFILE to s3://shared-storage-s3/NOFILE
$ aws s3 ls s3://shared-storage-s3
2019-11-10 21:37:14          0 NOFILE

# Mount the S3 bucket using FUSE (low performance doing intensive I/O, file lock issues)
$ mkdir $HOME/shared-storage-s3
$ s3fs -o iam_role=ec2InstanceRole -o use_cache=/tmp shared-storage-s3 $HOME/shared-storage-s3
$ dd if=/dev/zero of=ZERO bs=1M count=1024
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 47.63 s, 22.5 MB/s
```

## Destroy resources in this workspace

```bash
# Check current workspace
$ terraform workspace show
jnavarro

# Destroy resources in workspace jnavarro
$ terraform destroy -var prefix=server1
aws_key_pair.keypair: Refreshing state... [id=server1-jnavarro-keypair20191109211025215300000001]
data.aws_vpc.default: Refreshing state...
aws_security_group.server: Refreshing state... [id=sg-05fd998079994b67d]

[..]
Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources in workspace "jnavarro"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
[..]
aws_key_pair.keypair: Destruction complete after 0s
aws_security_group.server: Destruction complete after 1s

Destroy complete! Resources: 3 destroyed.

# Done!
```

## Deploy a single EC2 instance and attach an exsiting EBS volumen

```bash
$ cd ec2-with-ebs/
$ terraform workspace show
jnavarro

# Edit datasources or add a new variable to select an existing EBS volume

# Validate 
$ terraform validate
Success! The configuration is valid.

# Plan and deploy
terraform plan -var prefix=server-ebs
terraform apply -var prefix=server-ebs

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
Outputs:

data_ebs_volume_attachment_id = [
  "vol-0110d7629c3150532",
]
data_ebs_volume_attachment_instance_id = [
  "i-00150ee806563c537",
]
instances_public_ips = [
  "34.245.37.105",
]

# Destroy. WARN! Remember umount mounted filesystem (bootstrap.sh)
ssh ubunut@34.245.37.105 "sudo umount /mnt/xvdi"
terraform destroy -var prefix=server-ebs
```