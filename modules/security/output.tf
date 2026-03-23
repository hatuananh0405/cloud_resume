output "oac_id" {
  description = "CloudFront Origin Access Control ID"
  value       = aws_cloudfront_origin_access_control.resume_oac.id
}

output "lambda_sg_id" {
  description = "Lambda security group ID"
  value       = aws_security_group.lambda_sg.id
}

output "lambda_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_exec_role.arn
}