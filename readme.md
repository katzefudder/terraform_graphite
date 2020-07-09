# Graphite

Terraform and Ansible together shall be used to automate each and every step towards setting up, running and maintaining 
the infrastructure as well as the software needed to provide all parts that make up Graphite.

## Terraform
To create and maintain infrastructure in AWS, we chose to use Terraform.
For the sake of retaining persistent data beyond the lifecycle of an EC2 instance, 
we chose to create the _computing resource_ (EC2) apart from the storage device (EBS).

### Shell script to plan, apply, destroy
Both EBS and EC2 are to be managed via shell scripts: `setup_ebs.sh` and `setup_ec2.sh`

### Using Terraform
Terraform is configured to use AWS as the provider to be able to "speak" AWS.
To persist Terraform's state we chose to use S3 as it's backend.

The EBS volume has to be created first, so that it can be attached to the EC2 instance and mounted later (mount point `/data`).
Terraform will keep track of each the EC2's state as well as the EBS' state separately.

#### init Terraform
Please see the official [docs](https://www.terraform.io/docs/commands/init.html)

- init ebs
`./setup_ebs.sh init plain-graphite`
- init ec2
`./setup_ec2.sh init plain-graphite`

#### plan Terraform
Please see the official [docs](https://www.terraform.io/docs/commands/plan.html)

- plan ebs
`./setup_ebs.sh plan plain-graphite`
- plan ec2
`./setup_ec2.sh plan plain-graphite`

#### apply Terraform
Please see the official [docs](https://www.terraform.io/docs/commands/apply.html)

`./setup_ebs.sh apply plain-graphite`
`./setup_ec2.sh apply plain-graphite`



## Ansible
We chose to use Ansible to provision the EC2 instance, using the latest available KMI (CentOS).

#### Graphite

Ansible will create the following:
- the folder structure for Graphite's storage
- the configuration for Graphite
    - [carbon.conf](https://graphite.readthedocs.io/en/latest/config-carbon.html#carbon-conf)
    - [storage-aggregation.conf](https://graphite.readthedocs.io/en/latest/config-carbon.html#storage-aggregation-conf)
    - [storage-schemas.conf](https://graphite.readthedocs.io/en/latest/config-carbon.html#storage-schemas-conf)
    - [aggregation-rules.conf](https://graphite.readthedocs.io/en/latest/config-carbon.html#aggregation-rules-conf)


#### Graphite web application
Please see the official [docs](https://graphite.readthedocs.io/en/latest/config-webapp.html)

#### Carbon Daemons
Please see the official [docs](https://graphite.readthedocs.io/en/latest/carbon-daemons.html)

#### Whisper
Please see the official [docs](https://graphite.readthedocs.io/en/latest/whisper.html)