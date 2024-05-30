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
  compartment_id = local.vcn.compartment_id

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

resource "oci_logging_log" "subnets" {
  for_each = oci_core_subnet.subnets

  log_group_id = local.vcn.log_group.id
  display_name = each.value.id
  log_type = "SERVICE"

  configuration {
    source {
      category  = "all"
      service = "flowlogs"
      source_type = "OCISERVICE"
      resource = each.value.id
    }
  }

  is_enabled = true
  retention_duration = 30
}