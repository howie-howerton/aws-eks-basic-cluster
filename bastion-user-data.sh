#!/bin/bash
apt update
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip  
pip3 install awscli
apt install -y awscli
# Create the AWS CLI config and credentials files
mkdir -p /home/ubuntu/.aws/
cat << AWS_CONFIG > /home/ubuntu/.aws/config
[default]
region = ${region}
output = json
AWS_CONFIG
cat << AWS_CREDENTIALS > /home/ubuntu/.aws/credentials
[default]
aws_access_key_id = ${aws_access_key_id}
aws_secret_access_key = ${aws_secret_access_key}
AWS_CREDENTIALS

# install and configure kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
aws eks --region "${region}" update-kubeconfig --name "${cluster_name}"
# Save the above command to a local shell script in case it doesn't execute via user-data correctly for some reason.
cat << KUBECONFIG_AWSCLI > /home/ubuntu/kubeconfig.sh
aws eks --region "${region}" update-kubeconfig --name "${cluster_name}"
KUBECONFIG_AWSCLI
chmod +x /home/ubuntu/kubeconfig.sh
# Download and put aws-iam-authenticator util in the PATH
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
# Create the .kube/config configuration file for kubectl to access the cluster
mkdir -p /home/ubuntu/.kube
cat << KUBECONFIG > /home/ubuntu/.kube/config
${kubeconfig}
KUBECONFIG
# Create/Apply the needed configmap (using terraform's dynamic variables) to join worker nodes to the cluster
mkdir -p /home/ubuntu/yaml/
echo "${config_map_aws_auth}" > /home/ubuntu/yaml/config_map_aws_auth.yaml
sleep 5s
kubectl apply -f /home/ubuntu/yaml/config_map_aws_auth.yaml
cat << CONFIG_MAP > /home/ubuntu/config_map_aws_auth.sh
kubectl apply -f yaml/config_map_aws_auth.yaml
CONFIG_MAP
chmod +x /home/ubuntu/config_map_aws_auth.sh
sleep 45s
# install helm3 (to prepare for future deployments that use helm)
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
sleep 5
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
#helm search repo stable
#helm install stable/jenkins --generate-name
#helm list

