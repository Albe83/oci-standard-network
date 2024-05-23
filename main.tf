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

resource "oci_logging_log_group" "flowlogs" {
    compartment_id = local.vcn.compartment_id

    display_name = "Flowlogs"
    description = format("Network Logs from VCN: %s", local.vcn.display_name)
}