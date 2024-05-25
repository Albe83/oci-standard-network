resource "oci_core_public_ip" "ngw" {
    count = local.egress-ip-id == null ? 1 : 0
    
    compartment_id = oci_core_vcn.vcn.compartment_id
    lifetime = "RESERVED"

    display_name = "NAT Gateway"
}

resource "oci_core_nat_gateway" "ngw" {
    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    display_name = "NAT Gateway"
    public_ip_id = coalesce(local.egress-ip-id, try(oci_core_public_ip.ngw[0].id, null))
}

resource "oci_core_route_table" "egress" {
    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere-cidr
        network_entity_id = oci_core_nat_gateway.ngw.id
    }

    display_name = "Route Table for Egress subnet"
}

resource "oci_core_subnet" "egress" {
    for_each = local.egress-cidrs

    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    cidr_block = each.key
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-egress.id
}