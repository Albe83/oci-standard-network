
resource "oci_core_drg" "drg" {
    compartment_id = oci_core_vcn.vcn.compartment_id

    display_name = format("Local DRG for %s", oci_core_vcn.vcn.display_name)
}

resource "oci_core_drg_attachment" "workload" {
    drg_id = oci_core_drg.drg.id

    network_details {
        type = "VCN"
        id = oci_core_vcn.vcn.id
        route_table_id = local.rt-workload.id
    }

    display_name = format("Remote routes for %s Workload", oci_core_vcn.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "hub1" {
    drg_id = oci_core_drg.drg.id
    compartment_id = oci_core_drg.drg.compartment_id

    display_name = format("%s to Hub1 interface", oci_core_vcn.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "hub2" {
    drg_id = oci_core_drg.drg.id
    compartment_id = oci_core_drg.drg.compartment_id

    display_name = format("%s to Hub2 interface", oci_core_vcn.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "dr" {
    drg_id = oci_core_drg.drg.id
    compartment_id = oci_core_drg.drg.compartment_id

    display_name = format("%s to DR region", oci_core_vcn.vcn.display_name)
}

resource "oci_core_remote_peering_connection" "oci" {
    drg_id = oci_core_drg.drg.id
    compartment_id = oci_core_drg.drg.compartment_id

    display_name = format("%s to OCI Regional Services", oci_core_vcn.vcn.display_name)
}