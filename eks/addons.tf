################################################################################
# IAM Role for EBS CSI Driver Service Account
################################################################################

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${aws_eks_cluster.eks-cluster.name}-ebs-csi-driver-role"

  # Trust policy that allows the Kubernetes service account to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            # Condition to only allow the specific service account to assume this role.
            "${replace(aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${aws_eks_cluster.eks-cluster.name}-ebs-csi-driver-role"
  }
}

################################################################################
# IAM Policy Attachment for EBS CSI Driver
################################################################################

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  # AWS managed policy with the required permissions for the EBS CSI driver.
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################################################################
# EKS Add-on for AWS EBS CSI Driver
################################################################################

resource "aws_eks_addon" "ebs_csi_driver" {
  # Ensure the IAM role and policy are created before the add-on.
  depends_on = [aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment]

  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "aws-ebs-csi-driver"

  # Link the add-on to the IAM role created above.
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

  tags = {
    "eks_addon" = "ebs-csi-driver"
  }
}
