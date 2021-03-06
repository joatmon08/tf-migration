variable "env" {}

variable "aws_security_group_web_server_id" {}

variable "aws_subnet_public_id" {}

variable "key_rsa_pub" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployment" {
  key_name   = "${var.env}-key"
  public_key = "${var.key_rsa_pub}"
}

resource "aws_instance" "web" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = ["${var.aws_security_group_web_server_id}"]
  subnet_id              = "${var.aws_subnet_public_id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.deployment.id}"

  user_data = <<EOF
echo "hi"
ls
EOF

  tags {
    Env = "${var.env}"
  }
}

resource "aws_eip" "web" {
  instance = "${aws_instance.web.id}"
  vpc      = true
}

output "aws_eip_web_ip" {
  value = "${aws_eip.web.public_ip}"
}
