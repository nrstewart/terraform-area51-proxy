resource "openstack_compute_secgroup_v2" "proxy" {
  name = "ssh_proxy"
  description = "ssh passthrough proxy access"
  rule {
    from_port = 2200
    to_port = 2200
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 2200
    to_port = 2200
    ip_protocol = "tcp"
    cidr = "::/0"
  }
  rule {
    from_port = 2300
    to_port = 2300
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 2300
    to_port = 2300
    ip_protocol = "tcp"
    cidr = "::/0"
  }
  rule {
    from_port = 2400
    to_port = 2400
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 2400
    to_port = 2400
    ip_protocol = "tcp"
    cidr = "::/0"
  }
  rule {
    from_port = 2500
    to_port = 2500
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 2500
    to_port = 2500
    ip_protocol = "tcp"
    cidr = "::/0"
  }
}

resource "openstack_networking_network_v2" "fwf_net" {
  name = "comforting_illusion_of_reality"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "fwf_subnet" {
  name = "Essex_County"
  network_id = "${openstack_networking_network_v2.fwf_net.id}"
  ip_version = 4
  cidr = "192.168.1.0/24"
  enable_dhcp = "true"
}

resource "openstack_networking_network_v2" "sec_net" {
  name = "seething_cosmic_chaos"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "sec_subnet" {
  name = "outside_time_and_space"
  network_id = "${openstack_networking_network_v2.sec_net.id}"
  ip_version = 4
  cidr = "192.168.0.0/24"
  gateway_ip = "192.168.0.254"
  enable_dhcp = "true"
}

resource "openstack_networking_router_v2" "border_router" {
  name = "Nyarlathotep"
}

resource "openstack_networking_router_interface_v2" "router_interface_earth" {
  router_id = "${openstack_networking_router_v2.border_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.fwf_subnet.id}"
}

resource "openstack_networking_router_interface_v2" "router_interface_ots" {
  router_id = "${openstack_networking_router_v2.border_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.sec_subnet.id}"
}

resource "openstack_networking_router_route_v2" "internet_access" {
  depends_on = ["openstack_networking_router_interface_v2.router_interface_earth"]
  router_id = "${openstack_networking_router_v2.border_router.id}"
  destination_cidr = "0.0.0.0/0"
  next_hop = "192.168.1.254"
}

resource "openstack_compute_instance_v2" "proxy" {
  name = "Dunwich"
  depends_on = [
    "openstack_networking_subnet_v2.fwf_subnet"
  ]
  image_id = "e28a0633-5ddc-450b-a760-2cd61d3051b8"
  flavor_name = "m1.tiny"
  key_pair = "neil"
  security_groups = [
    "${openstack_compute_secgroup_v2.proxy.name}",
    "default",
  ]
  network {
    name = "default"
    floating_ip = "162.246.157.234"
    access_network = "True"
  }
  network {
    name = "${openstack_networking_network_v2.fwf_net.name}"
    fixed_ip_v4 = "192.168.1.254"
  }
   connection {
    user = "ubuntu"
    host = "${openstack_compute_instance_v2.proxy.access_ip_v4}"
    private_key = "~/.ssh/id_rsa.dec"
  }
  provisioner "file" {
    source = "files/openrc"
    destination = "/home/ubuntu/openrc"
  }
  provisioner "file" {
    source = "bootstrap/proxy.sh"
    destination = "/home/ubuntu/proxy.sh"
   }
  provisioner "file" {
    source = "~/.ssh/id_rsa.dec"
    destination = "/home/ubuntu/.ssh/id_rsa"
   }
  provisioner "file" {
    source = "files/eth1.cfg"
    destination = "/home/ubuntu/eth1.cfg"
   }
  provisioner "file" {
    source = "files/ssh_config"
    destination = "/home/ubuntu/.ssh/config"
   }
  provisioner "remote-exec" {
    inline = [
      "chmod 700 ~/.ssh/id_rsa",
      "chmod +x ~/proxy.sh",
      "~/proxy.sh"
    ]
  }
}

resource "openstack_compute_instance_v2" "peer_1" {
  name = "Innsmouth"
  depends_on = [
    "openstack_networking_subnet_v2.fwf_subnet"
  ]
  image_id = "e28a0633-5ddc-450b-a760-2cd61d3051b8"
  flavor_name = "m1.tiny"
  key_pair = "neil"
  security_groups = [
    "default",
  ]
  network {
    name = "${openstack_networking_network_v2.fwf_net.name}"
    access_network = "True"
  }
  connection {
    bastion_user = "ubuntu"
    bastion_host = "${openstack_compute_instance_v2.proxy.access_ip_v4}"
    bastion_private_key = "~/.ssh/id_rsa.dec"
    user = "ubuntu"
    host = "${openstack_compute_instance_v2.peer_1.access_ip_v4}"
    private_key = "~/.ssh/id_rsa.dec"
  }
  provisioner "file" {
    source = "~/.ssh/id_rsa.dec"
    destination = "/home/ubuntu/.ssh/id_rsa"
   }
  provisioner "file" {
    source = "files/ssh_config"
    destination = "/home/ubuntu/.ssh/config"
   }
  provisioner "file" {
    source = "bootstrap/passthrough.sh"
    destination = "/home/ubuntu/passthrough.sh"
   }
  provisioner "remote-exec" {
    inline = [
      "chmod 700 ~/.ssh/id_rsa",
      "chmod +x ~/passthrough.sh",
      "~/passthrough.sh"
    ]
  }
}

resource "openstack_compute_instance_v2" "box" {
  name = "Shub-Niggurath"
  image_id = "e28a0633-5ddc-450b-a760-2cd61d3051b8"
  flavor_name = "m1.small"
  key_pair = "neil"
  security_groups = [
    "default",
  ]
  network {
    uuid = "${openstack_networking_subnet_v2.sec_subnet.network_id}"
    access_network = "true"
  }
  connection {
    bastion_user = "ubuntu"
    bastion_host = "${openstack_compute_instance_v2.proxy.access_ip_v4}"
    bastion_private_key = "~/.ssh/id_rsa.dec"
    user = "ubuntu"
    host = "${openstack_compute_instance_v2.box.access_ip_v4}"
    private_key = "~/.ssh/id_rsa.dec"
  }
  provisioner "file" {
    source = "~/.ssh/id_rsa.dec"
    destination = "/home/ubuntu/.ssh/id_rsa"
   }
  provisioner "file" {
    source = "files/ssh_config"
    destination = "/home/ubuntu/.ssh/config"
   }
  provisioner "file" {
    source = "bootstrap/passthrough.sh"
    destination = "/home/ubuntu/passthrough.sh"
   }
  provisioner "remote-exec" {
    inline = [
      "chmod 700 ~/.ssh/id_rsa",
      "chmod +x ~/passthrough.sh",
      "~/passthrough.sh"
    ]
   }
}

resource "openstack_compute_instance_v2" "piaf" {
  name = "Azathoth"
  image_id = "e28a0633-5ddc-450b-a760-2cd61d3051b8"
  flavor_name = "m1.small"
  key_pair = "neil"
  security_groups = [
    "default",
  ]
  network {
    uuid = "${openstack_networking_subnet_v2.sec_subnet.network_id}"
    access_network = "true"
  }
  connection {
    bastion_user = "ubuntu"
    bastion_host = "${openstack_compute_instance_v2.proxy.access_ip_v4}"
    bastion_private_key = "~/.ssh/id_rsa.dec"
    user = "ubuntu"
    host = "${openstack_compute_instance_v2.piaf.access_ip_v4}"
    private_key = "~/.ssh/id_rsa.dec"
  }
  provisioner "file" {
    source = "~/.ssh/id_rsa.dec"
    destination = "/home/ubuntu/.ssh/id_rsa"
   }
  provisioner "file" {
    source = "files/ssh_config"
    destination = "/home/ubuntu/.ssh/config"
   }
  provisioner "file" {
    source = "bootstrap/passthrough.sh"
    destination = "/home/ubuntu/passthrough.sh"
   }
  provisioner "remote-exec" {
    inline = [
      "chmod 700 ~/.ssh/id_rsa",
      "chmod +x ~/passthrough.sh",
      "~/passthrough.sh"
    ]
   }
}

resource "openstack_compute_instance_v2" "xmpp" {
  name = "Yog-Sothoth"
  image_id = "e28a0633-5ddc-450b-a760-2cd61d3051b8"
  flavor_name = "m1.small"
  key_pair = "neil"
  security_groups = [
    "default",
  ]
  network {
    uuid = "${openstack_networking_subnet_v2.sec_subnet.network_id}"
    access_network = "true"
  }
  connection {
    bastion_user = "ubuntu"
    bastion_host = "${openstack_compute_instance_v2.proxy.access_ip_v4}"
    bastion_private_key = "~/.ssh/id_rsa.dec"
    user = "ubuntu"
    host = "${openstack_compute_instance_v2.xmpp.access_ip_v4}"
    private_key = "~/.ssh/id_rsa.dec"
  }
  provisioner "file" {
    source = "~/.ssh/id_rsa.dec"
    destination = "/home/ubuntu/.ssh/id_rsa"
   }
  provisioner "file" {
    source = "files/ssh_config"
    destination = "/home/ubuntu/.ssh/config"
   }
  provisioner "file" {
    source = "bootstrap/passthrough.sh"
    destination = "/home/ubuntu/passthrough.sh"
   }
  provisioner "remote-exec" {
    inline = [
      "chmod 700 ~/.ssh/id_rsa",
      "chmod +x ~/passthrough.sh",
      "~/passthrough.sh"
    ]
   }
}
