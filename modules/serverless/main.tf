# 1. CloudFront Distribution
resource "aws_cloudfront_distribution" "resume_cdn" {
  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = var.oac_id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  viewer_certificate { cloudfront_default_certificate = true }
restrictions {
  geo_restriction {
    restriction_type = "none" # Hoặc "whitelist"/"blacklist" tùy nhu cầu
  }
}
  tags = { Name = "resume-cdn" }
}



# 3. API Gateway để trang web gọi vào Lambda
resource "aws_apigatewayv2_api" "resume_api" {
  name          = "resume-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.resume_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_counter.invoke_arn
}

resource "aws_apigatewayv2_route" "counter_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.resume_api.id
  name        = "$default"
  auto_deploy = true
}

# 1. Tạo SNS Topic
resource "aws_sns_topic" "resume_notifications" {
  name = "resume-contact-topic"
}

# 2. Đăng ký nhận email (Subscription)
resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.resume_notifications.arn
  protocol  = "email"
  endpoint  = "hatuananh040504n@gmail.com" # Thay bằng mail thật của bạn
}

# 3. Thêm Route POST cho API Gateway
resource "aws_apigatewayv2_route" "comment_route" {
  api_id    = aws_apigatewayv2_api.resume_api.id
  route_key = "POST /comment" # Nhận dữ liệu từ Form gửi lên
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}








resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resume_api.execution_arn}/*/*"
}


resource "aws_ecr_repository" "resume_lambda_repo" {
  name = "resume-lambda-repo"
}


resource "aws_lambda_function" "visitor_counter" {
  function_name = "resume-visitor-counter"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.resume_lambda_repo.repository_url}:latest"
  role          = var.lambda_role_arn
  timeout       = 30
  memory_size   = 128
  
  # dynamic "vpc_config" {
  #   for_each = length(var.private_subnet_ids) > 0 && var.lambda_sg_id != "" ? [1] : []
  #   content {
  #     subnet_ids         = var.private_subnet_ids
  #     security_group_ids = [var.lambda_sg_id]
  #   }
  # }
  
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.resume_notifications.arn
      VISITOR_TABLE = var.visitor_table_name
      COMMENT_TABLE = var.comment_table_name
    }
  }
}