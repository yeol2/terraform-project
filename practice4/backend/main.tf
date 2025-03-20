provider "aws" {
        region = "ap-northeast-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "250320-rowan-practice4"  
}

resource "aws_s3_bucket_versioning" "enable" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
}
###
# 수명 주기 정책 추가
# resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     id = "expire-old-versions"
#     status = "Enabled"

#     noncurrent_version_expiration {
#       noncurrent_days = 30  # 30일 후 오래된 버전 자동 삭제
#     }
#   }
# }
###
# S3 bucket에 SSE(Server-side Encryption) 암호화 활성화
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
        }
    } 
}

# S3 bucket에 명시적 public access 비활성화 코드 작성 및 텍스트 에디터 종료
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# DynamoDB를 이용한 상태 파일 Lock 처리
resource "aws_dynamodb_table" "terraform_lock" {
    name = "250320-rowan-practice4"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}