resource "oci_core_internet_gateway" "igw" {
    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    display_name = "Internet Gateway"
}

resource "oci_core_route_table" "ingress" {
    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    route_rules {
        description = "Default route"
        destination = local.anywhere-cidr
        network_entity_id = oci_core_internet_gateway.igw.id
    }

    display_name = "Route Table for ingress subnet"
}

resource "oci_core_subnet" "ingress" {
    for_each = local.ingress-cidrs

    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    cidr_block = each.key
    prohibit_internet_ingress = false
    prohibit_public_ip_on_vnic = false

    route_table_id = local.rt-ingress.id
}