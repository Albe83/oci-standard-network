variable "compartment" {
}

variable "vcn_name" {
  type = string
  default = "VCN"
  description = "Name of VCN Resource"
}

variable "cidrs_workload" {
  type = set(string)
  default = []
  description = "List, space separeted, of CIDR for workload subnets. Es. 192.168.0.0/24 192.168.10.0/24"
}

variable "cidrs_ingress" {
  type = set(string)
  default = []
  description = "List, space separeted, of CIDR for ingress subnets. Es. 192.168.0.0/24 192.168.10.0/24"
}

variable "cidrs_egress" {
  type = set(string)
  default = []
  description = "List, space separeted, of CIDR for egress subnets. Es. 192.168.0.0/24 192.168.10.0/24"
}