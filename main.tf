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

  compartment = data.oci_identity_compartment.compartment
}

data "oci_identity_compartment" "compartment" {
    id = local.compartment_id
}