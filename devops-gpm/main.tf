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

provider "cloudflare" {
  api_token = var.cloudflare_token
}

resource "hcloud_server" "gpm" {
  name        = "gpm"
  image       = "debian-12"
  server_type = "cx22"
  ssh_keys    = ["antoniotrkdz@trkdz-d7-ceres"]
}

output "instance_public_ip" {
  description = "Public IP of Hetzner cloud instance"
  value       = hcloud_server.gpm.ipv4_address
}

resource "gandi_livedns_record" "gpm_dyne_im" {
  zone       = "dyne.im"
  name       = "gpm"
  type       = "A"
  ttl        = 300
  values     = [hcloud_server.gpm.ipv4_address]
  depends_on = [hcloud_server.gpm]
  #
  # Output the instance's public IP
  # provisioner "local-exec" {
  #   command = <<EOT
  #     echo '[gpm]' > inventory.ini
  #     echo '${self.gpm_dyne_im.name}.${self.gpm_dyne_im.zone} ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa' >> inventory.ini
  #   EOT
  # }
}

output "instance_name" {
  description = "DNS name of Hetzner cloud instance"
  value       = "${gandi_livedns_record.gpm_dyne_im.name}.${gandi_livedns_record.gpm_dyne_im.zone}"
}

resource "null_resource" "wait_for_ping" {
  depends_on = [hcloud_server.gpm]

  provisioner "local-exec" {
    command = "./ping_gpm.sh ${hcloud_server.gpm.ipv4_address}"
  }
}

# Run Ansible after creating the instance
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait_for_ping]

  provisioner "local-exec" {
    # command = "ansible-playbook -i ${gandi_livedns_record.gpm_dyne_im.name}.${gandi_livedns_record.gpm_dyne_im.zone}, gpm-devops/main.yaml"
    command = "ansible-playbook -i ${hcloud_server.gpm.ipv4_address}, gpm-devops/main.yaml"
  }
}

# Remove SSH key from known_hosts upon destroy
# resource "null_resource" "remove_ssh_keys" {
#   depends_on = [hcloud_server.gpm, gandi_livedns_record.gpm_dyne_im]
#   for_each = {
#     "hcloud_server" = hcloud_server.gpm.ipv4_address
#     "gandi_record"  = "${gandi_livedns_record.gpm_dyne_im.name}.${gandi_livedns_record.gpm_dyne_im.zone}"
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOT
#     if [[ "${each.key}" == "hcloud_server" ]]; then
#       ssh-keygen -f ~/.ssh/known_hosts -R ${hcloud_server.gpm.ipv4_address}
#     elif [[ "${each.key}" == "gandi_record" ]]; then
#       ssh-keygen -f ~/.ssh/known_hosts -R ${gandi_livedns_record.gpm_dyne_im.name}.${gandi_livedns_record.gpm_dyne_im.zone}
#     fi
#     EOT
#   }
# }

# Create a record
# resource "cloudflare_record" "tofutwo" {
#   zone_id = "dyne.im"
#   name    = "tofutwo"
#   content = hcloud_server.node1.ipv4_address
#   type    = "A"
#   ttl     = 300
# }
