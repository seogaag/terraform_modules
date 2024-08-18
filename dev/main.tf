# provider "aws" {
#   region = "ap-southeast-4"
# }

module "vpc" {
  source = "../modules/vpc"
  region = "ap-south-1"
  vpc_cidr = "10.0.10.0/24"
  vpc_name = "vpc-001109-test"
  subnet_names = ["sub-001109-pub-a", "sub-001109-pub-c",
                    "sub-001109-prv-nat-a", "sub-001109-prv-nat-c",
                    "sub-001109-prv-a", "sub-001109-prv-c"]
  igw_name = "igw-001109"
  ngw_names = ["ngw-001109-a", "ngw-001109-c"]

}


# module "eks_sg" {
#   source = "../modules/security-group"

#   vpc_id = module.vpc.vpc_id
#   user_name = "001109"
#   service_name = "eks"


# }

# module "eks" {
#   source = "../modules/eks"
  
#   vpc_id = module.vpc.vpc_id
#   eks_cluster_name = "001109-eks-cluster"
#   eks_node_group_name = "001109-eks-nodegroup"
#   eks_sub_ids = [module.vpc.sub_pub_a_id, module.vpc.sub_pub_c_id, module.vpc.sub_prv_nat_a_id, module.vpc.sub_prv_nat_c_id]
#   eks_security_groups_ids = [module.eks_sg.security_group_id, module.eks_sg.security_group_id]

#   node_sub_ids = [module.vpc.sub_pub_a_id, module.vpc.sub_pub_c_id]
#   node_disk_size = 100
# }

# module "instance" {
#   source = "../modules/instance"

#   ec2_name = "EC2-bastionhost"
#   ami_id = "ami-0790a5dc816e4a98f"
#   associate_public_ip_address = true
#   instance_type = "t3.micro"

#   vpc_id = module.vpc.vpc_id
#   subnet_id = module.vpc.sub_pub_a_id

#   keypair_name = "KEYPAIR-001109-H"
#   ec2_volume_size = 20
#   user_data = file("../source/bastionhost.sh")
  
#   ec2_security_group_ids = [ module.eks_sg.security_group_id ]
# }

# resource "aws_security_group_rule" "allow_all" {
#   type        = "ingress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]

#   security_group_id = "sg-05b943b663fbbd280"
# }