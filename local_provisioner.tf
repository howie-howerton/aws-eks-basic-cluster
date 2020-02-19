resource "null_resource" "local_mac_provisioner" {
    provisioner "local-exec" {
        command = <<EOT
        echo "################################################################################"
        echo "# Running local provisioner"
        echo "################################################################################"
        aws eks --region "${var.aws_region}" update-kubeconfig --name "${var.cluster_name}"
        echo "${local.config_map_aws_auth}" > config_map.yaml
        sleep 3
        kubectl apply -f ./config_map.yaml
        sleep 15
        EOT
  }

  depends_on                  = ["aws_eks_cluster.demo", "aws_launch_configuration.demo"]
}