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
  route_table = var.route_table

  hubs = toset(["Hub1", "Hub2"])
}

resource "oci_core_drg" "drg" {
    compartment_id = local.vcn.compartment_id
}

resource "oci_core_drg_attachment" "vcn" {
    drg_id = oci_core_drg.drg.id

    network_details {
        type = "VCN"
        id = local.vcn.id
        route_table_id = local.route_table.id
    }
}

resource "oci_core_remote_peering_connection" "hubs" {
    for_each = local.hubs

    drg_id = oci_core_drg.drg.id
    compartment_id = oci_core_drg.drg.compartment_id

    display_name = each.key
}

resource "oci_core_remote_peering_connection" "dr" {
    drg_id = oci_core_drg.drg.id
    compartment_id = oci_core_drg.drg.compartment_id
}

resource "oci_core_remote_peering_connection" "services" {
    drg_id = oci_core_drg.drg.id
    compartment_id = oci_core_drg.drg.compartment_id
}
