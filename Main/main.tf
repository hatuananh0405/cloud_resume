terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# 1. Module Networking
module "networking" {
  source       = "../modules/networking"
  bucket_name  = var.bucket_name
  aws_region   = var.aws_region
  lambda_sg_id = module.security.lambda_sg_id  # Thêm dòng này
}
module "security" {
  source         = "../modules/security"
  vpc_id         = module.networking.vpc_id
  bucket_id      = module.networking.bucket_id
  bucket_arn     = module.networking.bucket_arn
  cloudfront_arn = module.serverless.cloudfront_arn
}

module "serverless" {
  source               = "../modules/serverless"
  bucket_domain_name   = module.networking.bucket_domain_name
  oac_id               = module.security.oac_id
  lambda_role_arn      = module.security.lambda_role_arn
  private_subnet_ids   = module.networking.private_subnet_ids
  lambda_sg_id         = module.security.lambda_sg_id
  visitor_table_name   = module.networking.visitor_table_name
  comment_table_name   = module.networking.comment_table_name
}