# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  # --- BEGIN General Configuration --- #

  # Environment name to be appended to all resource names. Should be unique per region.
  # The length of the Environment value must be 6 characters or less.
  environment = "prod"

  # Additional identifier to be prepended to all resource names
  # Note: This variable can be set at stack creation via the cloudformation template. If you do set this variable here
  # be sure to set OverrideRepositoryParameters setting to 'false' when creating the pipeline stack in cloudformation.
  #
  #identifier = ""

  # The SSM parameter name that stores the Dozuki license file provided to you. If empty Terraform will attempt to get
  # the license from a parameter with name /{identifier}/dozuki/{environment}/license or
  # /dozuki/{environment}/license if identifier is not set.
  # Note: This variable is auto-populated via a parameter in the cloudformation stack creation. You should only set
  # this variable if you already have an SSM parameter setup for the dozuki license before stack creation.
  #
  #dozuki_license_parameter_name = ""

  # On fresh installs this variable specifies which sequence number to install. This sequence number must be available
  # to your customer account. If left blank or set to 0 (default) the latest sequence number available will be installed.
  #
  # Possible options: 0 - latest sequence number provided by Dozuki
  # Default: 0 (which will install latest sequence)
  #replicated_app_sequence_number = 0

  # This option will spin up additional infrastructure to support webhooks. This includes an external AWS managed Kafka
  # cluster as well as redis and mongodb deployed onto the kubernetes cluster. Webhooks must be enabled on your license
  # before you enable this.
  #
  # Possible options: true, false
  # Default: false
  #enable_webhooks = false

  # --- END General Configuration --- #

  # Specify whether data protection settings should be enabled for databases, s3 buckets, and compute clusters. This should
  # be set to true for production stacks and false for others. When set to true, databases will have deletion protection
  # enabled and will need to be manually disabled if you ever want to delete this stack.
  #
  # Possible options: true,false
  # Default: true
  #protect_resources = true

  # --- BEGIN Networking Configuration --- #
  # (Values below reflect defaults if unset)

  # The VPC ID to where we'll be deploying our resources. (If creating a new VPC leave this field and subnets blank).
  #
  # Default: ""
  #vpc_id = ""

  # The CIDR block for the VPC, should not need to change this unless you have exotic VPC configurations.
  #
  # Default: "172.16.0.0/16"
  #vpc_cidr = "172.16.0.0/16"

  # Should be true if you want to provision a highly available NAT Gateway across all of your private networks
  #
  # Possible options: true, false
  # Default: true
  #highly_available_nat_gateway = true

  # This CIDR will be allowed to connect to the app dashboard. This is where you upgrade to new versions as well as
  # view cluster status and start/stop the cluster. You probably want to lock this down to your company network CIDR,
  # especially if you chose 'true' for public access.
  #
  # Default: "0.0.0.0/0"
  #replicated_ui_access_cidr = "0.0.0.0/0"

  # This CIDR will be allowed to connect to Dozuki. If running a public site, use the default value. Otherwise you
  # probably want to lock this down to the VPC or your VPN CIDR."
  #
  # Default: "0.0.0.0/0"
  #app_access_cidr = "0.0.0.0/0"

  # Should the app and dashboard be accessible via a publicly routable IP and domain?
  #
  # Possible options: true, false
  # Default: true
  #public_access = true

  # --- END Networking Configuration --- #

  # --- BEGIN EKS & Worker Node Configuration --- #

  # The instance types for the spot fleet in the application's EKS worker node group.
  #
  # Possible options: any AWS ec2 instance types supported in your region
  # Default: ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
  #eks_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]

  # The amount of local storage (in gigabytes) to allocate to each kubernetes node. Keep in mind you will be billed for
  # this amount of storage multiplied by how many nodes you spin up (i.e. 50GB * 4 nodes = 200GB on your bill).
  # For production installations 50GB should be the minimum. This local storage is used as a temporary holding area for
  # uploaded and in-process assets like videos and images.
  #
  # Default: 50
  #eks_volume_size = 50

  # The minimum amount of nodes we will auto-scale to.
  #
  # Default: 2
  #eks_min_size = 2

  # The maximum amount of nodes we will auto-scale to.
  #
  # Default: 10
  #eks_max_size = 10

  # This is what the node count will start out as.
  #
  # Default: 3
  #eks_desired_capacity = 3

  # --- END EKS & Worker Node Configuration --- #

  # --- BEGIN Database and storage Options --- #

  # AWS KMS key identifier for S3 encryption. The identifier can be one of the following format: Key id, key ARN, alias
  # name or alias ARN
  #
  # Default: "alias/aws/s3"
  #s3_kms_key_id = ""

  # Whether to create the Dozuki S3 buckets or not. If this is set to false, you must specify the bucket names in the
  # variables below.
  #
  # Possible options: true, false
  # Default: true
  #create_s3_buckets = true

  # If you have existing data in S3 buckets you can specify them here. These should be left blank if creating a fresh
  # install. If setting these variables, be sure to set "create_s3_buckets" to false or these will be ignored.
  #
  #s3_objects_bucket = ""
  #s3_images_bucket = ""
  #s3_documents_bucket = ""
  #s3_pdfs_bucket = ""

  # AWS KMS key identifier for RDS encryption. The identifier can be one of the following format: Key id, key ARN,
  # alias name or alias ARN
  #
  # Default: "alias/aws/rds"
  #rds_kms_key_id = ""

  # We can seed the database from an existing RDS snapshot in this region. Type the snapshot identifier in this field
  # or leave blank to start with a fresh database. Note: If you *do* use a snapshot it's critical that during stack
  # updates you continue to include the snapshot identifier in this parameter. Clearing this parameter after using it
  # will cause AWS to spin up a new fresh DB and DELETE YOUR OLD ONE.
  #
  #rds_snapshot_identifier = ""

  # The instance type to use for your database. See this page for a breakdown of the performance and cost differences
  # between the different instance types:
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  #
  # Note: In some AWS regions they do not have m4 instances so you may need to switch to m5 and vice versa.
  # Default: "db.m4.large"
  #rds_instance_type = "db.m4.large"

  # If true we will tell RDS to automatically deploy and manage a highly available standby instance of your database.
  # Enabling this doubles the cost of the RDS instance but without it you are susceptible to downtime if the AWS
  # availability zone your RDS instance is in becomes unavailable.
  #
  # Possible options: true, false
  # Default: true
  #rds_multi_az = true

  # The initial size of the database storage allocated (in Gigabytes).
  #
  # Default: 100
  #rds_allocated_storage = 100

  # The maximum size to which AWS will scale the database storage (in Gigabytes).
  #
  # Default: 500
  #rds_max_allocated_storage = 500

  # The number of days to keep automatic database backups. Setting this value to 0 disables automatic backups.
  #
  # Default: 30
  #rds_backup_retention_period = 30

  # This option will spin up a BI slave of your master database and enable conditional replication (everything but the
  # mysql table will be replicated so you can have custom users).
  #
  # Possible options: true, false
  # Default: false
  #enable_bi = false

  # The compute and memory capacity of the nodes in the Cache Cluster
  #
  # Possible options: Any supported AWS ElastiCache instance type in your region
  # Default: "cache.t2.small"
  #cache_instance_type = "cache.t2.small"

  # --- END Database and storage Options --- #
}
