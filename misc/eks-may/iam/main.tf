resource "aws_iam_group" "reader" {
  name = "innfisreader"
}

resource "aws_iam_group" "manager" {
  name = "innfismanager"
}