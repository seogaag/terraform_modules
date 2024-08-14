resource "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    security_group_ids = var.eks_security_groups_ids
    subnet_ids = var.eks_sub_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.iam-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.iam-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "eks_nodegroup" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_node_group_name
  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = var.node_sub_ids
  instance_types = var.node_instance_types
  disk_size = var.node_disk_size

  scaling_config {
    desired_size = var.eks_node_scaling_config[0]
    max_size = var.eks_node_scaling_config[1]
    min_size = var.eks_node_scaling_config[2]
  }

  update_config {
    max_unavailable = 1
  }
  
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.iam-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.iam-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.iam-AmazonEC2ContainerRegistryReadOnly,
  ]
}


