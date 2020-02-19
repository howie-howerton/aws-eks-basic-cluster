# aws-eks-basic-cluster
A terraform template to create a basic AWS EKS cluster

## Detailed Description

This terraform template is designed to facilitate the creation of a 'vanilla' AWS EKS cluster for usage with testing/demos/etc.
It will create:
- A new VPC that contains all associated resoruces
- An Internet Gateway (IGW)
- A NAT Gateway (NGW)
- 2 public subnets and associated route table
- 2 private subnets and associated route table
- An EKS cluster with 2 worker nodes.
- An Ubuntu-based Bastion Host


The template has a local-exec provisioner that will take care of configuring kubectl (~/.kube/config) in order to access the cluster from your local MBP/Linux workstation.

In the event that controlling the EKS cluster from your local MBP/Linux workstation isn't ideal, an EC2 Ubuntu-based instance is also created and initialized for you.

# AWS Pre-Requisites
- An AWS IAM User Account (with permissions to create EKS and EC2 resources) + Access Keys
- An AWS EC2 Key pair 

# Local MBP/Linux workstation Pre-Requisites
- git               
- terraform v0.12+  
- awscli v1.16.308+ 
- kubectl v1.15+    
- helm v3.0+        
On a MBP, you can easily install all of these pre-requisites with:
```
brew install git terraform awscli kubectl helm
```

# Usage
1. Clone this repository
```
git clone https://github.com/howie-howerton/aws-eks-basic-cluster.git
```
2. Edit the variables in the sample 'terraform.tfvars.changeme' file to suit your AWS environment

3. Remove the '.changeme' extension from terraform.tfvars.changeme so that the filename reads as: terraform.tfvars

4. Initialize terraform
```
terraform init
```
5. Run 'terraform apply' to execute the template
```
terraform apply
```
   This process typically takes 10-15 minutes.

6. Review the resources that will be created by the template and type "yes" to proceed.
   Once the template completes creating all resources, you should be able to use kubectl to manage your new cluster.
```
kubectl cluster-info
```
```
kubectl get nodes
```
   Note: If the output of the above command is "No resources found.", run the following command:
```
kubectly apply -f config_map.yaml
```
# Cleaning up
After you've finished with your cluster, you can destroy/delete it (to keep your AWS bill as low as possible)
```
terraform destroy -auto-approve
```
   This process typically takes 10-15 minutes.
