variable "compartment_ocid" {
    type = string
}

variable "ingress_cidrs" {
    type = string
}

variable "egress_cidrs" {
    type = string
}

variable "workload_cidrs" {
    type = string
}

variable "egress_ip_ocid" {
    type = string
    default = null
}