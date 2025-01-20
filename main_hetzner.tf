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
    # cloudflare = {
    #   source  = "cloudflare/cloudflare"
    #   version = "4.38.0"
    # }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
}
provider "hcloud" {
  token = var.hcloud_token
}
provider "gandi" {
  personal_access_token = var.gandi_token
}
# resource "hcloud_server" "node2" {
# provider "cloudflare" {
#   api_token = var.cloudflare_token
# }
resource "hcloud_server" "node1" {
  name        = "node1"
  image       = "debian-12"
  server_type = "cx22"
  ssh_keys    = ["antoniotrkdz@trkdz-d7-ceres"]
}

output "instance_public_ip" {
  description = "Public IP of Hetzner cloud instance"
  value     = hcloud_server.node2.ipv4_address
}

resource "gandi_livedns_record" "tofu_dyne_im" {
  zone = "dyne.im"
  name = "tofu"
  type = "A"
  ttl = 300
  values = [hcloud_server.node2.ipv4_address] //["127.0.0.2"]
  depends_on = [
    hcloud_server.node2
  ]
}
  value       = hcloud_server.node1.ipv4_address
}

resource "gandi_livedns_record" "tofu_dyne_im" {
  zone       = "dyne.im"
  name       = "interfacer-test"
  type       = "A"
  ttl        = 3600
  values     = [hcloud_server.node1.ipv4_address] //["127.0.0.2"]
  depends_on = [hcloud_server.node1]
}

resource "gandi_livedns_record" "tofu_proxy_dyne_im" {
  zone       = "dyne.im"
  name       = "proxy.${gandi_livedns_record.tofu_dyne_im.name}"
  type       = "A"
  ttl        = 3600
  values     = [hcloud_server.node1.ipv4_address]
  depends_on = [hcloud_server.node1]
}

resource "gandi_livedns_record" "tofu_zenflows_dyne_im" {
  zone       = "dyne.im"
  name       = "zenflows.${gandi_livedns_record.tofu_dyne_im.name}"
  type       = "A"
  ttl        = 3600
  values     = [hcloud_server.node1.ipv4_address]
  depends_on = [hcloud_server.node1]
}

# Create a record
# resource "cloudflare_record" "tofutwo" {
#   zone_id = "dyne.im"
#   name    = "tofutwo"
#   content = hcloud_server.node1.ipv4_address
#   type    = "A"
#   ttl     = 300
# }


# resource "ansible_vault" "secrets" {
#   vault_file          = "interfacer-devops/hosts.yml"
#   vault_password_file = "interfacer-devops/.vault_pass"
# }


# locals {
#   decoded_vault_yaml = yamldecode(ansible_vault.secrets.yaml)
# }

# resource "ansible_host" "host" {
#   name   = "${gandi_livedns_record.tofu_dyne_im.name}.${gandi_livedns_record.tofu_dyne_im.zone}"
#   groups = ["all"]

#   variables = {
#     greetings   = "from host!"
#     some        = "variable"
#     yaml_hello  = local.decoded_vault_yaml.hello
#     yaml_number = local.decoded_vault_yaml.a_number

#     # using jsonencode() here is needed to stringify 
#     # a list that looks like: [ element_1, element_2, ..., element_N ]
#     yaml_list = jsonencode(local.decoded_vault_yaml.a_list)
#   }
# }

# resource "ansible_group" "group" {
#   name     = "somegroup"
#   children = ["somechild"]
#   variables = {
#     hello = "from group!"
#   }
# }

output "instance_name" {
  description = "DNS name of Hetzner cloud instance"
  value       = "${gandi_livedns_record.tofu_dyne_im.name}.${gandi_livedns_record.tofu_dyne_im.zone}"
}
