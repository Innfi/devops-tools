variable "user_names" {
  type =  set(string)
  default = [ "readonly_innfi", "readonly_ennfi" ]
}

variable "policy_readonly" {
  type = set(string)
  default = [
    "ars:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "ars:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}