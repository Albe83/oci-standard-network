output "gateway" {
  value = oci_core_internet_gateway.default
}

output "routes" {
  value = oci_core_route_table.route_table
}

output "subnets" {
  value = { for subnet in oci_core_subnet.subnets: subnet.id => subnet }
}