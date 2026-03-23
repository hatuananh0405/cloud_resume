# --- Storage & Database (Trang web tĩnh & Bộ đếm) ---

resource "aws_s3_bucket" "resume_assets" {
  bucket = var.bucket_name
  tags   = { Name = "resume-assets-bucket" }
}

resource "aws_dynamodb_table" "visitor_count" {
  name         = "VisitorCount"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = { Name = "resume-visitor-counter-db" }
}

# --- VPC & Connectivity (Hạ tầng mạng) ---

resource "aws_vpc" "resume_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "Cloud-Resume-VPC" }
}

resource "aws_internet_gateway" "resume_igw" {
  vpc_id = aws_vpc.resume_vpc.id
  tags   = { Name = "resume-igw" }
}

# Public Subnets (Dùng count để viết code gọn hơn)
resource "aws_subnet" "resume_public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.resume_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "resume-public-${count.index + 1}" }
}

# Private Subnets
resource "aws_subnet" "resume_private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.resume_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags                    = { Name = "resume-private-${count.index + 1}" }
}

# --- Routing (Định tuyến) ---

resource "aws_route_table" "resume_public_rt" {
  vpc_id = aws_vpc.resume_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.resume_igw.id
  }
  tags = { Name = "resume-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.resume_public[count.index].id
  route_table_id = aws_route_table.resume_public_rt.id
}

resource "aws_route_table" "resume_private_rt" {
  vpc_id = aws_vpc.resume_vpc.id
  tags   = { Name = "resume-private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.resume_private[count.index].id
  route_table_id = aws_route_table.resume_private_rt.id
}

# --- VPC Endpoint (Giải pháp thay thế NAT Gateway cho DynamoDB) ---

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.resume_vpc.id
  service_name      = "com.amazonaws.ap-southeast-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.resume_private_rt.id]
  tags              = { Name = "resume-dynamodb-endpoint" }
}

# Thêm bảng DynamoDB mới để lưu feedback
resource "aws_dynamodb_table" "resume_comments" {
  name         = "ResumeComments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "comment_id" # Khóa chính là ID duy nhất của mỗi nhận xét

  attribute {
    name = "comment_id"
    type = "S"
  }

  tags = { Name = "resume-comments-db" }
}


# VPC endpoint cho SNS (Interface)

resource "aws_vpc_endpoint" "sns" {
  vpc_id              = aws_vpc.resume_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.resume_private[*].id
  security_group_ids  = var.lambda_sg_id != "" ? [var.lambda_sg_id] : []
  private_dns_enabled = true
  
  tags = {
    Name = "resume-sns-endpoint"
  }
}