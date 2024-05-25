resource "oci_logging_log_group" "flowlogs" {
    compartment_id = local.vcn.compartment_id

    display_name = local.vcn.id
    description = format("Network Logs from VCN: %s", local.vcn.display_name)
}

resource "oci_logging_log" "vcn" {
  display_name = local.vcn.display_name
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

resource "oci_logging_log" "subnets" {
  for_each = merge(
    { for cidr, subnet in oci_core_oci_core_subnet.workloads[*]: subnet.id => subnet },
    { for cidr, subnet in oci_core_oci_core_subnet.ingress[*]: subnet.id => subnet },
    { for cidr, subnet in oci_core_oci_core_subnet.egress[*]: subnet.id => subnet }
  )

  log_group_id = oci_logging_log_group.flowlogs.id
  display_name = each.value.display_name
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
  retention_duration = local.log-retention
}
