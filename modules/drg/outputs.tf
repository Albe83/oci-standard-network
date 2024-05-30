output "rpcs" {
  value = { for rpc in oci_coci_core_remote_peering_connection.hubs: rpc.id => rpc }
}
