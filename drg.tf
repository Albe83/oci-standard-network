
resource "oci_core_drg" "drg" {
    compartment_id = local.vcn.compartment_id

    display_name = format("Local DRG for %s", local.vcn.display_name)
}

resource "oci_core_drg_attachment" "workload" {
    drg_id = local.drg.id

    network_details {
        type = "VCN"
        id = local.vcn.id
        route_table_id = local.rt-workload.id
    }

    display_name = format("Remote routes for %s Workload", local.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "hub" {
    drg_id = local.drg.id
    compartment_id = local.drg.compartment_id

    display_name = format("%s to HUB interface", local.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "dr" {
    drg_id = local.drg.id
    compartment_id = local.drg.compartment_id

    display_name = format("%s to DR region", local.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "oci" {
    drg_id = local.drg.id
    compartment_id = local.drg.compartment_id

    display_name = format("%s to OCI Regional Services", local.vcn.display_name)
}