# Creating IAM role for Master Node
resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy" {
  count = 3
  role  = aws_iam_role.cluster_role.name
  policy_arn = [
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonEKSVPCResourceController"
  ][count.index]
}

resource "aws_iam_role_policy_attachment" "node_role_additional_policy" {
  count = 2
  role  = module.eks_cluster.eks_managed_node_groups["node-group"].iam_role_name
  policy_arn = [
    "arn:${data.aws_partition.current.id}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ][count.index]
}