# Sử dụng AWS Lambda base image chính thức
FROM public.ecr.aws/lambda/python:3.11

# Copy requirements.txt và cài đặt dependencies
# (Bạn có thể bỏ comment nếu cần, hiện tại code chỉ dùng boto3 có sẵn)
# COPY requirements.txt ${LAMBDA_TASK_ROOT}
# RUN pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy file code CHÍNH XÁC của bạn vào container
COPY lambda_function.py ${LAMBDA_TASK_ROOT}

# Set CMD đúng với tên file và tên hàm handler (lambda_handler)
CMD [ "lambda_function.lambda_handler" ]