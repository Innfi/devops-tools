resource "aws_ebs_volume" "ebs_vol" {
  availability_zone = "ap-northeast-2a"
  size = 20 

  type = "standard" 
  kms_key_id = var.kms_id
}

resource "aws_volume_attachment" "volume_attachment" {
  device_name = "/usr/local/bin"
  volume_id = resource.aws_ebs_volume.ebs_vol.id
  instance_id = var.target_ec2_id
}