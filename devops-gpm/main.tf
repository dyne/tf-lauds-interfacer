# <RESOURCE TYPE>.<NAME>.<ATTRIBUTE>
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.27.2"
    }
    gandi = {
      source   = "go-gandi/gandi"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.38.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "gandi" {
  personal_access_token = var.gandi_token
}

resource "hcloud_server" "gpm" {
  name        = "gpm"
  image       = "debian-12"
  server_type = "cx22"
  ssh_keys    = [var.hetzner_ssh_key_name]
}

output "instance_public_ip" {
  description = "Public IP of Hetzner cloud instance"
  value       = hcloud_server.gpm.ipv4_address
}

resource "gandi_livedns_record" "gpm" {
  zone       = var.domain
  name       = var.name
  type       = "A"
  ttl        = 300
  values     = [hcloud_server.gpm.ipv4_address]
  depends_on = [hcloud_server.gpm]
  #
  # Output the instance's public IP
  # provisioner "local-exec" {
  #   command = <<EOT
  #     echo '[gpm]' > inventory.ini
  #     echo '${self.gpm.name}.${self.gpm.zone} ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa' >> inventory.ini
  #   EOT
  # }
}

output "instance_name" {
  description = "DNS name of Hetzner cloud instance"
  value       = "${gandi_livedns_record.gpm.name}.${gandi_livedns_record.gpm.zone}"
}

resource "null_resource" "wait_for_ping" {
  depends_on = [hcloud_server.gpm]

  provisioner "local-exec" {
    command = "../ping_new.sh ${hcloud_server.gpm.ipv4_address}"
  }
}

# Run Ansible after creating the instance
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait_for_ping]

  provisioner "local-exec" {
    # command = "ansible-playbook -i ${gandi_livedns_record.gpm.name}.${gandi_livedns_record.gpm.zone}, gpm-devops/main.yaml"
    command = "ansible-playbook -i ${hcloud_server.gpm.ipv4_address}, gpm-devops/main.yaml"
  }
}

# Remove SSH key from remote host upon destroy
#resource "null_resource" "remove_remote_ssh_keys" {
#  triggers = {
#    remote_host_ip = hcloud_server.gpm.ipv4_address
#  }
#  provisioner "remote-exec" {
#    when    = destroy
#    connection {
#      host     = "${self.triggers["remote_host_ip"]}"  # Replace with your resource's IP
#      user     = "root"                                # Replace with the remote user
#      private_key = file(var.ssh_private_key_path)              # Path to your private SSH key
#    }

    # Command to delete the file
 #   inline = [
 #     "which srm && srm /root/.ssh/authorized_keys || rm /root/.ssh/authorized_keys",
 #     "[ ! -f /root/.ssh/authorized_keys ]"
  #  ]
 # }
#}

# Remove SSH key from known_hosts upon destroy
resource "null_resource" "remove_ssh_keys" {
  # depends_on = [gandi_livedns_record.gpm]
  triggers = {
    keys_id = hcloud_server.gpm.ipv4_address
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${self.triggers["keys_id"]}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "echo ${self.triggers["keys_id"]}"
  }
}

# Create a record
# resource "cloudflare_record" "tofutwo" {
#   zone_id = "dyne.im"
#   name    = "tofutwo"
#   content = hcloud_server.node1.ipv4_address
#   type    = "A"
#   ttl     = 300
# }
