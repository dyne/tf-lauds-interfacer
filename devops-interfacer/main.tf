#  <RESOURCE TYPE>.<NAME>.<ATTRIBUTE>
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
    # ansible = {
    #   version = "~> 1.3.0"
    #   source  = "ansible/ansible"
    # }
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

resource "hcloud_server" "interfacer" {
  name        = "interfacer.staging"
  image       = "debian-12"
  server_type = "cx22"
  ssh_keys    = ["antoniotrkdz@trkdz-d7-ceres"]
}

output "instance_public_ip" {
  description = "Public IP of Hetzner cloud instance"
  value       = hcloud_server.interfacer.ipv4_address
}

resource "gandi_livedns_record" "dyne_im" {
  zone       = "dyne.im"
  name       = var.name
  type       = "A"
  ttl        = 300
  values     = [hcloud_server.interfacer.ipv4_address]
  depends_on = [hcloud_server.interfacer]
}

resource "gandi_livedns_record" "proxy_dyne_im" {
  zone       = "dyne.im"
  name       = "proxy.${gandi_livedns_record.dyne_im.name}"
  type       = "A"
  ttl        = 300
  values     = [hcloud_server.interfacer.ipv4_address]
  depends_on = [hcloud_server.interfacer]
}

resource "gandi_livedns_record" "zenflows_dyne_im" {
  zone       = "dyne.im"
  name       = "zenflows.${gandi_livedns_record.dyne_im.name}"
  type       = "A"
  ttl        = 300
  values     = [hcloud_server.interfacer.ipv4_address]
  depends_on = [hcloud_server.interfacer]
}

output "instance_name" {
  description = "DNS name of Hetzner cloud instance"
  value       = "${gandi_livedns_record.dyne_im.name}.${gandi_livedns_record.dyne_im.zone}"
}

# Generate the inventory/hosts.yml file
data "template_file" "ansible_inventory" {
  template = <<EOT
all:
  hosts:
    ${gandi_livedns_record.dyne_im.name}.${gandi_livedns_record.dyne_im.zone}:
EOT
}

# Write the inventory file to the filesystem
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/interfacer-devops/inventory/hosts.yml"
  content  = data.template_file.ansible_inventory.rendered
}

resource "null_resource" "wait_for_ping" {
  depends_on = [hcloud_server.interfacer]

  provisioner "local-exec" {
    command = "../ping_new.sh ${gandi_livedns_record.dyne_im.name}.${gandi_livedns_record.dyne_im.zone}"
  }
}

# Run Ansible after creating the instance
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait_for_ping]

  provisioner "local-exec" {
    command = <<EOT
ansible-playbook -i ${local_file.ansible_inventory.filename} \
--vault-password-file interfacer-devops/.vault_pass \
-e domain_name=${gandi_livedns_record.dyne_im.name}.${gandi_livedns_record.dyne_im.zone} \
interfacer-devops/install-proxy.yaml
EOT
  }
}

# Remove SSH key from known_hosts upon destroy
resource "null_resource" "remove_ssh_keys" {
  # depends_on = [gandi_livedns_record.gpm_dyne_im]
  triggers = {
    keys_id = "${gandi_livedns_record.dyne_im.name}.${gandi_livedns_record.dyne_im.zone}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${self.triggers["keys_id"]}"
  }
}

# Create a record
# resource "cloudflare_record" "tofutwo" {
#   zone_id = "dyne.im"
#   name    = "tofutwo"
#   content = hcloud_server.interfacer.ipv4_address
#   type    = "A"
#   ttl     = 300
# }


# resource "ansible_vault" "secrets" {
#   vault_file          = "interfacer-devops/hosts.yaml"
#   vault_password_file = "interfacer-devops/.vault_pass"
# }

# locals {
#   decoded_vault_yaml = yamldecode(ansible_vault.secrets.yaml)["all"]["hosts"]
# }

# output "instance_name" {
#   description = "Vault decoded content"
#   value       = nonsensitive(local.decoded_vault_yaml)
# }

# 2024-12-18.17:51:54 trkdz-d7-ceres antoniotrkdz /home/antoniotrkdz/dyne/devops  2016  ansible-playbook -u root -i hosts_test.yaml --vault-pass-file .vault_pass install-proxy.yaml --key-file ~/.ssh/id_rsa

