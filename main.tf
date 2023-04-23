
module "sftp" {
  source = "./terraform-module-sftp"

  region                = "us-east-1"
  vpc_cidr_block        = "10.0.0.0/16"
  subnet_cidr_block     = "10.0.1.0/24"
  bucket_name           = "iqgeo-bucket"
  zone_name             = "sftp.iqgeo.com"
  server_name           = "sftp_iqgeo_server"
  server_domain         = "sftp.iqgeo.com"
  transfer_user_name    = "iqgeo_user"
  role_name             = "sftp_iqgeo_role"
  policy_name           = "sftp_iqgeo_policy"
  public_key_body       = "... SSH key ..."
  service_name          = "sftp_iqgeo"
}
