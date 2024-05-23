variable "compartment_id" {
    type = string
}

variable "ingress-cidr" {
    type = string
    default = "192.168.0.0/24"
}

variable "egress-cidr" {
    type = string
    default = "192.168.10.0/24"
}

variable "workload-cidr" {
    type = string
    default = "192.168.100.0/24"
}