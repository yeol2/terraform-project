# 현재 배포 환경을 설정 (예: "dev", "stg", "prod")
variable "stage" {
    type  = string
    default = "dev"
}

# 서비스의 이름을 설정
variable "servicename" {
    type  = string
    default = "aaron"
}

# AWS 리소스에 적용할 공통 태그
variable "tags" {
  type = map(string)
  default = {
    "name" = "aaron-alb"
  }
}

# ALB가 내부(Internal)인지 여부 (true: 내부용, false: 인터넷 공개)
variable "internal" {
    type  = bool
    default = true
}

# ALB가 퍼블릭인지 여부 (true: 퍼블릭 ALB, false: 프라이빗 ALB)
variable "public" {
    type  = bool
    default = false
}

# ALB가 배포될 서브넷 ID 목록 (VPC 내부의 ALB 서브넷)
variable "subnet_ids" {
    type  = list
    default = []
}

# ALB 접근 로그를 저장할 S3 버킷 이름
variable "aws_s3_lb_logs_name" {
    type  = string
}

# ALB의 연결 유휴 시간 (초 단위)
variable "idle_timeout" {
    type  = string
    default = "60"
}

# HTTPS용 SSL 인증서 ARN (AWS Certificate Manager에서 제공)
variable "certificate_arn" {
    type  = string
}

# ALB가 연결할 Target Group의 기본 포트 (예: 80, 443, 8080)
variable "port" {
    type  = string
    default = "80"
}

# ALB가 속할 VPC ID
variable "vpc_id" {
    type  = string
}

# asg 사용해서 주석처리함
# # ALB가 라우팅할 EC2 인스턴스 ID 목록
# variable "instance_ids" {
#     type  = list
# }

# Route 53에서 사용할 도메인 이름 (없으면 빈 값)
variable "domain" {
    type  = string
    default = ""
}

# Route 53의 호스팅 존 ID (없으면 빈 값)
variable "hostzone_id" {
    type  = string
    default = ""
}

# 헬스 체크 경로 (기본값: "/")
variable "hc_path" {
    type  = string
    default = "/"
}

# 헬스 체크가 정상으로 간주될 연속 성공 횟수
variable "hc_healthy_threshold" {
    type  = number
    default = 5
}

# 헬스 체크가 비정상으로 간주될 연속 실패 횟수
variable "hc_unhealthy_threshold" {
    type  = number
    default = 2
}

# ALB의 보안 그룹에서 허용할 CIDR 블록 목록 (예: ["0.0.0.0/0"])
variable "sg_allow_comm_list" {
    type = list
}

# Target Group의 대상 유형 (예: "instance", "ip", "lambda")
variable "target_type" {
    type = string
    default = "instance"
}

# asg 사용으로 인한 주석처리
# 특정 가용 영역에서만 ALB를 실행할 경우 사용 (기본값: 빈 값)
# variable "availability_zone" {
#     type = string
#     default = ""
# }
