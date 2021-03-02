# Pull in the backend and provider configurations from a root terragrunt.hcl file that you include in each child terragrunt.hcl:
include {
  path = find_in_parent_folders()
}

# Set the source to an immutable released version of the infrastructure module being deployed:
terraform {
  source = "git::https://github.com/Dozuki/CloudPrem-Infra.git//cloudprem?ref=v1.0"
}

# Configure input values for the specific environment being deployed:
inputs = {
  region = "us-west-2"

  environment = "prod"
}