get_deployment_resources.sh is deployed to EC2 instances in usr/local/bin and user both during the packer build and  when the AMI is launched to get resources from a private  bucket. The bucket is managed by terragrunt and exists is created for each account.

The "packer_access" IAM profile grants packer temporaray build instances access to the bucket.

thant profile is managed by this module and caalled from the  live repo:

  source = "git::ssh://git@stash.imprivata.com:7999/devops/terragrunt-cpi-modules.git//iam/ec2_instance_profile?ref=v0.0.36"


