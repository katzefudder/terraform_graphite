#!/bin/bash

set -e

TERRAFORM_CONTAINER=hashicorp/terraform:0.11.3
SYSTEMID=$2

EXEC_PATH=$(pwd)

AWS_DEFAULT_REGION=eu-central-1

# fetch the latest KMI
AMI_ID=$(aws ec2 describe-images --query 'Images[*].[ImageId,CreationDate]' --filters 'Name=name,Values=kmi_centos7*' --region eu-central-1 --output text | sort -k2 -r | head -n1 | cut -f1)

function runTerraform() {
    # get your AWS access token on the fly via ADFS (access federation) first, then run...
    docker run -ti -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" -e AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" -w /data -v $(pwd):/data $TERRAFORM_CONTAINER $@
}

function runAnsiblePlaybook() {
    cd $EXEC_PATH/ansible;
    # get the IP from the newly created EC2 machine
    IP_ADDRESS=$(aws ec2 describe-instances --filters "Name=tag:SystemID,Values=$SYSTEMID" --output text --query 'Reservations[].Instances[].[PrivateIpAddress]' | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

    # wait until EC2 instance is available via SSH to run Ansible playbook
    echo "waiting for SSH to be available"
    while ! nc -z "$IP_ADDRESS" 22 &>/dev/null; do
        echo "SSH available on $IP_ADDRESS"
        sleep 5
    done

    # start the Ansible playbook
    ansible-playbook -i inventory -i "$IP_ADDRESS", host.yml
}

# fetch the EBS VOLUME first
cd $EXEC_PATH/terraform/ebs_volume;
EBS_VOLUME=$(runTerraform output aws_ebs_volume.id | sed 's/[^a-zA-Z0-9\-]//g')

# break - if there's no volume
if [ -z $EBS_VOLUME ]
  then
    printf "\n\n-------------------------------------------------------------\n"
    echo "No EBS Volume found to be used! Please use `setup_ebs.sh` to create the EBS Volume first."
    exit 1
  else
    echo "Using predefined EBS Volume."
fi

if [[ "$1" == "init" ]]
then
    cd $EXEC_PATH/terraform/graphite; runTerraform init --backend-config=terraform.conf --var-file terraform.tfvars --var "system_id=$SYSTEMID" --var "aws_ami_id=$AMI_ID"
elif [[ "$1" == "plan" ]]
then
    cd $EXEC_PATH/terraform/graphite; runTerraform plan --var-file terraform.tfvars --var "system_id=$SYSTEMID" --var "ebs_volume=$EBS_VOLUME" --var "aws_ami_id=$AMI_ID"
elif [[ "$1" == "apply" ]]
then
    cd $EXEC_PATH/terraform/graphite; runTerraform apply --var-file terraform.tfvars --var "system_id=$SYSTEMID" --var "ebs_volume=$EBS_VOLUME" --var "aws_ami_id=$AMI_ID"
    runAnsiblePlaybook
elif [[ "$1" == "provision" ]]
then
    runAnsiblePlaybook
elif [[ "$1" == "output" ]]
then
    cd $EXEC_PATH/terraform/graphite; runTerraform output $2
elif [[ "$1" == "destroy" ]]
then
    cd $EXEC_PATH/terraform/graphite; runTerraform destroy --var-file terraform.tfvars --var "ebs_volume=$EBS_VOLUME"  --var "system_id=$SYSTEMID" --var "aws_ami_id=$AMI_ID"
else
    echo "usage: setup_graphite.sh [init, plan, apply, output, destroy] SystemID"
    exit 1
fi