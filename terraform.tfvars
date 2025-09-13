### GENERAL ###
REGION = "us-east-1"
ACCOUNT = "704505749045"

### VPC ###
vpc_name = "liorm-webapp"
# availability_zone = ""
# az_name = ""
vpc_cidr_block = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

### CLUSTER ###
EbsCredSecret = "aws-credentials-OWbgXs"
CredSecret = "aws-credentials-OWbgXs"
cluster_name = "liorm-webapp"
cluster_version = "1.33"

### NODE GROUP ###
node_group_name = "liorm-node-group"
capacity_type = "ON_DEMAND"
instance_types = ["t3.small", "t3a.small", "t2.small"]
max_size = 2 
desired_size = 1
node_name = "liorm-webapp"



