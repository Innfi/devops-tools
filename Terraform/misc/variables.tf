variable "repository_days" {
  type = list(string)
  default = [
    "this_repo",
    "that_repo"
  ]
}

variable "days_threshold" {
  type = number
  default = 30
}

variable "repository_counts" {
  type = list(string)
  default = [
    "one_repo",
    "two_repo"
  ]
}

variable "count_threshold" {
  type = number
  default = 10
}
