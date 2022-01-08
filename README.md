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
* region
  * environment
    * module

At each level a configuration file exists that sets variables for that level.

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
us-east-1/
├── region.hcl
├── development/
│   ├── env.hcl
│   ├── logical/
│   │   └── terragrunt.hcl
│   └── physical/
│       └── terragrunt.hcl
├── qa/
│   ├── env.hcl
│   ├── logical/
│   │   └── terragrunt.hcl
│   └── physical/
│       └── terragrunt.hcl
└── production/
    ├── env.hcl
    ├── logical/
    │   └── terragrunt.hcl
    └── physical/
        └── terragrunt.hcl
us-west-2/
├── region.hcl
├── development/
│   ├── env.hcl
│   ├── logical/
│   │   └── terragrunt.hcl
│   └── physical/
│       └── terragrunt.hcl
├── qa/
│   ├── env.hcl
│   ├── logical/
│   │   └── terragrunt.hcl
│   └── physical/
│       └── terragrunt.hcl
└── production/
    ├── env.hcl
    ├── logical/
    │   └── terragrunt.hcl
    └── physical/
        └── terragrunt.hcl
```

### Environment
Similarly to region, this level has an `env.hcl` file that specifies input variables for the
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
  source = "git::https://github.com/Dozuki/CloudPrem-Infra.git//cloudprem/physical?ref=v2.5"
}
```
At the end of the `source=` string you'll see a `?ref=` parameter. This points to a specific release of our infrastructure code. If you want to upgrade your environment
to the latest infrastructure you'll need to modify this parameter to point to the desired release tag. See our main infrastructure [release page](https://github.com/Dozuki/Cloudprem-Infra/releases) to get
a list of the available tags. By default, this repo will always be updated to point to the latest available version but once you fork the repo you may need to make
these changes manually going forward.