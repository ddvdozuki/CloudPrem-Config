# Pull in the backend and provider configurations from a root terragrunt.hcl file that you include in each child terragrunt.hcl:
include {
  path = find_in_parent_folders()
}

# Set the source to an immutable released version of the infrastructure module being deployed:
terraform {
  source = "git::https://github.com/Dozuki/CloudPrem-Infra.git//cloudprem?ref=v1.4.1"
}

# Configure input values for the specific environment being deployed:
inputs = {
  region = "us-west-2"

  environment = "prod"

  # Specify whether this is a production stack or a development stack. Production stacks have data protection settings
  # enabled but will leave S3 buckets and RDS instances behind after a terraform delete operation.
  # Default is production.
  # Possible options: production,dev
  #
  #stack_type = "production"

  # --- BEGIN Networking Configuration --- #
  # (Values below reflect defaults if unset)

  # The VPC ID where we'll be deploying our resources. (If creating a new VPC leave this field and subnets blank).
  #
  #vpc_id = ""

  # The CIDR block for the VPC
  #
  #vpc_cidr = "172.16.0.0/16"

  # Should be true if you want to provision a highly available NAT Gateway across all of your private networks
  #
  #highly_available_nat_gateway = false

  # This CIDR will be allowed to connect to the app dashboard. This is where you upgrade to new versions as well as
  # view cluster status and start/stop the cluster. You probably want to lock this down to your company network CIDR,
  # especially if you chose 'true' for public access.
  #
  #replicated_ui_access_cidr = "0.0.0.0/0"

  # This CIDR will be allowed to connect to Dozuki. If running a public site, use the default value. Otherwise you
  # probably want to lock this down to the VPC or your VPN CIDR."
  #
  #app_access_cidr = "0.0.0.0/0"

  # Should the app and dashboard be accessible via a publicly routable IP and domain?
  #
  #public_access = true

  # --- END Networking Configuration --- #

  # --- BEGIN EKS & Worker Node Configuration --- #

  # The instance type of each node in the application's EKS worker node group.
  #
  #eks_instance_type = "t3.medium"

  # The amount of local storage (in gigabytes) to allocate to each kubernetes node. Keep in mind you will be billed for
  # this amount of storage multiplied by how many nodes you spin up (i.e. 50GB * 4 nodes = 200GB on your bill).
  # For production installations 50GB should be the minimum. This local storage is used as a temporary holding area for
  # uploaded and in-process assets like videos and images.
  #
  #eks_volume_size = 50

  # The minimum amount of nodes we will autoscale to.
  #
  #eks_min_size = 4

  # The maximum amount of nodes we will autoscale to.
  #
  #eks_max_size = 4

  # This is what the node count will start out as.
  #
  #eks_desired_capacity = 4


  # --- END EKS & Worker Node Configuration --- #

  # --- BEGIN Database and storage Options --- #

  # AWS KMS key identifier for S3 encryption. The identifier can be one of the following format: Key id, key ARN, alias
  # name or alias ARN
  #
  #s3_kms_key_id = "alias/aws/s3"

  # Whether to create the dozuki S3 buckets or not. If this is set to false, you must specify the bucket names in the
  # variables below.
  #
  #create_s3_buckets = true

  # If you have existing data in S3 buckets you can specify them here. These should be left blank if creating a fresh
  # install. If setting these variables, be sure to set "create_s3_buckets" to false or they will be ignored.
  #
  #s3_objects_bucket = ""
  #s3_images_bucket = ""
  #s3_documents_bucket = ""
  #s3_pdfs_bucket = ""

  # AWS KMS key identifier for RDS encryption. The identifier can be one of the following format: Key id, key ARN,
  # alias name or alias ARN
  #
  #rds_kms_key_id = "alias/aws/rds"

  # We can seed the database from an existing RDS snapshot in this region. Type the snapshot identifier in this field
  # or leave blank to start with a fresh database. Note: If you do use a snapshot it's critical that during stack
  # updates you continue to include the snapshot identifier in this parameter. Clearing this parameter after using it
  # will cause AWS to spin up a new fresh DB and delete your old one.
  #
  #rds_snapshot_identifier = ""

  # The instance type to use for your database. See this page for a breakdown of the performance and cost differences
  # between the different instance types:
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  #
  #rds_instance_type = "db.m4.large"

  # If true we will tell RDS to automatically deploy and manage a highly available standby instance of your database.
  # Enabling this doubles the cost of the RDS instance but without it you are susceptible to downtime if the AWS
  # availability zone your RDS instance is in becomes unavailable.
  #
  #rds_multi_az = true

  # The initial size of the database (GB)
  #
  #rds_allocated_storage = 100

  # The maximum size to which AWS will scale the database (GB).
  #
  #rds_max_allocated_storage = 500

  # The number of days to keep automatic database backups. Setting this value to 0 disables automatic backups.
  #
  #rds_backup_retention_period = 30

  # This option will spin up a BI slave of your master database and enable conditional replication (everything but the
  # mysql table will be replicated so you can have custom users).
  #
  #enable_bi = true

  # The compute and memory capacity of the nodes in the Cache Cluster
  #
  #cache_instance_type = "cache.t2.small"

  # --- END Database and storage Options --- #

  # --- BEGIN Bastion --- #

  # Setting this to true will spin up an EC2 instance and configure it for this environment for easy access to
  # RDS and EKS.
  #
  #enable_bastion = true

  # The instance type to use for the bastion host
  #
  #bastion_instance_type = "t3.micro"

  # --- END Bastion --- #

  # --- BEGIN General Configuration --- #

  # A name identifier to use as prefix for all the resources.
  # Note: This variable can be set at stack creation via the cloudformation template. If you do set this variable here
  # be sure to set OverrideRepositoryParameters setting to 'false' when creating the pipeline stack in cloudformation.
  #
  #identifier = ""

  # The SSM parameter name that stores the Dozuki license file provided to you. If empty Terraform will attempt to get
  # the license from a parameter with name /{identifier}/cloudprem/{environment}/license or
  # /cloudprem/{environment}/license if identifier is not set.
  # Note: This variable is auto-populated via a parameter in the cloudformation stack creation. You should only set
  # this variable if you already have an SSM parameter setup for the dozuki license before stack creation.
  #
  #dozuki_license_parameter_name = ""

  # On fresh installs this variable specifies which sequence number to install. This sequence number must be available
  # to your customer account. If left blank or set to 0 (default) the latest sequence number available will be installed.
  #
  #replicated_app_sequence_number = 0

  # This option will spin up additional infrastructure to support webhooks. This includes an external AWS managed Kafka
  # cluster as well as redis and mongodb deployed onto the kubernetes cluster.
  #
  #enable_webhooks = false

  # --- END General Configuration --- #
}