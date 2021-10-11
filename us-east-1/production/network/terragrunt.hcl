locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/Dozuki/CloudPrem-Infra.git//cloudprem/network?ref=v2.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

retryable_errors = [
  "(?s).*error waiting for Route in Route Table.*waiting for state to become 'ready'.*",
  "(?s).*timeout while waiting for resource to be gone.*"
]

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

}