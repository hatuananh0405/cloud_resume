
variable "region" {
  description = "AWS Region triển khai dự án"
  type        = string
}

variable "bucket_name" {
  description = "Tên S3 Bucket (phải là duy nhất toàn cầu)"
  type        = string
}

# Thêm biến này
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}