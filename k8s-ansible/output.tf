output "internal_ip_address_nodes" {
  value = {
    for node in yandex_compute_instance.cluster-k8s:
    node.hostname => node.network_interface.0.ip_address

  }
}
output "external_ip_address_nodes" {
  value = {
    for node in yandex_compute_instance.cluster-k8s:
    node.hostname => node.network_interface.0.nat_ip_address
  }
}

resource "local_file" "hosts" {
  content = <<-EOT
${yandex_compute_instance.cluster-k8s[0].network_interface.0.nat_ip_address} ${yandex_compute_instance.cluster-k8s[1].network_interface.0.nat_ip_address} ${yandex_compute_instance.cluster-k8s[2].network_interface.0.nat_ip_address}
  EOT
  filename = "./hosts.ini"
}
