# ECR Repositories
resource "aws_ecr_repository" "this" {
  count = length(var.ecr_repository_names)

  name                 = var.ecr_repository_names[count.index]
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = var.ecr_repository_names[count.index]
  }
}

# ECR Lifecycle Policy (Keep last 10 images)
resource "aws_ecr_lifecycle_policy" "this" {
  count = length(var.ecr_repository_names)

  repository = aws_ecr_repository.this[count.index].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# IAM Role for ECR access from EKS (for use with IRSA)
resource "aws_iam_role" "eks_ecr_role" {
  name = "${var.project_name}-eks-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", ""):aud" = "sts.amazonaws.com"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", ""):sub" = "system:serviceaccount:bbhealthapp:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-eks-ecr-role"
  }
}

# ECR Access Policy
resource "aws_iam_policy" "eks_ecr_policy" {
  name        = "${var.project_name}-eks-ecr-policy"
  description = "Policy for EKS pods to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy_attachment" {
  policy_arn = aws_iam_policy.eks_ecr_policy.arn
  role       = aws_iam_role.eks_ecr_role.name
}

# IAM Role for CloudWatch Logs (for application logs)
resource "aws_iam_role" "eks_cloudwatch_role" {
  name = "${var.project_name}-eks-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", ""):aud" = "sts.amazonaws.com"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", ""):sub" = "system:serviceaccount:bbhealthapp:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-eks-cloudwatch-role"
  }
}

# CloudWatch Logs Policy
resource "aws_iam_policy" "eks_cloudwatch_policy" {
  name        = "${var.project_name}-eks-cloudwatch-policy"
  description = "Policy for EKS pods to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cloudwatch_policy_attachment" {
  policy_arn = aws_iam_policy.eks_cloudwatch_policy.arn
  role       = aws_iam_role.eks_cloudwatch_role.name
}

# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  tags = {
    Name = "${var.cluster_name}-logs"
  }
}
