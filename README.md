# Cloudprem Infrastructure Parameters

This repository contains the configuration parameters for the Cloudprem infrastructure deployed via our [CodePipeline configuration](https://github.com/Dozuki/Cloudprem). Each directory represents one environment (e.g. development) and contains parameters such as the version of the infrastructure and the inputs for the Terraform stack.

## Usage
This configuration repository is meant to be used as an upstream for your own config repo. To get started you can fork 
this repo to your own source control and make changes to the existing environments or add new ones. You can have 1 of 
each environment per region. 

By default, when deploying our CodePipeline solution using the link above we pre-fill this repository's address as your
config repo but this is not recommended for production deployments as you will not have control over the configuration
or version of your infrastructure. It's much better to fork a copy and use that repository address instead during that setup 
process. (See `Module Config & Updating` below for upgrade instructions)

## Folder Structure
This repository is broken down into the following sections:
* account
   * region
      * environment
         * module

At each level a configuration file exists that sets variables for that level.

### Account
While we support any number of accounts _this_ folder structure provides an example of one
account as you can see by the [account.hcl](./account.hcl) file. If your usage requires multiple accounts
you can simply create folders related to your different accounts, put an `account.hcl` file inside each one
and then copy the `us-east-1` folder and all it's contents into each account diretory. 
Modify the `account.hcl` file with the account number and the aws cli profile you will use
to access it.

An example directory structure with two accounts:

```
aws_account_1
  account.hcl
  us-east-1
    region.hcl
    development
      env.hcl
      app
        terragrunt.hcl
      compute
        terragrunt.hcl
      network
        terragrunt.hcl
      storage
        terragrunt.hcl
    qa
      env.hcl
      app
        terragrunt.hcl
      compute
        terragrunt.hcl
      network
        terragrunt.hcl
      storage
        terragrunt.hcl
    production
      env.hcl
      app
        terragrunt.hcl
      compute
        terragrunt.hcl
      network
        terragrunt.hcl
      storage
        terragrunt.hcl
  
aws_account_2
  account.hcl
  us-east-1
    region.hcl
    development
      env.hcl
      app
        terragrunt.hcl
      compute
        terragrunt.hcl
      network
        terragrunt.hcl
      storage
        terragrunt.hcl
    qa
      env.hcl
      app
        terragrunt.hcl
      compute
        terragrunt.hcl
      network
        terragrunt.hcl
      storage
        terragrunt.hcl
    production
      env.hcl
      app
        terragrunt.hcl
      compute
        terragrunt.hcl
      network
        terragrunt.hcl
      storage
        terragrunt.hcl
```

An example `account.hcl` file:
```hcl
locals {
  aws_account_id = "012345678"
  aws_profile    = "default"
}
```

This configuration will be used with the generated provider blocks to lock down access to the specified
account number. The profile is unused in CodePipeline deployments.

### Region
As an example the `us-east-1` region has a config file `region.hcl` inside the `us-east-1` folder
that looks like this:

```hcl
locals {
  aws_region = "us-east-1"
}
```
This `aws_region` variable should be edited to reflect the aws region if any new regions are added. Adding a new region is
as simple as creating a new region folder at the same directory level and naming it.

An example directory structure with two regions:
```
us-east-1
  region.hcl
  development
    env.hcl
    app
      terragrunt.hcl
    compute
      terragrunt.hcl
    network
      terragrunt.hcl
    storage
      terragrunt.hcl
  qa
    env.hcl
    app
      terragrunt.hcl
    compute
      terragrunt.hcl
    network
      terragrunt.hcl
    storage
      terragrunt.hcl
  production
    env.hcl
    app
      terragrunt.hcl
    compute
      terragrunt.hcl
    network
      terragrunt.hcl
    storage
      terragrunt.hcl
  
us-west-2
  region.hcl
  development
    env.hcl
    app
      terragrunt.hcl
    compute
      terragrunt.hcl
    network
      terragrunt.hcl
    storage
      terragrunt.hcl
  qa
    env.hcl
    app
      terragrunt.hcl
    compute
      terragrunt.hcl
    network
      terragrunt.hcl
    storage
      terragrunt.hcl
  production
    env.hcl
    app
      terragrunt.hcl
    compute
      terragrunt.hcl
    network
      terragrunt.hcl
    storage
      terragrunt.hcl
```

### Environment
Similarly to account and region, this level has an `env.hcl` file that specifies input variables for the
individual environments. To see a full list of the variables available refer to the `env.hcl` file inside 
any of the environment folders. All available variables are listed with descriptions and defaults.

The defaults included here are 3 separate environments:
* development
   * A quickly deployed environment with all data protection and high availability disabled.
   * Takes ~30 minutes to boot
* qa
   * Same as development but with a different environment name.
   * Takes ~30 minutes to boot
* production
   * All data protections and high availability options enabled. 
     * **Note:** This stack will require manual intervention to remove deletion protections before deleting. We specifically set it up so our infrastructure code could not accidentally delete core resources.
   * Takes ~45 minutes to boot
   
### Module Config & Updating
Inside the module the only configuration you should ever need to modify is the infrastructure release version, you can see an example of the configuration block here:
```hcl
terraform {
  source = "git::https://github.com/Dozuki/CloudPrem-Infra.git//cloudprem/app?ref=v2.0"
}
```
At the end of the `source=` string you'll see a `?ref=` parameter. This points to a specific release of our infrastructure code. If you want to upgrade your environment
to the latest infrastructure you'll need to modify this parameter to point to the desired release tag. See our main infrastructure [release page](https://github.com/Dozuki/Cloudprem-Infra/releases) to get
a list of the available tags. By default, this repo will always be updated to point to the latest available version but once you fork the repo you may need to make
these changes manually going forward.