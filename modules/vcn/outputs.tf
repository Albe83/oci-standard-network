output "vcn" {
  value = merge(
    oci_core_vcn.vcn, { subnets = merge(
      module.workloads.subnets,
      module.ingress.subnets,
      module.egress.subnets
    )}
  )
}
