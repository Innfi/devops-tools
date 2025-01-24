resource "aws_iam_role" "replication_role" {
  name = "replication_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect" : "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "replication_policy" {
  name   = "repication_policy"
  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
        ],
        Resource = "${var.s3_arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
        ],
        Resource = "${var.s3_dest_arn}"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  provider = aws.central

  bucket = var.s3_id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication" "replication_conf" {
  provider = aws.central

  depends_on = [ aws_s3_bucket_versioning.bucket_versioning ]

  role = var.versioning_role_arn
  bucket = var.s3_id

  rule {
    id = "repl_rule"
    status = "Enabled"
    destination {
      bucket = var.s3_dest_arn
      storage_class = "STANDARD"
    }
  }
}
