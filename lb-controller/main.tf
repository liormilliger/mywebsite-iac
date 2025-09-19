# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     principals {
#       type        = "Federated"
#       identifiers = [var.oidc_provider_arn]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(var.oidc_provider_arn, ".*oidc-provider/", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#     }
#   }
# }

# resource "aws_iam_role" "aws_load_balancer_controller" {
#   name               = "${var.cluster_name}-alb-controller-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
# }

# resource "aws_iam_policy" "aws_load_balancer_controller" {
#   name        = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
#   description = "Policy for the AWS Load Balancer Controller"
#   policy      = file("${path.module}/iam_policy.json")
# }

# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
#   policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
#   role       = aws_iam_role.aws_load_balancer_controller.name
# }

# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.7.1"

#   values = [
#     yamlencode({
#       clusterName = var.cluster_name
#       awsVpcID    = var.vpc_id
#       serviceAccount = {
#         create = true
#         name   = "aws-load-balancer-controller"
#         annotations = {
#           "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
#         }
#       }
#     })
#   ]
# }
