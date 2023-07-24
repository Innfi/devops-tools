#symmetric

resource "aws_kms_key" "sym_key" {
  description = "symmetric key"

  key_usage = "ENCRYPT_DECRYPT"

  policy = jsonencode({
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.kms_arn}"
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
  }) 
}

resource "aws_kms_key" "asym_key" {
  description = "asymmetric key"

  key_usage = "SIGN_VERIFY"

  customer_master_key_spec = "RSA_4096"

  enable_key_rotation = true
}