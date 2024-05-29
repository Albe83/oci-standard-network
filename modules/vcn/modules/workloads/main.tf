terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "5.42.0"
    }
  }
}

locals {
  vcn = var.vcn
  cidrs = var.cidrs
  route_table_name = var.route_table_name
}

resource "oci_core_route_table" "route_table" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_ocid

    display_name = local.route_table_name
}

resource "oci_core_subnet" "subnets" {
    for_each = local.cidrs

    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = each.key
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = oci_core_route_table.route_table.id
}
