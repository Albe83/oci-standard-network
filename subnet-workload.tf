resource "oci_core_route_table" "workload" {
    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    display_name = "Route Table for Workload subnets"
}

resource "oci_core_subnet" "workloads" {
    for_each = local.workload-cidrs

    vcn_id = oci_core_vcn.vcn.id
    compartment_id = oci_core_vcn.vcn.compartment_id

    cidr_block = each.key
    prohibit_internet_ingress = true
    prohibit_public_ip_on_vnic = true

    route_table_id = local.rt-workload.id
}