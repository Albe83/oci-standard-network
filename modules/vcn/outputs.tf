output "vcn" {
  value = merge(
    oci_core_vcn.vcn,
    { subnets = merge(module.workloads.subnets, module.ingress.subnets, module.egress.subnets) },
    { route_tables = {
        workload = module.workloads.route_table,
        ingress = module.ingress.route_table,
        egress = module.egress.route_table
      }
    }
  )
}
