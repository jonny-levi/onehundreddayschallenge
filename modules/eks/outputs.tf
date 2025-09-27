output "eks_cluster_ca" {
  value = aws_eks_cluster.example.certificate_authority

}
output "kubeconfig" {
  value = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.example.endpoint}
    certificate-authority-data: ${aws_eks_cluster.example.certificate_authority[0].data}
  name: ${aws_eks_cluster.example.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.example.name}
    user: ${data.aws_eks_cluster_auth.example.name}
  name: ${aws_eks_cluster.example.name}
current-context: ${aws_eks_cluster.example.name}
kind: Config
preferences: {}
users:
- name: ${data.aws_eks_cluster_auth.example.name}
  user:
    token: ${data.aws_eks_cluster_auth.example.token}
EOT
}
# output "eks_instances_ids" {
#   value = aws_eks_node_group.example.
# }
