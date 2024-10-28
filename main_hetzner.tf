terraform {
   required_providers {
     hcloud = {
       source  = "hetznercloud/hcloud"
       version = "1.27.2"
     }
   }
 }
 
 provider "hcloud" {
   token = var.hcloud_token
 }
 
 resource "hcloud_server" "node1" {
   name        = "node1"
   image       = "debian-11"
   server_type = "cx11"
   ssh_keys = ["antoniotrkdz@trkdz-d7-ceres"]
 }
