resource "aws_rds_cluster" "rds-cluster" {
  cluster_identifier              = lower("aws-rds-cluster-dev-rowan-aurora-db")
  # Aurora 클러스터의 고유 식별자 (이름)
  # lower()를 사용하여 소문자로 변환

  engine                          = var.engine  # RDS 엔진 유형 (예: "aurora-mysql")
  engine_version                  = var.engine_version  # Aurora MySQL 버전 (예: "8.mysql_aurora")

  availability_zones              = [element(var.az, 0), element(var.az, 1)]
  # 클러스터가 배포될 가용 영역 (Multi-AZ 설정)

  db_subnet_group_name            = aws_db_subnet_group.rds-subnet-group.id
  # RDS가 배치될 서브넷 그룹

  database_name = var.dbname

  # 기본 데이터베이스 이름

  master_username                 = var.master_username  # DB 관리자 계정 이름
  master_password                 = random_password.rds-password.result  # 자동 생성된 랜덤 비밀번호

  backup_retention_period         = var.backup_retention_period  # 백업 보관 기간 (일)
  preferred_backup_window         = var.backup_window  # 백업 실행 시간 설정

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds-cluster-parameter-group.name
  # 클러스터에 적용할 Parameter Group 지정

  vpc_security_group_ids          = [aws_security_group.sg-aurora.id]
  # 클러스터에 적용할 Security Group

  deletion_protection             = false  # 실수로 삭제되지 않도록 보호 활성화
  storage_encrypted               = true  # 스토리지 암호화 활성화
  kms_key_id                      = var.kms_key_id  # KMS 키를 사용한 암호화 적용

  skip_final_snapshot             = true  # 클러스터 삭제 시 최종 스냅샷을 생성하지 않음
  port                            = var.port  # 기본 포트 (MySQL: 3306)

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  # CloudWatch에 로그 전송 설정 (예: "audit", "error", "general", "slowquery")

  lifecycle {
    ignore_changes = [availability_zones, engine_version, snapshot_identifier, kms_key_id]
    # 특정 속성 변경 시 Terraform이 무시하도록 설정
  }

  tags = var.tags  # 태그 적용
}

resource "aws_rds_cluster_instance" "rds-instance" {
  count                      = var.rds_instance_count  # 생성할 DB 인스턴스 개수
  identifier                 = lower("aws-rds-instance-dev-rowan-aurora-db-${count.index}")
  # DB 인스턴스의 고유 식별자 (이름)

  cluster_identifier          = aws_rds_cluster.rds-cluster.id
  # 위에서 생성한 Aurora 클러스터에 연결

  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.rds_instance_class
  # 인스턴스 유형 (예: db.r5.large)

  auto_minor_version_upgrade = var.rds_instance_auto_minor_version_upgrade
  # 마이너 버전 자동 업데이트 활성화 여부

  publicly_accessible        = var.rds_instance_publicly_accessible
  # 퍼블릭 IP 할당 여부

  lifecycle {
    ignore_changes = [engine_version, monitoring_interval]
    # 특정 속성 변경 시 Terraform이 무시하도록 설정
  }
}


resource "random_password" "rds-password" {
  length           = 16
  special          = true
  override_special = "_%"
  # 특수 문자 포함된 16자리 랜덤 비밀번호 생성
}


resource "aws_db_subnet_group" "rds-subnet-group" {
  name_prefix = lower("aws-rds-subnet-group-${var.stage}-${var.servicename}-aurora-${var.dbname}")
  # 서브넷 그룹의 이름을 소문자로 설정 (예: "aws-rds-subnet-group-dev-myapp-aurora-mydb")

  subnet_ids  = var.subnet_ids
  # RDS 클러스터가 배포될 서브넷 목록 지정 (Multi-AZ 지원)

}

resource "aws_rds_cluster_parameter_group" "rds-cluster-parameter-group" {
  name        = lower("aws-rds-cluster-parameter-group-dev-rowan-aurora-db")
  # 클러스터 파라미터 그룹 이름 (소문자 변환)

  family      = var.family  # Aurora 엔진 패밀리 (예: "aurora-mysql8")
  description = "RDS cluster parameter group"
  # 파라미터 그룹에 대한 설명

  parameter {
    name  = "autocommit"
    value = "0"
  }
  # 트랜잭션이 자동으로 커밋되지 않도록 설정 (데이터 무결성 보장)

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  # UTF-8MB4 설정을 통해 이모지 및 다양한 언어 지원

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_bin"
    #value = "utf8mb4_unicode_ci"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
    #value = "utf8mb4_unicode_ci"
  }
  # 데이터 정렬 및 비교 설정을 UTF-8MB4 기준으로 조정

  # parameter {
  #   name         = "lower_case_table_names"
  #   value        = "1"
  #   apply_method = "pending-reboot"
  # }
  # # 테이블 이름을 대소문자 구분 없이 사용하도록 설정
  
  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
  parameter {
    name = "max_user_connections"
    value = var.max_user_connections #default "4294967295"
  }
  # 최대 연결 수 및 최대 사용자 연결 수 설정 (기본값: 4294967295)

  parameter {
    name  = "sql_mode"
    value = "PIPES_AS_CONCAT,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  }
  # SQL 모드를 설정하여 안전한 SQL 실행 환경 구성

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }
  # RDS 클러스터의 타임존을 한국 시간으로 설정

  parameter {
    name  = "transaction_isolation"
    value = "READ-COMMITTED"
  }
  # 트랜잭션 격리 수준 설정 (READ-COMMITTED)

  parameter {
     name         = "connect_timeout" 
     value        = "60"
  }
  parameter {
    name         = "max_connect_errors"
    value        = "100000"
  }
  parameter {
    name         = "max_prepared_stmt_count"
    value        = "1048576"
  }
  parameter {
    name         = "long_query_time"
    value        = 5
  }
  # 긴 쿼리 감지 및 오류 허용 횟수 조정
  
  parameter {
    name         = "log_bin_trust_function_creators"
    value        = "1"
  }
  parameter {
    name         = "general_log"
    value        = "0"
  }
  parameter {
    name         = "server_audit_events"
    value        = "QUERY"
  }
  parameter {
    name         = "server_audit_excl_users"
    value        = "rdsadmin"
  }
  parameter {
    name         = "server_audit_logging"
    value        = "1"
  }
  # 데이터베이스 감사 로깅 및 보안 관련 설정

  tags = var.tags
 
}


resource "aws_db_parameter_group" "rds-instance-parameter-group" {
  name   = lower("aws-rds-instance-parameter-group-dev-rowan-aurora-db")
  family = var.family  # Aurora 인스턴스 엔진 패밀리 (예: "aurora-postgresql12")

  parameter {
    name  = "autocommit"
    value = "0"
  }
  # 자동 커밋 비활성화 (트랜잭션 안정성 강화)

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
  parameter {
    name = "max_user_connections"
    value = var.max_user_connections #default "4294967295"
  }
  # 최대 연결 수 및 사용자 연결 수 설정

  parameter {
    name         = "performance_schema"
    value        = "1"
    apply_method = "pending-reboot"
  }
  # 성능 모니터링을 위한 Performance Schema 활성화 (재부팅 필요)
  parameter {
    name  = "sql_mode"
    value = "PIPES_AS_CONCAT,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  }
  parameter {
    name  = "transaction_isolation"
    value = "READ-COMMITTED"
  }
  tags = var.tags
 
}
