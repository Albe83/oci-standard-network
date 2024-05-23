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

  ingress-cidr = var.ingress_cidr
  egress-cidr = var.egress_cidr
  workload-cidr = var.workload_cidr
  anywhere-cidr = "0.0.0.0/0"


  compartment = data.oci_identity_compartment.compartment
  vcn = oci_core_vcn.vcn
  drg = oci_core_drg.drg

  igw = oci_core_internet_gateway.igw
  ngw = oci_core_nat_gateway.ngw
  sgw = oci_core_service_gateway.sgw

  rt-ingress = oci_core_route_table.ingress
  rt-egress = oci_core_route_table.egress
  rt-workload = oci_core_route_table.workload

  net-ingress = oci_core_subnet.ingress
  net-egress = oci_core_subnet.egress
  net-workload = oci_core_subnet.workload
}

data "oci_identity_compartment" "compartment" {
    id = local.compartment_id
}

resource "oci_core_vcn" "vcn" {
    compartment_id = local.compartment.id

    cidr_blocks = [
        local.workload-cidr,
        local.ingress-cidr,
        local.egress-cidr,
    ]

    display_name = "VCN"
}

resource "oci_core_internet_gateway" "igw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "Internet Gateway"
}

resource "oci_core_public_ip" "ngw" {
    compartment_id = local.vcn.compartment_id
    lifetime = "RESERVED"

    display_name = "NAT Gateway"
}

resource "oci_core_nat_gateway" "ngw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "NAT Gateway"
    public_ip_id = oci_core_public_ip.ngw.id
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

resource "oci_core_route_table" "ingress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere-cidr
        network_entity_id = local.igw.id
    }

    display_name = "Route Table for ingress subnet"

    depends_on = [
        local.vcn
     ]
}

resource "oci_core_route_table" "egress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere-cidr
        network_entity_id = local.ngw.id
    }

    display_name = "Route Table for Egress subnet"

    depends_on = [
        local.vcn
     ]
}

resource "oci_core_route_table" "workload" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    route_rules {
        description = "OCI Regional Services"
        destination_type = "SERVICE_CIDR_BLOCK"
        destination = data.oci_core_services.oci_services.services.0.cidr_block
        network_entity_id = local.sgw.id
    }

    display_name = "Route Table for Workload subnet"

    depends_on = [
        local.vcn
     ]
}

resource "oci_core_subnet" "ingress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.ingress-cidr
    prohibit_internet_ingress = false
    prohibit_public_ip_on_vnic = false

    route_table_id = local.rt-ingress.id

    display_name = "Ingress subnet"
}

resource "oci_core_subnet" "egress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.egress-cidr
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-egress.id

    display_name = "Egress subnet"
}

resource "oci_core_subnet" "workload" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.workload-cidr
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-workload.id

    display_name = "Egress subnet"
}

resource "oci_core_drg" "drg" {
    #Required
    compartment_id = local.vcn.compartment_id

    display_name = "DRG"
}

resource "oci_core_drg_attachment" "vcn" {
    drg_id = local.drg.id

    network_details {
        type = "VCN"
        id = local.vcn.id
        route_table_id = local.net-workload.route_table_id
    }

    display_name = "VCN"
}