 # Set the variable value in *.tfvars file
 # or using the -var="hcloud_token=..." CLI option
 variable "hcloud_token" {
   sensitive = true
 }
 
 variable "gandi_token" {
   sensitive = true
 }

 variable "cloudflare_token" {
   sensitive = true
 }

# HERE KEY: HTwZt-b2kdAbv1mQdx2cczmjy6xXrgeEAO5woOnaXZo