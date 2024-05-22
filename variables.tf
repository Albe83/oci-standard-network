variable "compartment_id" {
    type = string
}

variable "public_cidr" {
    type = string
    default = "192.168.0.0/24"
}

variable "private_cidr" {
    type = string
    default = "192.168.100.0/24"
}