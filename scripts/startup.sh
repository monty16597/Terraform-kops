#!/bin/bash

sudo curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall

# Installing KOPS binaries

cd /opt &&  curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
cd /opt &&  chmod +x kops-linux-amd64
cd /opt &&  sudo mv kops-linux-amd64 /usr/local/bin/kops

# Installing Kubectl binaries
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Generating new SSH key file
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa|echo -e 'y\n' > /dev/null

ZONES=$1
TOPOLOGY=$2
MASTER_SIZE=$3
MASTER_NODES=$4
WORKERS_SIZE=$5
WORKERS_NODES=$6
WORKERS_VOLUME_SIZE=$7
CLUSTER_NAME=$8
NETWORKING=$9
S3_BUCKET=$10
REGION=$11


export REGION=$REGION
export KOPS_STATE_STORE=s3://$S3_BUCKET
export NAME=$CLUSTER_NAME

# Without networking stratergy
kops create cluster --zones $ZONES --topology $TOPOLOGY --master-size $MASTER_SIZE --master-count $MASTER_NODES --node-size $WORKERS_SIZE --node-count $WORKERS_NODES --node-volume-size $WORKERS_VOLUME_SIZE $CLUSTER_NAME

# With networking stratergy
# kops create cluster --zones $ZONES --topology $TOPOLOGY --networking $NETWORKING --master-size $MASTER_SIZE --master-count $MASTER_NODES --node-size $WORKERS_SIZE --node-count $WORKERS_NODES --node-volume-size $WORKERS_VOLUME_SIZE $CLUSTER_NAME

# Creating SSH-KEY screte
kops create secret --name $CLUSTER_NAME sshpublickey admin -i ~/.ssh/id_rsa.pub

#echo "----------------------Please execute below command to start cluster manually in the kops instance-----------------"
echo "kops update cluster --name $CLUSTER_NAME --yes"