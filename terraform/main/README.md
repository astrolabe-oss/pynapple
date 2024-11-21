### Local Setup

#### Prereqs cli programs:
* kubectl
* aws 
* OpenTofu >= 1.9 (becuae we are using it's `for_each` for `provider` functionality)

## How to deploy it
1. Create SSH key pair in AWS
   1. Name it `pynapple_key_pair` if you do not wish to pass the `aws_key_pair_name` in as tf var
   1. Download/save the `.pem` file
1. Create terraform.tfvars file
   1. `cp terraform.example.tfvars terraform.tfvars`
   2. Replace `aws_key_pair_name`
   3. Replace `aws_account_id`
1. Deploy Baseline Resources (Mostly the ECR Repo and tarball deploy buckets need to be created)
```bash
   terraform apply var="deploy_infra=true" var="deploy_app=false"
```
1. Deploy application docker images and tarballs
```bash
  ../build_tarball_deploy_ec2.sh
  ../build_docker_deploy_eks.sh
```
1. Deploy Remaining Resources
```bash
   terraform apply var="deploy_infra=true" var="deploy_app=true"
```
