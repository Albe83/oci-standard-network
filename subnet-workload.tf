resource "oci_core_route_table" "workload" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "Route Table for Workload subnets"
}

resource "oci_core_subnet" "workloads" {
    for_each = local.workload-cidrs

    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = each.key
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-workload.id

    # display_name = format(local.net-workloads-name, each.key)
    display_name = format("Workload-%02d", index(local.workload-cidrs, each.key) + 1)
}

resource "oci_logging_log" "workloads" {
  for_each = local.net-workloads

  display_name = each.value.id
  log_group_id = local.log-group.id
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