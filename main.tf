
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA4MTWOE5EMQUZRW6E"
  secret_key = "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"
}



resource "aws_s3_bucket" "b" {
 bucket = "parallel-research-s3-bucket-0001000"
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket = aws_s3_bucket.b.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "b" {
 bucket = aws_s3_bucket.b.id
 policy = <<POLICY
{
 "Version": "2012-10-17",
 "Id": "MYBUCKETPOLICY",
 "Statement": [
   {
      "Sid": "GrantAnonymousReadPermissions",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::parallel-research-s3-bucket/*"
   },
  {
    "Sid": "GrantAnonymousReadPermissions1",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::parallel-research-s3-bucket-0001000/*"
  }
]
}
POLICY
depends_on = [ aws_s3_bucket_public_access_block.b ]
}

resource "aws_security_group" "mysql_sg" {
  name        = "research-mysql-sg1"
  description = "Security group for MySQL on port 3306"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from any IP address
  }
}
output "security_group_id" {
  value = aws_security_group.mysql_sg.id
}
data "aws_security_group" "mysql_sg" {
  id = aws_security_group.mysql_sg.id
}

resource "aws_db_instance" "default" {
  allocated_storage             = 20
  apply_immediately             = true
  db_name                       = "mydb1"
  engine                        = "mysql"
  engine_version                = "5.7"
  identifier                    = "research-rds2"   
  instance_class                = "db.t3.micro"
  network_type                  = "IPV4"
  port                          = "3306" 
  publicly_accessible           = true
  username                      = "admin"
  password                      = "passwd1!"
  parameter_group_name          = "default.mysql5.7"
  vpc_security_group_ids        = [data.aws_security_group.mysql_sg.id]
}
