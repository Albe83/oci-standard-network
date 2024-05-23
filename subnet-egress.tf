resource "oci_core_public_ip" "ngw" {
    count = local.egress-ip-id == null ? 1 : 0
    
    compartment_id = local.vcn.compartment_id
    lifetime = "RESERVED"

    display_name = "NAT Gateway"
}

resource "oci_core_nat_gateway" "ngw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "NAT Gateway"
    public_ip_id = coalesce(local.egress-ip-id, try(oci_core_public_ip.ngw[0].id, null))
}

resource "oci_core_route_table" "egress" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere-cidr
        network_entity_id = local.ngw.id
    }

    display_name = "Route Table for Egress subnet"
}

resource "oci_core_subnet" "egress" {
    for_each = local.egress-cidrs

    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = each.key
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-egress.id

    display_name = format(local.net-egress-name, each.key)
}

resource "oci_logging_log" "egress" {
  for_each = local.net-egress

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