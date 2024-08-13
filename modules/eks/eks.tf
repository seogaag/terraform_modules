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


# ## Security Group
# resource "aws_security_group" "sg_eks" {
#   vpc_id = var.vpc_id
  
#   dynamic "ingress" {
#     for_each = ["tcp", "udp", "icmp"]
#     content {
#       from_port = 0
#       to_port = 0
#       protocol = ingress.value
#       cidr_blocks = var.sg_cidr_blocks
#     }

#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "aws_eks_node_group" "eks_nodegroup" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_node_group_name
  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = var.node_sub_ids
  instance_types = var.node_instance_types
  disk_size = var.node_disk_size

  scaling_config {
    desired_size = 2
    max_size = 5
    min_size = 1
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


