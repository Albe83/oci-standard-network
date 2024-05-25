terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "5.42.0"
    }
  }
}

locals {
  compartment_id = var.compartment_ocid

  anywhere-cidr = "0.0.0.0/0"
  ingress-cidrs = toset(distinct(compact(split(" ", trim(var.ingress_cidrs, " ")))))
  egress-cidrs = toset(distinct(compact(split(" ", trim(var.egress_cidrs, " ")))))
  workload-cidrs = toset(distinct(compact(split(" ", trim(var.workload_cidrs, " ")))))
  egress-ip-id = var.egress_ip_ocid

  log-retention = 30

  vcn-name = "VCN"
  net-ingress-name = "Ingress %s Subnet"
  net-egress-name = "Egress %s Subnet"
  net-workloads-name = "Workload %s Subnet"
}

data "oci_identity_compartment" "compartment" {
    id = local.compartment_id
}

resource "oci_core_vcn" "vcn" {
    compartment_id = data.oci_identity_compartment.compartment.id

    cidr_blocks = toset(distinct(setunion(
        local.workload-cidrs,
        local.ingress-cidrs,
        local.egress-cidrs
    )))

    display_name = local.vcn-name
}