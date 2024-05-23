variable "compartment_id" {
    type = string
}

variable "ingress_cidrs" {
    type = string
    default = "192.168.0.0/24"
}

variable "egress_cidrs" {
    type = string
    default = "192.168.10.0/24"
}

variable "workload_cidrs" {
    type = string
    default = "192.168.100.0/24"
}