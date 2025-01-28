 # Set the variable value in *.tfvars file
 # or using the -var="hcloud_token=..." CLI option
 variable "hcloud_token" {
   sensitive = true
 }
 
 variable "gandi_token" {
   sensitive = true
 }

 variable "domain" {}

 variable "name" {}

 variable "hetzner_ssh_key_name" {}
