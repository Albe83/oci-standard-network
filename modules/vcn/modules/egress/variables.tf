variable "vcn" {
}

variable "cidrs" {
  type = set(string)
  default = []
  description = "List, space separeted, of CIDR. Es. 192.168.0.0/24 192.168.10.0/24"
}