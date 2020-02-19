

data "template_file" "bastion_user_data" {
  template = "${file("bastion-user-data.sh")}"

  vars = {
    config_map_aws_auth = "${local.config_map_aws_auth}"
    aws_access_key_id   = "${var.aws_access_key_id}"
    aws_secret_access_key = "${var.aws_secret_access_key}"
    cluster_name          = "${var.cluster_name}"
    region                = "${var.aws_region}"
    kubeconfig            = "${local.kubeconfig}"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0a313d6098716f372" #ubuntu
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"
  subnet_id                   = "${aws_subnet.demo_public1_subnet.id}"
  user_data                   = "${data.template_file.bastion_user_data.rendered}"
  depends_on                  = ["aws_eks_cluster.demo", "aws_launch_configuration.demo"]

  tags = {
    Name = "${var.tag_prefix}_bastion"
  }
}

resource "aws_security_group" "bastion" {
  name        = "${var.tag_prefix}_bastion_sg"
  description = "Access to bastion from workstation IP"
  vpc_id      = "${aws_vpc.demo_vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${local.workstation-external-cidr}"] #"${var.admin_ip}"
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_prefix}_bastion_sg"
  }
}
