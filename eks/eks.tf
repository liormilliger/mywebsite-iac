resource "aws_iam_role" "eks-cluster-iam-role" {
  name = "${var.cluster_name}-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    provisioned_by = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-iam-role.name
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster-iam-role.arn
  
  tags = {
    provisioned_by = "Terraform"
  }

  lifecycle {
    ignore_changes = [tags]
  }

  vpc_config {
    subnet_ids = [
      local.private-us-east-1a-id,
      local.private-us-east-1b-id,
      local.public-us-east-1a-id,
      local.public-us-east-1b-id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-cluster-policy]
}