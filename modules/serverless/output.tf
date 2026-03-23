output "cloudfront_domain_name" {
  description = "Tên miền của CloudFront để truy cập web"
  value       = aws_cloudfront_distribution.resume_cdn.domain_name 
}

output "cloudfront_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.resume_cdn.arn
}

output "api_url" {
  description = "Endpoint của API Gateway để Frontend gọi vào"
  value       = aws_apigatewayv2_api.resume_api.api_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.resume_lambda_repo.repository_url
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.resume_notifications.arn
}