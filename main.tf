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
  ingress-cidrs = toset(split(" ", trim(var.ingress_cidrs, " ")))
  egress-cidrs = toset(split(" ", trim(var.egress_cidrs, " ")))
  workload-cidrs = toset(split(" ", trim(var.workload_cidrs, " ")))

  log-retention = 30

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

  log-group = oci_logging_log_group.flowlogs
}

data "oci_identity_compartment" "compartment" {
    id = local.compartment_id
}

resource "oci_core_vcn" "vcn" {
    compartment_id = local.compartment.id

    cidr_blocks = setunion(
        local.workload-cidrs,
        local.ingress-cidrs,
        local.egress-cidrs
    )

    display_name = local.vcn-name
}

resource "oci_logging_log_group" "flowlogs" {
    compartment_id = local.vcn.compartment_id

    display_name = local.vcn.id
    description = format("Network Logs from VCN: %s", local.vcn.display_name)
}

resource "oci_logging_log" "vcn" {
  display_name = local.vcn.id
  log_group_id = local.log-group.id
  log_type = "SERVICE"

  configuration {
    source {
      category  = "vcn"
      service = "flowlogs"
      source_type = "OCISERVICE"
      resource = local.vcn.id
    }
  }

  is_enabled = true
  retention_duration = local.log-retention
}