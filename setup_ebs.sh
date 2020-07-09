#!/bin/bash

set -e

TERRAFORM_CONTAINER=hashicorp/terraform:0.11.3

EXEC_PATH=$(pwd)

SYSTEMID=$2

function runTerraform() {
    # get your AWS access token on the fly via ADFS (access federation) first, then run...
    docker run -ti -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" -e AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" -w /data -v $(pwd):/data $TERRAFORM_CONTAINER $@
}

if [[ "$1" == "init" ]]
then
    cd $EXEC_PATH/terraform/ebs_volume; runTerraform init --backend-config=terraform.conf --var-file terraform.tfvars --var "system_id=$SYSTEMID"
elif [[ "$1" == "plan" ]]
then
    cd $EXEC_PATH/terraform/ebs_volume; runTerraform plan --var-file terraform.tfvars --var "system_id=$SYSTEMID"
elif [[ "$1" == "apply" ]]
then
    cd $EXEC_PATH/terraform/ebs_volume; runTerraform apply --var-file terraform.tfvars --var "system_id=$SYSTEMID"
elif [[ "$1" == "output" ]]
then
    cd $EXEC_PATH/terraform/ebs_volume; runTerraform output $2
elif [[ "$1" == "destroy" ]]
then
    cd $EXEC_PATH/terraform/ebs_volume; runTerraform destroy --var-file terraform.tfvars --var "system_id=$SYSTEMID"
else
    echo "usage: setup_ebs.sh [init, plan, apply, output, destroy] SystemID"
    exit 1
fi