resource "aws_iam_role" "cluster" {
  name = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = var.default_tags
}

resource "aws_iam_role" "eks_node_role" {
  name = "node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}


resource "aws_iam_role_policy_attachment" "example-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_role.name
}



resource "aws_eks_cluster" "example" {
  name = var.eks_cluster_name

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids = var.eks_private_subnets
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy, aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController
  ]
  tags = var.default_tags
}

data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.example.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_access_entry" "example" {
  cluster_name  = aws_eks_cluster.example.name
  principal_arn = "arn:aws:iam::659797033228:user/admin" #aws_iam_user.my_user.arn
  type          = "STANDARD"                             # STANDARD | SYSTEM
}

resource "aws_eks_access_policy_association" "example" {
  cluster_name  = aws_eks_cluster.example.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = aws_eks_access_entry.example.principal_arn # your IAM user
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "example_AmazonEKSClusterAdminPolicy" {
  cluster_name  = aws_eks_cluster.example.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.example.principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.eks_private_subnets
  instance_types  = var.instance_types
  disk_size       = var.instance_disk_size
  ami_type        = var.instances_ami_type # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type   = "ON_DEMAND"
  scaling_config {
    desired_size = var.desired_number_of_ec2eks_instances
    max_size     = var.max_number_of_ec2eks_instances
    min_size     = var.min_number_of_ec2eks_instances

  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = merge(var.default_tags, { Name = "eks-node" })
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "aws-ebs-csi-driver"
}


provider "kubernetes" {
  host                   = aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
}

# resource "kubernetes_storage_class" "gp3" {
#   metadata {
#     name = "gp3"
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" = "true"
#     }
#   }

#   storage_provisioner = "kubernetes.io/aws-ebs"

#   parameters = {
#     type      = "gp3"
#     fsType    = "ext4"
#     encrypted = "true"
#   }

#   allow_volume_expansion = true
#   volume_binding_mode    = "WaitForFirstConsumer"
# }

# EKS Node Security Group
# resource "aws_security_group" "eks_nodes" {
#   name        = "node-sg"
#   description = "Security group for all nodes in the cluster"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name                             = "node-sg"
#     "kubernetes.io/cluster/-cluster" = "owned"
#   }
# }

# resource "aws_security_group_rule" "nodes_internal" {
#   description              = "Allow nodes to communicate with each other"
#   from_port                = 0
#   protocol                 = "-1"
#   security_group_id        = aws_security_group.eks_nodes.id
#   source_security_group_id = aws_security_group.eks_nodes.id
#   to_port                  = 65535
#   type                     = "ingress"
# }

# resource "aws_security_group_rule" "nodes_cluster_inbound" {
#   description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#   from_port                = 1025
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_nodes.id
#   source_security_group_id = aws_security_group.eks_cluster.id
#   to_port                  = 65535
#   type                     = "ingress"
# }
