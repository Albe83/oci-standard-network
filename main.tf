terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "5.42.0"
    }
  }
}

locals {
  compartment_id = var.compartment_id
  public_cidr = "192.168.0.0/24"
  private_cidr = "192.168.100.0/24"

  compartment = data.oci_identity_compartment.compartment
  vcn = oci_core_vcn.vcn
}

data "oci_identity_compartment" "compartment" {
    id = local.compartment_id
}

resource "oci_core_vcn" "vcn" {
    compartment_id = local.compartment.id

    cidr_blocks = [
        local.public_cidr,
        local.private_cidr
    ]
}