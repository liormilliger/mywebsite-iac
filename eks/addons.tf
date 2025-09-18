# # Installing Kubernetes Networking Components

# resource "aws_eks_addon" "kube-proxy" {
#   cluster_name = aws_eks_cluster.blog-app.name
#   addon_name   = "kube-proxy"

#   depends_on = [aws_eks_node_group.cluster-nodes]
# }
# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.blog-app.name
#   addon_name   = "coredns"

#   depends_on = [aws_eks_node_group.cluster-nodes]
# }
# resource "aws_eks_addon" "vpc-cni" {
#   cluster_name = aws_eks_cluster.blog-app.name
#   addon_name   = "vpc-cni"

#   depends_on = [aws_eks_node_group.cluster-nodes]
# }

