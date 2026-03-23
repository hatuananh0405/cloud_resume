#Bước 1:tao repository ECR
terraform apply -target=module.serverless.aws_ecr_repository.resume_lambda_repo

#Bước 2:build image va push len ECR
docker build --platform linux/amd64 -t resume-lambda-repo .
# 1. Đăng nhập lại (Thay ID 358920420597 nếu cần)
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 358920420597.dkr.ecr.ap-southeast-1.amazonaws.com

# 2. Gắn thẻ (Tag) cho bản build mới nhất
docker tag resume-lambda-repo:latest 358920420597.dkr.ecr.ap-southeast-1.amazonaws.com/resume-lambda-repo:latest

# 3. Đẩy lên ECR (Nó sẽ ghi đè lên bản lỗi cũ)
docker push 358920420597.dkr.ecr.ap-southeast-1.amazonaws.com/resume-lambda-repo:latest


#Bước 3:deploy all resources
terraform plan --var-file "terraform.tfvars"
terraform apply --var-file "terraform.tfvars"


#Bước 4:sync code len S3 va invalidate CloudFront cache

# Upload file HTML, CSS, JS
aws s3 cp index.html s3://resume-cv-intern-tanh-2026/
aws s3 cp style.css s3://resume-cv-intern-tanh-2026/
aws s3 cp script.js s3://resume-cv-intern-tanh-2026/

# Upload ảnh và file PDF
aws s3 cp profile.jpg s3://resume-cv-intern-tanh-2026/
aws s3 cp clf.jpg s3://resume-cv-intern-tanh-2026/
aws s3 cp dva.jpg s3://resume-cv-intern-tanh-2026/
aws s3 cp CV_HaTuanAnh.pdf s3://resume-cv-intern-tanh-2026/

aws s3 sync . s3://resume-cv-intern-tanh-2026 \
    --exclude ".terraform/*" \
    --exclude "terraform.tfstate*" \
    --exclude ".git/*" \
    --region ap-southeast-1



    aws cloudfront create-invalidation \
    --distribution-id E17V6TVIGLK6LJ \
    --paths "/*" \
    --region ap-southeast-1


MSYS_NO_PATHCONV=1 aws cloudfront create-invalidation --distribution-id E17V6TVIGLK6LJ --paths "/*" --region ap-southeast-1


terraform init
terraform apply -target=module.serverless.aws_ecr_repository.resume_lambda_repo
terraform plan --var-file "terraform.tfvars"
terraform apply --var-file "terraform.tfvars"

#Clear resources:
terraform destroy --var-file "terraform.tfvars"

aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 358920420597.dkr.ecr.ap-southeast-1.amazonaws.com



<img src="clf.jpg" alt="AWS Certified Cloud Practitioner">
<img src="dva.jpg" alt="AWS Certified Developer - Associate">


aws s3 ls s3://resume-cv-intern-tanh-2026/ --region ap-southeast-1


aws cloudfront create-invalidation --distribution-id E17V6TVIGLK6LJ --paths "/*" --region ap-southeast-1