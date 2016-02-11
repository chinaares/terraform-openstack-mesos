/*********************************
 * Provider Configuration        *
 *********************************/
provider "openstack" {
/*
   The necessary input to configure OpenStack as the provider
   will be picked up from the following env vars. Make sure
   that they are set appropriately.
      OS_USERNAME
      OS_TENANT_NAME
      OS_PASSWORD
      OS_AUTH_URL
*/
}


/*********************************
 * Resources                     *
 *********************************/
resource "openstack_compute_secgroup_v2" "ssh_config_server" {
   name = "ssh_config_server"
   description = "Enable SSH to the config server"
   rule {
      from_port = 22
      to_port = 22
      ip_protocol = "tcp"
      cidr = "0.0.0.0/0"
   }
}

resource "openstack_compute_secgroup_v2" "ssh_mesos_cluster" {
   name = "ssh_mesos_cluster"
   description = "Enable SSH to the mesos masters & slaves"
   rule {
      from_port = 22
      to_port = 22
      ip_protocol = "tcp"
      cidr = "10.0.0.0/24"
   }
}

resource "openstack_networking_network_v2" "mesos_net" {
   name = "mesos_net"
   admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "mesos_subnet" {
   name = "mesos_subnet"
   network_id = "${openstack_networking_network_v2.mesos_net.id}"
   cidr = "10.0.0.0/24"
   dns_nameservers = ["${var.dns_server1}", "${var.dns_server2}"]
   ip_version = 4
}

resource "openstack_networking_router_v2" "mesos_gw_rtr" {
   name = "mesos_gw_rtr"
   external_gateway = "${var.public_net_id}"
}

resource "openstack_networking_router_interface_v2" "mesos_gw_intf" {
   router_id = "${openstack_networking_router_v2.mesos_gw_rtr.id}"
   subnet_id = "${openstack_networking_subnet_v2.mesos_subnet.id}"
}

resource "openstack_compute_floatingip_v2" "floatingip" {
   depends_on = ["openstack_networking_router_interface_v2.mesos_gw_intf"]
   pool = "${var.floating_ip_pool}"
}


resource "openstack_compute_keypair_v2" "keypair" {
   name = "Mesos-Key-Pair"
   public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_compute_instance_v2" "config_server" {
   name = "config_server"
   image_name = "${var.image}"
   flavor_name = "${var.flavor}"
   key_pair = "${openstack_compute_keypair_v2.keypair.name}"
   security_groups = ["${openstack_compute_secgroup_v2.ssh_config_server.name}"]

   network {
      name = "${openstack_networking_network_v2.mesos_net.name}"
      floating_ip = "${openstack_compute_floatingip_v2.floatingip.address}"
   }
}

resource "openstack_compute_instance_v2" "mesos_masters" {
   count = 3
   depends_on = ["openstack_compute_instance_v2.config_server"]
   name = "mesos_master_${count.index + 1}"
   image_name = "${var.image}"
   flavor_name = "${var.flavor}"
   key_pair = "${openstack_compute_keypair_v2.keypair.name}"
   security_groups = ["${openstack_compute_secgroup_v2.ssh_mesos_cluster.name}"]
   network {
      name = "${openstack_networking_network_v2.mesos_net.name}"
   }
}

resource "null_resource" "prep_config_server" {
   triggers {
      instance_ids = "${openstack_compute_instance_v2.config_server.id}"
   }
   connection {
      host = "${openstack_compute_instance_v2.config_server.network.0.floating_ip}"
      user = "${var.ssh_user_name}"
      private_key = "${file("${var.ssh_key_file}")}"
   }

   provisioner "file" {
      # Script to prepare the config server
      source = "scripts/prep-config-server.sh"
      destination = "~/prep-config-server.sh"
   }

   provisioner "file" {
      # Script to update the ansible inventory files for masters
      source = "scripts/update-inventory-masters.sh"
      destination = "~/update-inventory-masters.sh"
   }

   provisioner "file" {
      # Script to update the ansible inventory files for slaves
      source = "scripts/update-inventory-slaves.sh"
      destination = "~/update-inventory-slaves.sh"
   }

   provisioner "file" {
      # Ansible config file
      source = "confs/ansible.cfg"
      destination = "~/.ansible.cfg"
   }

   provisioner "file" {
      # SSH private key. config server will need this to ssh
      # to the masters & slaves
      source = "${var.ssh_key_file}"
      destination = "~/.ssh/id_rsa"
   }

   provisioner "remote-exec" {
      inline = [
         "chmod +x ~/prep-config-server.sh",
         "chmod +x ~/update-inventory-masters.sh",
         "chmod +x ~/update-inventory-slaves.sh",
         "chmod 600 ~/.ssh/id_rsa",
         "~/prep-config-server.sh"
      ]
   }
}

resource "null_resource" "prep_mesos_masters" {
   depends_on = ["null_resource.prep_config_server"]
   triggers {
      instance_ids = "${join(", ", openstack_compute_instance_v2.mesos_masters.*.id)}"
   }

   connection {
      host = "${openstack_compute_instance_v2.config_server.network.0.floating_ip}"
      user = "${var.ssh_user_name}"
      private_key = "${file("${var.ssh_key_file}")}"
   }

   provisioner "remote-exec" {
      inline = [
         "~/update-inventory-masters.sh ${join(" ", openstack_compute_instance_v2.mesos_masters.*.network.0.fixed_ip_v4)}",
      ]
   }
}
