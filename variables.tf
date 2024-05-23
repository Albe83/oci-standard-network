variable "compartment_id" {
    type = string
}

variable "ingress_cidr" {
    type = string
    default = "192.168.0.0/24"
}

variable "egress_cidr" {
    type = string
    default = "192.168.10.0/24"
}

variable "workload_cidr" {
    type = string
    default = "192.168.100.0/24"
}