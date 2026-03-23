
output "api_endpoint" {
  value = module.serverless.api_url # Đảm bảo 'serverless' khớp với tên module trong main.tf
}
output "website_url" {
  description = "Link CV của bạn"
  # Đảm bảo tên module (serverless) khớp với khai báo trong main.tf
  value = "https://${module.serverless.cloudfront_domain_name}"
}