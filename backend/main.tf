# S3 bucket for terraform state
resource "aws_s3_bucket" "terraform_state" {
    bucket = "rowan-2503-state-final"
    force_destroy = true  # S3 버킷 삭제 방지 (true로 설정하면 삭제 가능)
}

# S3 versioning enable -> terraform state 변경사항 추적
resource "aws_s3_bucket_versioning" "enable" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
}

# 수명 주기 정책 추가
# resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     id = "expire-old-versions"
#     status = "Enabled"

#     noncurrent_version_expiration {
#       noncurrent_days = 120  # 120일 후 오래된 버전 자동 삭제
#     }
#   }
# }


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
    block_public_policy = false
    ignore_public_acls = true
    restrict_public_buckets = true
}

 # S3 버킷 정책 설정 (IAM 역할 또는 사용자에게 Terraform 사용 권한 부여)
resource "aws_s3_bucket_policy" "terraform_state_policy" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::908027376495:user/rowan.park"
      },
      "Action": [
        "s3:GetBucketPolicy",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::rowan-2503-state-final",
        "arn:aws:s3:::rowan-2503-state-final/*"
      ]
    }
  ]
}
POLICY
}

# DynamoDB를 이용한 상태 파일 Lock 처리
resource "aws_dynamodb_table" "terraform_lock" {
    name = "rowan-2503-state-final"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}