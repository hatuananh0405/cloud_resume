# 1. CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "resume_oac" {
  name                              = "resume-s3-oac"
  description                       = "OAC for Cloud Resume S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. S3 Bucket Policy (Chỉ cho phép CloudFront truy cập)
resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = var.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${var.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_arn
          }
        }
      }
    ]
  })
}

# 3. Security Group cho Lambda (Visitor Counter)
resource "aws_security_group" "lambda_sg" {
  name        = "resume-lambda-sg"
  description = "Security group for Visitor Counter Lambda"
  vpc_id      = var.vpc_id

  # Lambda chỉ cần gửi yêu cầu ra ngoài (egress) để gọi DynamoDB API
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "resume-lambda-sg" }
}

# 4. IAM Role cho Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "resume-lambda-executor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 5. Cấp quyền cho Lambda ghi log và truy cập DynamoDB
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_dynamo_policy" {
  name = "resume-lambda-dynamo-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
      Resource = "*" # Bạn có thể thu hẹp lại ARN của table sau
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_policy.arn
}

# Thêm quyền SNS Publish vào IAM Policy hiện có của Lambda
resource "aws_iam_policy" "lambda_sns_dynamo_policy" {
  name = "resume-lambda-sns-dynamo-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"] # Quyền ghi nhận xét mới
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]      # Quyền gửi mail qua SNS
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  role       = aws_iam_role.lambda_exec_role.name #
  policy_arn = aws_iam_policy.lambda_sns_dynamo_policy.arn
}


resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "LambdaSNSPublishPolicy"
  role = aws_iam_role.lambda_exec_role.id # Đảm bảo tên này khớp với Role hiện tại của bạn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = "arn:aws:sns:ap-southeast-1:358920420597:resume-contact-topic"
    }]
  })
}