resource "aws_iam_role" "liorm-node-group-role" {
  name = "liorm_node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "liorm-eks-csi-ebs-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "liorm-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "liorm-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "liorm-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_eks_node_group" "node-group" {
  cluster_name    = var.cluster_name
  version         = var.cluster_version
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.liorm-node-group-role.arn

  subnet_ids = [
    local.public-us-east-1a-id,
    local.public-us-east-1b-id
  ]

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
    nodeName = var.node_name
  }
  
  launch_template {
    name    = aws_launch_template.naming-nodes.name
    version = aws_launch_template.naming-nodes.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.liorm-eks-worker-node-policy,
    aws_iam_role_policy_attachment.liorm-eks-cni-policy,
    aws_iam_role_policy_attachment.liorm-ec2-container-registry-read-only,
    aws_eks_cluster.eks-cluster,
  ]

  tags = {
    provisioned_by = "Terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# Naming Nodes
resource "aws_launch_template" "naming-nodes" {
  name = "naming-nodes"
  # image_id = "ami-0d64bb532e0502c46" ##ubuntu 22.04 LTS for eu-west-1
  tag_specifications {
    resource_type = "instance"
    
    tags = {
      Name = var.node_name
    }
  }
}
