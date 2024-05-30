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
    retention = var.log_retention
}

resource "oci_logging_log_group" "flowlogs" {
    compartment_id = local.vcn.compartment_id

    display_name = local.vcn.id
}

data "oci_core_subnets" "subnets" {
  vcn_id = local.vcn.id
  compartment_id = local.vcn.compartment_id
}

resource "oci_logging_log" "subnets" {
  for_each = data.oci_core_subnets.subnets.subnets

  log_group_id = oci_logging_log_group.flowlogs.id
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
  retention_duration = local.retention
}