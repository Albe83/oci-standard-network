resource "oci_logging_log_group" "flowlogs" {
    compartment_id = oci_core_vcn.vcn.compartment_id

    display_name = oci_core_vcn.vcn.id
    description = format("Network Logs from VCN: %s", oci_core_vcn.vcn.display_name)
}

resource "oci_logging_log" "vcn" {
  display_name = oci_core_vcn.vcn.display_name
  log_group_id = oci_logging_log_group.flowlogs.id
  log_type = "SERVICE"

  configuration {
    source {
      category  = "vcn"
      service = "flowlogs"
      source_type = "OCISERVICE"
      resource = oci_core_vcn.vcn.id
    }
  }

  is_enabled = true
  retention_duration = local.log-retention
}

resource "oci_logging_log" "subnets" {
  for_each = tomap(merge(
    oci_core_subnet.workloads,
    oci_core_subnet.ingress,
    oci_core_subnet.ingress
  ))

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
  retention_duration = local.log-retention

  depends_on = [
    oci_core_subnet.workloads, oci_core_subnet.ingress, oci_core_subnet.egress
  ]
}
