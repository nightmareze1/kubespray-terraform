# kubespray-terraform 

[![Greenkeeper badge](https://badges.greenkeeper.io/nightmareze1/kubespray-terraform.svg)](https://greenkeeper.io/)

I running Kubernetes with kubespray in Centos 7 using HAPROXY to loadbalancer Kubernetes_API,http and http traffic ports using Traefik ingress.

- based in this documentation:

https://blog.openshift.com/haproxy-highly-available-keepalived/

https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ha-mode.md

https://blog.inkubate.io/install-and-manage-automatically-a-kubernetes-cluster-on-vmware-vsphere-with-terraform-and-kubespray/

Regards!!!

# Requirements:

   - Terraform v0.11.11 ( provider.vsphere v1.9.0)
    
   - Ansible 2.7.5 
    
   - Python Library (details in kubespray requirements.yml)
    
   - Deploy HAPROXY HA.
   
1- Clone kubespray repository
```
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# pip install -r requirements.txt

```
2- Configure kubespray ansible inventory , you need copy sample directory to prd 
```
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# cp -rfp inventory/sample inventory/prod

root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# ls -la inventory/
total 12
drwxr-xr-x  3 root root 4096 Dec 16 17:04 .
drwxr-xr-x 12 root root 4096 Dec 26 17:11 ..
drwxr-xr-x  3 root root 4096 Dec 20 10:13 prod
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# ls -la inventory/prod/
total 16
drwxr-xr-x 3 root root 4096 Dec 20 10:13 .
drwxr-xr-x 3 root root 4096 Dec 16 17:04 ..
drwxr-xr-x 4 root root 4096 Dec 16 19:40 group_vars
-rw-r--r-- 1 root root  474 Dec 20 10:13 hosts.ini
```
```
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# cat inventory/prod/hosts.ini
```
```
[all]
node1 	 ansible_host=172.16.250.180 ip=172.16.250.180
node2 	 ansible_host=172.16.250.181 ip=172.16.250.181
node3 	 ansible_host=172.16.250.182 ip=172.16.250.182
node4 	 ansible_host=172.16.250.190 ip=172.16.250.190
node5 	 ansible_host=172.16.250.191 ip=172.16.250.191

[kube-master]
node1
node2
node3

[kube-node]
node1
node2
node3
node4
node5

[etcd]
node1
node2
node3

[k8s-cluster:children]
kube-node
kube-master

[calico-rr]
```

3- Configure VIP HAPROXY in kubespray all.yml
```
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# cat inventory/prod/group_vars/all/all.yml

## External LB example config
#apiserver_loadbalancer_domain_name: "elb.apps.stg.itshellws-k8s.com"
loadbalancer_apiserver:
  address: 172.16.250.150
  port: 6443
```  
- Check git diff of principal kubespray repository and mylocal(you need change this for use mycentos 7 template).
```
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# git diff roles/container-engine/docker/handlers/main.yml
diff --git a/roles/container-engine/docker/handlers/main.yml b/roles/container-engine/docker/handlers/main.yml
index a43d843..6172d79 100644
--- a/roles/container-engine/docker/handlers/main.yml
+++ b/roles/container-engine/docker/handlers/main.yml
@@ -17,10 +17,17 @@
     state: restarted
   when: ansible_os_family in ['CoreOS', 'Container Linux by CoreOS']

- name: Docker | reload docker
   service:
     name: docker
     state: restarted
+    force: yes
+  ignore_errors: true
```

```
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# git diff roles/container-engine/docker/tasks/main.yml

diff --git a/roles/container-engine/docker/tasks/main.yml b/roles/container-engine/docker/tasks/main.yml
index 1b3c629..3d92386 100644
--- a/roles/container-engine/docker/tasks/main.yml
+++ b/roles/container-engine/docker/tasks/main.yml
@@ -134,8 +134,8 @@
     update_cache: "{{ omit if ansible_distribution == 'Fedora' else True }}"
   register: docker_task_result
   until: docker_task_result is succeeded
-  retries: 4
-  delay: "{{ retry_stagger | d(3) }}"
+  retries: 10
+  delay: "{{ retry_stagger | d(8) }}"
   with_items: "{{ docker_package_info.pkgs }}"
   notify: restart docker
   when: not (ansible_os_family in ["CoreOS", "Container Linux by CoreOS"] or is_atomic) and (docker_package_info.pkgs|length > 0)
@@ -167,7 +167,8 @@
 - name: ensure service is started if docker packages are already present
   service:
     name: docker
-    state: started
+    state: restarted
+  ignore_errors: true
   when: docker_task_result is not changed
```
4 - Create a new directory outside kubespray and clone haproxy-ansible-kubernetes
```
git clone https://github.com/nightmareze1/haproxy-ansible-kubernetes.git
```

5- Create VMware template with Centos7
   - Install Centos7 minimal with 2 disk in LVM
   - SO- disk0 
   - Docker_Volume- disk1
  
Later, running the all commands details in centos7_template.yml the final step is copy you ssh-keys :
```
ssh-copy-id root@centos7machine

test ssh conection, it's if success convert the virtual machine in template.
ssh root@centos7machine
```

6- Follow this readme https://github.com/nightmareze1/haproxy-ansible-kubernetes/blob/master/README.md

7- if haproxy is running correctly , you can advanced to next step. 

# Launch terraform infraesctucture for k8s cluster without HAPROXY.

- For running terraform you need configure you vcenter_cluster,datastore,template-name and the same nodes-ip's that kube-spray inventory.

```
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
  name          = "clusters/Centos7"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


resource "vsphere_virtual_machine" "kub0" {
  name             = "kub0 - 172.16.250.180"
  resource_pool_id = "${data.vsphere_resource_pool.pool-1.id}"
  datastore_id     = "${data.vsphere_datastore.sas-datastore.id}"
  folder           = "clusters"
  num_cpus = 4
  memory   = 4096
  guest_id = "centos64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk1"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
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
   guest_id = "centos64Guest"
   scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


   network_interface {
     network_id = "${data.vsphere_network.network.id}"
   }

   disk {
    label            = "disk1"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
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
   guest_id = "centos64Guest"
   scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


   network_interface {
     network_id = "${data.vsphere_network.network.id}"
   }
   disk {
    label            = "disk1"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
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
  guest_id = "centos64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk1"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
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
  guest_id = "centos64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk1"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
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
```
- Launch terraform plan

root@jenkins:/home/zz/kubernetes/kube-spray/terraform# ./terraform plan

Plan: 5 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

root@jenkins:/home/zz/kubernetes/kube-spray/terraform# ./terraform apply -auto-approve

- Later that Terraform plan is success you can running ansible kubespray.
```
root@jenkins:/home/zz/kubernetes/kube-spray# cd kubespray/
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# ls
ansible.cfg    cluster.yml         contrib          Dockerfile  extra_playbooks  library  Makefile      OWNERS          README.md   remove-node.yml   reset.yml  scale.yml  SECURITY_CONTACTS  setup.py  upgrade-cluster.yml
cluster.retry  code-of-conduct.md  CONTRIBUTING.md  docs        inventory        LICENSE  mitogen.yaml  OWNERS_ALIASES  RELEASE.md  requirements.txt  roles      scripts    setup.cfg          tests     Vagrantfile
```
```
root@jenkins:/home/zz/kubernetes/kube-spray/kubespray# sudo ansible-playbook -i inventory/prod/hosts.ini --become --become-user=root cluster.yml -vvvv

root@jenkins:/kubespray# sudo ansible-playbook -i inventory/prod/hosts.ini --become --become-user=root cluster.yml -vvvv
```

