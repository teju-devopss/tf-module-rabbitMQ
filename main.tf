# resource "aws_security_group" "main" {
#   name        = local.name
#   description = local.name
#   vpc_id      = var.vpc_id
#
#   ingress {
#     description = "RABBITMQ"
#     from_port   = 5672
#     to_port     = 5672
#     protocol    = "tcp"
#     cidr_blocks = var.sg_cidrs
#   }
#
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = var.bastion_cidrs
#   }
#
#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
#
#   tags = merge(var.tags, { Name = local.name })
# }
#
# resource "aws_instance" "main" {
#   ami                    = data.aws_ami.ami.image_id
#   instance_type          = var.instance_type
#   vpc_security_group_ids = [aws_security_group.main.id]
#   subnet_id              = var.subnets[0]
#   tags                   = merge(var.tags, { Name = local.name })
#   iam_instance_profile   = aws_iam_instance_profile.main.name
#
#   root_block_device {
#     volume_size           = 10
#     encrypted             = true
#     kms_key_id            = var.kms
#     delete_on_termination = true
#   }
#
#
#   user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {
#     env = var.env
#   }))
# }
#
# resource "aws_iam_role" "main" {
#   name = local.name
#   tags = merge(var.tags, { Name = local.name })
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
#
#   inline_policy {
#     name = "SSM-Read-Access"
#
#     policy = jsonencode({
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Sid" : "GetResources",
#           "Effect" : "Allow",
#           "Action" : [
#             "ssm:GetParameterHistory",
#             "ssm:GetParametersByPath",
#             "ssm:GetParameters",
#             "ssm:GetParameter"
#           ],
#           "Resource" : [
#             "arn:aws:ssm:us-east-1:633788536644:parameter/${var.env}.${var.project_name}.rabbitmq.*"
#           ]
#         },
#         {
#           "Sid" : "ListResources",
#           "Effect" : "Allow",
#           "Action" : "ssm:DescribeParameters",
#           "Resource" : "*"
#         },
#         {
#           "Sid" : "S3UploadForPrometheusAlerts",
#           "Effect" : "Allow",
#           "Action" : [
#             "s3:GetObject",
#             "s3:ListBucket",
#             "s3:PutObject",
#             "s3:DeleteObjectVersion",
#             "s3:DeleteObject"
#           ],
#           "Resource" : [
#             "arn:aws:s3:::d76-prometheus-alert-rules/*",
#             "arn:aws:s3:::d76-prometheus-alert-rules"
#           ]
#         }
#       ]
#     })
#   }
#
# }
#
# resource "aws_iam_instance_profile" "main" {
#   name = local.name
#   role = aws_iam_role.main.name
# }
#
# resource "aws_route53_record" "main" {
#   name    = "rabbitmq-${var.env}"
#   type    = "A"
#   zone_id = var.route53_zone_id
#   ttl     = 30
#   records = [aws_instance.main.private_ip]
# }
