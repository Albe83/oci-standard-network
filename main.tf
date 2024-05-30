terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "5.42.0"
    }
  }
}

locals {
  compartment_id = coalesce(var.compartment_ocid, var.tenancy_ocid)
}

data "oci_identity_compartment" "comparment" {
  id = local.compartment_id
}

module "vcn" {
  source = "./modules/vcn"

  compartment = data.oci_identity_compartment.comparment

  cidrs_workload = toset([
    "192.168.0.0/24",
    "192.168.10.0/24"
  ])
  
  cidrs_ingress = toset([
    "192.168.254.0/24"
  ])

  cidrs_egress = toset([
    "192.168.255.0/24"
  ])
}

module "drg" {
  source = "./modules/drg"

  vcn = module.vcn.vcn
  route_table = module.vcn.vcn.route_tables.workload
}
