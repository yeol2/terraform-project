# 현재 배포 환경을 설정 (예: "dev", "stg", "prod")
variable "stage" {
  type    = string
  default = "dev"
}

# 서비스의 이름을 설정
variable "servicename" {
  type    = string
  default = "rowan"
}

# AWS 리소스에 적용할 공통 태그
variable "tags" {
  type = map(string)
  default = {
    "name" = "rowandb"
  }
}

# 기본 데이터베이스 이름
variable "dbname" {
  type    = string
  default = "rdsrowandb"
}

# 사용할 RDS 엔진 유형 (Aurora MySQL 사용)
variable "engine" {
  type    = string
  default = "aurora-mysql"
}

# Aurora MySQL 엔진 버전
variable "engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.04.0"
}

# RDS 마스터(관리자) 계정 이름
variable "master_username" {
  type    = string
  default = "admin"
}

# RDS 백업 보관 기간 (일 단위, 최대 35일)
variable "backup_retention_period" {
  type    = string
  default = 30
}

# RDS 백업 실행 시간 설정 (UTC 기준)
variable "backup_window" {
  type    = string
  default = "18:00-20:00"
}

# RDS 암호화를 위한 AWS KMS 키 ID (필수)
variable "kms_key_id" {
  type = string
}

# CloudWatch 로그 전송 활성화 (audit, error, general, slowquery 로그 포함)
variable "enabled_cloudwatch_logs_exports" {
  type    = list
  default = ["audit", "error", "general", "slowquery"]
}

# Aurora 서버리스 모드 최대/최소 용량 설정
variable "max_capacity" {
  type    = string
  default = 16
}

variable "min_capacity" {
  type    = string
  default = 1
}

# 최대 연결 수 설정
variable "max_connections" {
  type    = string
  default = 16000
}

# 최대 사용자 연결 수 설정
variable "max_user_connections" {
  type    = string
  default = 4294967295
}

# Aurora 서버리스 자동 일시 정지까지의 대기 시간 (초 단위, 기본값 3시간)
variable "seconds_util_auto_pause" {
  type    = string
  default = 10800
}

# Aurora 서버리스 용량 변경 정책
variable "timeout_action" {
  type    = string
  default = "ForceApplyCapacityChange"
}

# Aurora 파라미터 그룹 패밀리 설정
variable "family" {
  type    = string
  default = "aurora-mysql8.0"
}

# MySQL 기본 포트 (3306)
variable "port" {
  type    = string
  default = "3306"
}

# RDS가 배포될 AWS 가용 영역(AZ) 리스트
variable "az" {
  type = list(any)
}

# RDS 서브넷 그룹에 포함될 서브넷 ID 리스트
variable "subnet_ids" {
  type = list
}

# RDS가 속할 VPC ID
variable "network_vpc_id" {
  type = string
}

# Aurora에 대한 인바운드 허용 CIDR 목록 (IP 기반 접근 허용)
variable "sg_allow_ingress_list_aurora" {
  type    = list
  default = []
}

# Aurora에 대한 인바운드 허용 보안 그룹 목록 (SG 기반 접근 허용)
variable "sg_allow_ingress_sg_list_aurora" {
  type    = list
  default = []
}

# Aurora 클러스터 내 인스턴스 개수 설정 (0이면 서버리스)
variable "rds_instance_count" {
  type    = number
  default = 0
}

# Aurora 인스턴스 타입 (예: db.r6g.large)
variable "rds_instance_class" {
  type    = string
  default = "db.r5.large"
}

# RDS 인스턴스 마이너 버전 자동 업데이트 여부
variable "rds_instance_auto_minor_version_upgrade" {
  type    = bool
  default = false
}

# RDS 인스턴스를 퍼블릭 액세스 가능하게 설정할지 여부
variable "rds_instance_publicly_accessible" {
  type    = bool
  default = false
}

