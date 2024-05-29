output "gateway" {
  value = oci_core_nat_gateway.default
}

output "routes" {
  value = oci_core_route_table.route_table
}

output "subnets" {
  value = {
    for subnet in oci_core_subnet.subnets:
      subnet.id => merge(subnet, {
        route_table = oci_core_route_table.route_table
      })
  }
}
