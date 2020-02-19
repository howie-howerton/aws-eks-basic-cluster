# EC2 key name (for SSH-ing into EC2 instances)
output "ec2_key_name" {
  value       = "${var.key_name}"
  description = "The key pair used to authenticate to EC2 instances via SSH."
}
#Bastion info
output "bastion_public_ip" {
  value       = "${aws_instance.bastion.public_ip}"
  description = "The public IP address of the bastion host"
}
# Variable to dynamically create the config-map needed to join worker nodes to the cluster
output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}
# K8s configuration file (in case we need to manually configure kubectl on another workstation)
output "kubeconfig" {
  value = "${local.kubeconfig}"
}

