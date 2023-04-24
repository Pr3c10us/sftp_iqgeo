output "s3_bucket_name" {
  value = aws_s3_bucket.iqgeo.bucket
}

output "route53_zone_id" {
  value = aws_route53_zone.iqgeo-cloud.zone_id
}

output "transfer_server_id" {
  value = aws_transfer_server.sftp_iqgeo_server.id
}

# output "transfer_user_name" {
#   value = aws_transfer_user.sftp_iqgeo[count.index].user_name
# }

output "transfer_user_names" {
  value = [for user in aws_transfer_user.sftp_iqgeo[*] : user.user_name]
}
