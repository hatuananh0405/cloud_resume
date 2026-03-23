variable "vpc_id" {
  description = "ID của VPC nhận từ networking module"
  type        = string
}

variable "bucket_id" {
  description = "ID của S3 bucket"
  type        = string
}

variable "bucket_arn" {
  description = "ARN của S3 bucket"
  type        = string
}

variable "cloudfront_arn" {
  description = "ARN của CloudFront (sẽ nhận từ compute module sau)"
  type        = string
  default     = ""
}