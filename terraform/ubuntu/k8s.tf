provider "vsphere" {
   user           = "Administrator@vsphere.local"
   password       = "PEPITOOOO"
   vsphere_server = "VCENTER_IP"
   allow_unverified_ssl = "true"
 }

data "vsphere_datacenter" "dc" {
  name = "DATACENTER"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "sas-datastore" {
  name          = "sas-datastore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "ssd-datastore" {
  name          = "ssd-datastore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "clusters"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool-1" {
   name          = "clusters-1"
   datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "vlan-default"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "clusters/Ubuntu16"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


resource "vsphere_virtual_machine" "kub0" {
  name             = "kub0 - 172.16.250.180"
  resource_pool_id = "${data.vsphere_resource_pool.pool-1.id}"
  datastore_id     = "${data.vsphere_datastore.sas-datastore.id}"
  folder           = "clusters"
  num_cpus = 4
  memory   = 4096
  guest_id = "ubuntu64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label             = "disk0"
     unit_number      =  0
     size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
     eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
     thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
   }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "kub0"
        domain    = "itshell.local"
      }

      network_interface {
        ipv4_address = "172.16.250.180"
        ipv4_netmask = 24
      }

      ipv4_gateway = "172.16.250.1"
      dns_server_list = ["172.16.250.2"]
    }
  }
}

 resource "vsphere_virtual_machine" "kub1" {
   name             = "kub1 - 172.16.250.181"
   resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
   datastore_id     = "${data.vsphere_datastore.datastore.id}"
   folder           = "clusters"
   num_cpus = 4
   num_cores_per_socket = 2
   memory   = 2560
   guest_id = "ubuntu64Guest"
   scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


   network_interface {
     network_id = "${data.vsphere_network.network.id}"
   }

   disk {
     label             = "disk0"
      unit_number      =  0
      size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
      eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
      thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    }

   clone {
     template_uuid = "${data.vsphere_virtual_machine.template.id}"

     customize {
       linux_options {
         host_name = "kub1"
         domain    = "itshell.local"
       }

       network_interface {
         ipv4_address = "172.16.250.181"
         ipv4_netmask = 24
       }

       ipv4_gateway = "172.16.250.1"
       dns_server_list = ["172.16.250.2"]
     }
   }
 }

 resource "vsphere_virtual_machine" "kub2" {
   name             = "kub2 - 172.16.250.182"
   resource_pool_id = "${data.vsphere_resource_pool.pool-1.id}"
   datastore_id     = "${data.vsphere_datastore.sas-datastore.id}"
   host_system_id   = "host-183"
   folder           = "clusters"
   num_cpus = 4
   num_cores_per_socket = 2
   memory   = 2048
   guest_id = "ubuntu64Guest"
   scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


   network_interface {
     network_id = "${data.vsphere_network.network.id}"
   }

   disk {
     label             = "disk0"
      unit_number      =  0
      size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
      eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
      thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    }

   clone {
     template_uuid = "${data.vsphere_virtual_machine.template.id}"

     customize {
       linux_options {
         host_name = "kub2"
         domain    = "itshell.local"
       }

       network_interface {
         ipv4_address = "172.16.250.182"
         ipv4_netmask = 24
       }

       ipv4_gateway = "172.16.250.1"
       dns_server_list = ["172.16.250.2"]
     }
   }
 }

resource "vsphere_virtual_machine" "minion0" {
  name             = "minion0 - 172.16.250.190"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "clusters"
  num_cpus = 2
  memory   = 3048
  guest_id = "ubuntu64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label             = "disk0"
     unit_number      =  0
     size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
     eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
     thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
   }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "minion0"
        domain    = "itshell.local"
      }

      network_interface {
        ipv4_address = "172.16.250.190"
        ipv4_netmask = 24
      }

      ipv4_gateway = "172.16.250.1"
      dns_server_list = ["172.16.250.2"]
    }
  }
}

resource "vsphere_virtual_machine" "minion1" {
  name             = "minion1 - 172.16.250.191"
  resource_pool_id = "${data.vsphere_resource_pool.pool-1.id}"
  datastore_id     = "${data.vsphere_datastore.ssd-datastore.id}"
  folder           = "clusters"
  num_cpus = 4
  num_cores_per_socket = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label             = "disk0"
     unit_number      =  0
     size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
     eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
     thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
   }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "minion1"
        domain    = "itshell.local"
      }

      network_interface {
        ipv4_address = "172.16.250.191"
        ipv4_netmask = 24
      }

      ipv4_gateway = "172.16.250.1"
      dns_server_list = ["172.16.250.2"]
    }
  }
}
