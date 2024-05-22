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
  igw = oci_core_internet_gateway.igw
  ngw = oci_core_nat_gateway.ngw
  sgw = oci_core_service_gateway.sgw
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

resource "oci_core_internet_gateway" "igw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id
}

resource "oci_core_internet_gateway" "igw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id
}

resource "oci_core_nat_gateway" "ngw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id
}

data "oci_core_services" "oci_services" {
}

resource "oci_core_service_gateway" "sgw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    services {
        service_id = data.oci_core_services.oci_services.services.0.id
    }
}
