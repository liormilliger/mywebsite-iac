# resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks-cluster-iam-role.name
# }

# resource "aws_iam_role_policy_attachment" "liorm-eks-csi-ebs-node-policy" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.liorm-node-group-role.name
# }

# resource "aws_iam_role_policy_attachment" "liorm-eks-worker-node-policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.liorm-node-group-role.name
# }

# resource "aws_iam_role_policy_attachment" "liorm-eks-cni-policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.liorm-node-group-role.name
# }

# resource "aws_iam_role_policy_attachment" "liorm-ec2-container-registry-read-only" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.liorm-node-group-role.name
# }