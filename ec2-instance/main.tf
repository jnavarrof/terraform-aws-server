variable "instances_number" {
  default = 1
}

resource "aws_security_group" "server" {
  name        = "${var.prefix}-server"
  description = "Allow Server inbound traffic"
  # vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "keypair" {
  key_name_prefix = "${var.prefix}-${terraform.workspace}-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "ec2" {
  source  = "github.com/jnavarrof/terraform-aws-ec2-instance"

  name                        = "${var.prefix}-instance"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [ aws_security_group.server.id ]
  associate_public_ip_address = true
  monitoring                  = false
  key_name                    = aws_key_pair.keypair.key_name
  user_data                   = file("../scripts/bootstrap.sh")

  # Attacj instance role created in the common workspace
  iam_instance_profile        = "ec2InstanceRole"
}

