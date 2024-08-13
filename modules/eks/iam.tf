data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.eks_cluster_name}-iam-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
  assume_role_policy = jsonencode({
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "eks.amazonaws.com"
        }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "iam-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "iam-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks_cluster_role.name
}

#####

resource "aws_iam_role" "eks_node_role" {
  name = "${var.eks_node_group_name}-iam-role"

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

resource "aws_iam_role_policy_attachment" "iam-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "iam-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks_node_role.name
}


resource "aws_iam_role_policy_attachment" "iam-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks_node_role.name
}