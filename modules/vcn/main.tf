terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "5.42.0"
    }
  }
}

locals {
    compartment = var.compartment

    vcn_name = var.vcn_name

    cidrs_workload = var.cidrs_workload
    cidrs_ingress = var.cidrs_ingress
    cidrs_egress = var.cidrs_egress

    cidrs = distinct(setunion(
        local.cidrs_workload, local.cidrs_ingress, local.cidrs_egress
    ))
}

resource "oci_core_vcn" "vcn" {
    compartment_id = local.compartment.id

    cidr_blocks = local.cidrs

    display_name = local.vcn_name
}

resource "oci_logging_log_group" "flowlogs" {
    compartment_id = oci_core_vcn.vcn.compartment_id

    display_name = oci_core_vcn.vcn.id
}

module "workloads" {
    source = "./modules/workloads"

    vcn = oci_core_vcn.vcn
    cidrs = local.cidrs_workload

    log_group = oci_logging_log_group.flowlogs
}

module "ingress" {
  source = "./modules/ingress"

  vcn = oci_core_vcn.vcn
  cidrs = local.cidrs_ingress
}

module "egress" {
  source = "./modules/egress"

  vcn = oci_core_vcn.vcn
  cidrs = local.cidrs_egress
}

