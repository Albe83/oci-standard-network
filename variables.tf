variable "compartment_ocid" {
    type = string
    description = "The OCID of the compartment"
}

variable "ingress_cidrs" {
    type = string
    description = "List of CIDRs, space separated for ingress subnets"
}

variable "egress_cidrs" {
    type = string
    description = "List of CIDRs, space separated for egress subnets"
}

variable "workload_cidrs" {
    type = string
    description = "List of CIDRs, space separated for workload subnets"
}

variable "egress_ip_ocid" {
    type = string
    default = null
    description = "Optional public IP OCID for NAT Gateway"
}