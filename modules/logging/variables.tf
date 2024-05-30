variable "vcn" { 
}

variable "log_retention" {
  type = number
  default = 30
  description = "Number of days to retaining logs"
}