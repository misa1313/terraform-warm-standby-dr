##########################################################################
# IAM profile 
##########################################################################

resource "aws_iam_role" "webserver_role" {
  name = "webserver_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid": ""
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com" 
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "apache-main-profile" {
  name = "apache-main-profile"

  role = aws_iam_role.webserver_role.name
}

resource "aws_iam_policy" "s3_session_manager_policy" {
  name = "S3SessionManagerPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::apache-bucket-07/*"  
      },
      {
        Action = "ssm:StartSession",
        Effect = "Allow",
        Resource = "*"  
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "webserver_policy_attachment" {
  policy_arn = aws_iam_policy.s3_session_manager_policy.arn
  role       = aws_iam_role.webserver_role.name
}


##########################################################################
# IAM for Cloudwatch 
##########################################################################

data "aws_iam_policy_document" "cw-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cw-iam-role" {
  name               = "cw-iam-role"
  assume_role_policy = data.aws_iam_policy_document.cw-assume-role.json
}

data "aws_iam_policy_document" "cw-iam-policy-document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"] #log-group
  }
}

resource "aws_iam_role_policy" "cw-iam-role-policy" {
  name   = "cw-iam-role-policy"
  role   = aws_iam_role.cw-iam-role.id
  policy = data.aws_iam_policy_document.cw-iam-policy-document.json
}