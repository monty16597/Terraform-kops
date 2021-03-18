#!/bin/bash

echo "ScriptStarted"
sudo teraform init
echo "---------------------------------------------------------------------"
echo "Note. Make sure you use unique name."
echo "---------------------------------------------------------------------"
echo "Please Eneter S3 Name (This name should be same as hosted zone you have created)."
read s3_name
echo "Please Eneter Cluster Name (This name should be same as hosted zone you have created)."
read cluster_name
echo "#####################################################################"
echo "Creating s3 bucket....."
terraform apply -auto-approve -var="s3_name=$s3_name" -var="cluster_name=$cluster_name" --target aws_iam_role.kops-role --target aws_iam_policy.kops-policy --target aws_iam_role_policy_attachment.kops-attach --target aws_iam_instance_profile.kops-profile && echo "Policy created"|| echo "Error in creating policy.............." 
echo "#####################################################################"
terraform apply -auto-approve -var="s3_name=$s3_name" -var="cluster_name=$cluster_name" --target aws_vpc.main --target aws_subnet.public --target aws_internet_gateway.kops-igw --target aws_route_table.main --target aws_route_table_association.public --target aws_security_group.kops  && echo "Network created" || echo "Error in creating Network.............."
echo "#####################################################################"
echo "Creating Kops Server....."
terraform apply -auto-approve -var="s3_name=$s3_name" -var="cluster_name=$cluster_name" --target aws_key_pair.kops --target aws_instance.kops --target aws_eip.kops  && echo "Server created" || echo "Error in creating server.............."
echo "Kops Server Created....."
echo "---------------------------------------------------------------------"
echo "Note: Please use kops.ppk or kops.pem file to do SSH in the kops server."
echo "---------------------------------------------------------------------"