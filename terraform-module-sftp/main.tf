resource "aws_vpc" "iqgeo" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "iqgeo_public" {
  vpc_id     = aws_vpc.iqgeo.id
  cidr_block = var.subnet_cidr_block
}

resource "aws_internet_gateway" "iqgeo" {
  vpc_id = aws_vpc.iqgeo.id
}

resource "aws_route_table" "iqgeo_public" {
  vpc_id = aws_vpc.iqgeo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iqgeo.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "iqgeo_public" {
  subnet_id      = aws_subnet.iqgeo_public.id
  route_table_id = aws_route_table.iqgeo_public.id
}

resource "aws_security_group" "iqgeo_sftp" {
  name_prefix = "iqgeo-sftp"
}

resource "aws_security_group_rule" "iqgeo_sftp_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.iqgeo_sftp.id
}

resource "aws_s3_bucket" "iqgeo" {
    bucket = var.bucket_name
    acl    = "private"
  }
  
  resource "aws_route53_zone" "iqgeo-cloud" {
    name    = var.zone_name
    comment = "DNS zone for iqgeo.cloud"
  
    tags = {
      Environment = "production"
      Owner       = "iqgeo"
    }
  }
  
  resource "aws_route53_record" "iqgeo_sftp" {
    zone_id = aws_route53_zone.iqgeo-cloud.zone_id
    name    = "sftp.iqgeo.com"
    type    = "CNAME"
    ttl     = "300"
    records = [aws_transfer_server.sftp_iqgeo_server.endpoint]
  }
  
  resource "aws_vpc_endpoint" "iqgeo" {
    service_name = var.service_name
    vpc_id = aws_vpc.iqgeo.id
  }
  
  resource "aws_transfer_server" "sftp_iqgeo_server" {
  identity_provider_type = "SERVICE_MANAGED"
  url = "https://iqgeo.com/identity-provider"
  endpoint_type = "PUBLIC"
  endpoint_details {
    vpc_endpoint_id = aws_vpc_endpoint.iqgeo.id
    security_group_ids = [aws_security_group.iqgeo_sftp.id]
  }

  tags = {
    Name = var.server_name
  }

  domain = aws_s3_bucket.iqgeo.bucket_domain_name
}

  
  resource "aws_transfer_user" "sftp_iqgeo" {
    count = length(var.transfer_user_names)
    server_id = aws_transfer_server.sftp_iqgeo_server.id
    user_name = element(var.transfer_user_names, count.index)
    role      = aws_iam_role.sftp_iqgeo_role.arn
    home_directory = "/${var.bucket_name}"
  
    tags = {
      NAME = "sftp_iqgeo"
    }
  }
  
  
  
  data "aws_iam_policy_document" "assume_role" {
    statement {
      effect = "Allow"
  
      principals {
        type        = "Service"
        identifiers = ["transfer.amazonaws.com"]
      }
  
      actions = ["sts:AssumeRole"]
    }
  }
  
  resource "aws_iam_role" "sftp_iqgeo_role" {
    name               = var.role_name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
  }
  
  data "aws_iam_policy_document" "sftp_iqgeo" {
    statement {
      sid       = "AllowFullAccesstoS3"
      effect    = "Allow"
      actions   = ["s3:*"]
      resources = ["*"]
    }
  }
  
  resource "aws_iam_role_policy" "sftp_iqgeo_policy" {
    name   = var.policy_name
    role   = aws_iam_role.sftp_iqgeo_role.id
    policy = data.aws_iam_policy_document.sftp_iqgeo.json
  }
  resource "aws_transfer_ssh_key" "iqgeo" {
    count = length(var.transfer_user_names)
    user_name = aws_transfer_user.sftp_iqgeo[count.index].user_name
    server_id = aws_transfer_server.sftp_iqgeo_server.id
    body      = element(var.transfer_server_ssh_keys, count.index)
  }
  
  resource "aws_iam_role" "iqgeo" {
    name = "iqgeo-role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "transfer.amazonaws.com"
          }
        }
      ]
    })
  }
  resource "aws_iam_role_policy_attachment" "iqgeo" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    role       = aws_iam_role.iqgeo.name
  }
  
