provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-example"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "eks" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = [
      "us-east-1a",
      "us-east-1b"
    ]
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = "cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.33"

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = data.aws_subnets.eks.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}
