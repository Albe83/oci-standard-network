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

  anywhere = "0.0.0.0/0"


  compartment = data.oci_identity_compartment.compartment
  vcn = oci_core_vcn.vcn

  igw = oci_core_internet_gateway.igw
  ngw = oci_core_nat_gateway.ngw
  sgw = oci_core_service_gateway.sgw

  rt-public = oci_core_route_table.public
  rt-private = oci_core_route_table.private

  net-public = oci_core_subnet.public
  net-private = oci_core_subnet.private
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

    display_name = "VCN"
}

resource "oci_core_internet_gateway" "igw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "Internet Gateway"
}

resource "oci_core_nat_gateway" "ngw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "NAT Gateway"
}

data "oci_core_services" "oci_services" {
}

resource "oci_core_service_gateway" "sgw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    services {
        service_id = data.oci_core_services.oci_services.services.0.id
    }

    display_name = "OCI Services Gateway"
}

resource "oci_core_route_table" "public" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere
        network_entity_id = local.igw.id
    }

    display_name = "Route Table for Public subnet"
}

resource "oci_core_route_table" "private" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere
        network_entity_id = local.ngw.id
    }

    route_rules {
        description = "OCI Regional Services"
        destination_type = "SERVICE_CIDR_BLOCK"
        destination = data.oci_core_services.oci_services.services.0.cidr_block
        network_entity_id = local.sgw.id
    }

    display_name = "Route Table for Private subnet"
}

resource "oci_core_subnet" "public" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.public_cidr
    prohibit_internet_ingress = false
    prohibit_public_ip_on_vnic = false

    route_table_id = local.rt-public.id

    display_name = "Public subnet"
}

resource "oci_core_subnet" "private" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.private_cidr
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-private.id

    display_name = "Private subnet"
}