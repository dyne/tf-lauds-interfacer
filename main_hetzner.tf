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
  }
}
provider "hcloud" {
  token = var.hcloud_token
}
 
provider "gandi" {
  personal_access_token = var.gandi_token
}
resource "hcloud_server" "node1" {
  name        = "node1"
  image       = "debian-11"
  server_type = "cx22"
  ssh_keys    = ["antoniotrkdz@trkdz-d7-ceres"]
}

output "instance_public_ip" {
  description = "Public IP of Hetzner cloud instance"
  value     = hcloud_server.node1.ipv4_address
}

resource "gandi_livedns_record" "tofu_dyne_im" {
  zone = "dyne.im"
  name = "tofu"
  type = "A"
  ttl = 300
  values = [hcloud_server.node1.ipv4_address] //["127.0.0.2"]
  depends_on = [
    hcloud_server.node1
  ]
}