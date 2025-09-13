# Credentials for EBS-CSI-DRIVER

data "aws_secretsmanager_secret" "aws-credentials" {
  arn = "arn:aws:secretsmanager:${var.REGION}:${var.ACCOUNT}:secret:${var.CredSecret}"
}

data "aws_secretsmanager_secret" "ebs-credentials" {
  arn = "arn:aws:secretsmanager:${var.REGION}:${var.ACCOUNT}:secret:${var.EbsCredSecret}"
}

data "aws_secretsmanager_secret_version" "ebs-csi-secret" {
  secret_id = data.aws_secretsmanager_secret.ebs-credentials.id
}
