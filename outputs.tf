/*********************************
 * Output Variables              *
 *********************************/
output "config_server_ip" {
   value = "${openstack_compute_instance_v2.config_server.network.0.floating_ip}"
}

output "mesos_master_ips" {
   value = "${join(", ", openstack_compute_instance_v2.mesos_masters.*.network.0.fixed_ip_v4)}"
}

output "vpn_server_ip" {
   value = "${openstack_compute_instance_v2.vpn_server.network.0.floating_ip}"
}

output "vpn_clients_store_path" {
   value = "${openstack_compute_instance_v2.config_server.network.0.floating_ip}:ubuntu@config-server:~/ansible/playbooks/clients"
}

output "mesos_master" {
   value = "${var.master}"
}

output "mesos_slave" {
   value = "${var.slave}"
}

