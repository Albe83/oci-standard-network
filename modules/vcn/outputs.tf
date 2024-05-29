output "vcn" {
  value = merge(
    oci_core_vcn.vcn,
    { subnets = merge(module.workloads.subnets, module.ingress.subnets, module.egress.subnets) },
    { route_tables = {
        workload = module.workloads.routes,
        ingress = module.ingress.routes,
        egress = module.egress.routes
      }
    }
  )
}
