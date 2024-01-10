provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "assume_role"
  region = "eu-west-2"
  assume_role {
    role_arn = aws_iam_role.assume_role.arn
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "assume_role" {
  name             = "AssumedRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

module "lambda" {
  source = "./rds/"
  # Add other Lambda configuration options as needed
}

