output "vpc_id" {
  value = aws_vpc.resume_vpc.id
}

output "bucket_id" {
  value = aws_s3_bucket.resume_assets.id
}

output "bucket_arn" {
  value = aws_s3_bucket.resume_assets.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.resume_assets.bucket_regional_domain_name
}

output "private_subnet_ids" {
  value = aws_subnet.resume_private[*].id
}

output "visitor_table_name" {
  description = "Visitor count table name"
  value       = aws_dynamodb_table.visitor_count.name
}

output "comment_table_name" {
  description = "Comments table name"
  value       = aws_dynamodb_table.resume_comments.name
}

