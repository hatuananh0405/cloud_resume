variable "bucket_domain_name" {
  type = string
}

variable "oac_id" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "lambda_sg_id" {
  description = "Security group ID for Lambda"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda VPC"
  type        = list(string)
  default     = []
}

variable "visitor_table_name" {
  description = "Visitor count table name"
  type        = string
}

variable "comment_table_name" {
  description = "Comments table name"
  type        = string
}