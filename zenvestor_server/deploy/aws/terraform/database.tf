resource "aws_db_instance" "postgres" {
  identifier          = var.project_name
  allocated_storage   = 10
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  db_name             = "serverpod"
  username            = "postgres"
  password            = var.DATABASE_PASSWORD_PRODUCTION
  skip_final_snapshot = true
  vpc_security_group_ids = [
    aws_security_group.database.id
  ]
  publicly_accessible  = false
  db_subnet_group_name = module.vpc.database_subnet_group_name
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

resource "aws_route53_record" "database" {
  zone_id = var.hosted_zone_id
  name    = "${var.subdomain_database}.${var.top_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.postgres.address}"]
}

# Database security group - restricts access to VPC only
resource "aws_security_group" "database" {
  name   = "${var.project_name}-database"
  vpc_id = module.vpc.vpc_id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Staging
resource "aws_db_instance" "postgres_staging" {
  count = var.enable_staging_server ? 1 : 0

  identifier          = "${var.project_name}-staging"
  allocated_storage   = 10
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  db_name             = "serverpod"
  username            = "postgres"
  password            = var.DATABASE_PASSWORD_STAGING
  skip_final_snapshot = true
  vpc_security_group_ids = [
    aws_security_group.database.id
  ]
  publicly_accessible  = false
  db_subnet_group_name = module.vpc.database_subnet_group_name
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

resource "aws_route53_record" "database_staging" {
  count = var.enable_staging_server ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = "${var.subdomain_database_staging}.${var.top_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.postgres_staging[0].address}"]
}