# # Auto Scaling 그룹 정보 가져오기
# data "aws_autoscaling_group" "example" {
#   name = "eks-001109-eks-nodegroup-b0c8a5e2-0e1d-d008-3342-2ac26adfae8c"
# }

# # 보안 그룹 ID 출력
# output "node_security_group_ids" {
#   value = data.aws_autoscaling_group.example.security_groups
# }