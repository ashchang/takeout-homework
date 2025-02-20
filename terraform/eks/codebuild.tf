data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    } 
  }
}

data "aws_iam_policy_document" "eks_policy" {
  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codebuild_describe_policy" {
  name        = "codebuild_describe_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.eks_policy.json
}

resource "aws_iam_role" "example" {
  name               = "example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_policy2" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_describe_policy_attachment" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.codebuild_describe_policy.arn
}

resource "aws_codebuild_project" "example" {
  name          = "test-project"
  description   = "test_codebuild_project"
  build_timeout = 5
  service_role  = aws_iam_role.example.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "USER"
      value = var.docker_user
    }

    environment_variable {
      name  = "PASS"
      value = var.docker_pass
    }

    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }

    environment_variable {
      name  = "REGION"
      value = var.region
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/ashchang/gama.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "main"

  # vpc_config {
  #   vpc_id = module.vpc.default_vpc_id

  #   subnets = module.vpc.public_subnets

  #   security_group_ids = [
  #     module.eks_cluster.node_security_group_id
  #   ]
  # }
}