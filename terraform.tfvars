### GENERAL ###
REGION = "us-east-1"
ACCOUNT = "704505749045"

### VPC ###
vpc_name = "liorm-website-network"
# availability_zone = ""
# az_name = ""
vpc_cidr_block = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.13.0/24", "10.0.24.0/24"]
public_subnet_cidrs = ["10.0.31.0/24", "10.0.42.0/24"]

### CLUSTER ###
# EbsCredSecret = "aws-credentials-OWbgXs" //
EbsCredSecret = "website-admin-credentials-ptXO57"
# CredSecret = "aws-credentials-OWbgXs"
CredSecret = "website-admin-credentials-ptXO57"
cluster_name = "liorm-website"
cluster_version = "1.33"



### NODE GROUP ###
node_group_name = "liorm-node-group"
capacity_type = "ON_DEMAND"
# instance_types = ["t3.medium", "t3a.medium"] //~0.04 per hour
# instance_types = ["t3.large", "c5.large"] //~0.09 per hour
instance_types = ["t3.xlarge"] //~0.17 per hour
# instance_types = ["t3.2xlarge", "c5.2xlarge"] //~0.34 per hour
max_size = 4
desired_size = 3
node_name = "liorm-website-node"

