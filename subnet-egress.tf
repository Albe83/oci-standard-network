resource "oci_core_public_ip" "ngw" {
    compartment_id = local.vcn.compartment_id
    lifetime = "RESERVED"

    display_name = "NAT Gateway"
}

resource "oci_core_nat_gateway" "ngw" {
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    display_name = "NAT Gateway"
    public_ip_id = oci_core_public_ip.ngw.id
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
    vcn_id = local.vcn.id
    compartment_id = local.vcn.compartment_id

    cidr_block = local.egress-cidr
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-egress.id

    display_name = local.net-egress-name
}