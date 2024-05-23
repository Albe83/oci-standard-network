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

  anywhere-cidr = "0.0.0.0/0"
  ingress-cidr = var.ingress_cidr
  egress-cidr = var.egress_cidr
  workload-cidrs = toset(split(" ", trim(var.workload_cidrs, " ")))


  vcn-name = "VCN"
  net-ingress-name = "Ingress Subnet"
  net-egress-name = "Egress Subnet"
  net-workloads-name = "Workload %s Subnet"

  compartment = data.oci_identity_compartment.compartment
  vcn = oci_core_vcn.vcn
  drg = oci_core_drg.drg

  igw = oci_core_internet_gateway.igw
  ngw = oci_core_nat_gateway.ngw

  rt-ingress = oci_core_route_table.ingress
  rt-egress = oci_core_route_table.egress
  rt-workload = oci_core_route_table.workload

  net-ingress = oci_core_subnet.ingress
  net-egress = oci_core_subnet.egress
  net-workloads = oci_core_subnet.workloads
}

data "oci_identity_compartment" "compartment" {
    id = local.compartment_id
}

resource "oci_core_vcn" "vcn" {
    compartment_id = local.compartment.id

    cidr_blocks = setunion(
        local.workload-cidrs,
        [local.ingress-cidr],
        [local.egress-cidr]
    )

    display_name = local.vcn-name
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

resource "oci_core_route_table" "ingress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere-cidr
        network_entity_id = local.igw.id
    }

    display_name = "Route Table for ingress subnet"
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
}

resource "oci_core_route_table" "workload" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "Route Table for Workload subnets"
}

resource "oci_core_subnet" "ingress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.ingress-cidr
    prohibit_internet_ingress = false
    prohibit_public_ip_on_vnic = false

    route_table_id = local.rt-ingress.id

    display_name = local.net-ingress-name
}

resource "oci_core_subnet" "egress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.egress-cidr
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-egress.id

    display_name = local.net-egress-name
}

resource "oci_core_subnet" "workloads" {
    for_each = local.workload-cidrs

    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = each.key
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-workload.id

    display_name = format(local.net-workloads-name, each.key)
}

resource "oci_core_drg" "drg" {
    compartment_id = local.vcn.compartment_id

    display_name = format("Local DRG for %s", local.vcn.display_name)
}

resource "oci_core_drg_attachment" "workload" {
    drg_id = local.drg.id

    network_details {
        type = "VCN"
        id = local.vcn.id
        route_table_id = local.rt-workload.id
    }

    display_name = format("Remote subnets for %s Workload", local.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "hub" {
    drg_id = local.drg.id
    compartment_id = local.drg.compartment_id

    display_name = format("%s to HUB", local.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "dr" {
    drg_id = local.drg.id
    compartment_id = local.drg.compartment_id

    display_name = format("%s to Disaster Recovery region", local.vcn.display_name)
}