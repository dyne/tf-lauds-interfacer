# Valburga

Follow the steps in (this guide)[https://justobjects.nl/terraform-first-steps/]

## Prerequisites
1. Install Open Tofu
1. install ansible
2. Create a first test main to pull and start nginx docker on localhost
3. Open an account on Hetzner provider (or any other provider of cloud)
4. Supply an (public) ssh key to a new hetzner cloud project
5. Create an API token on the dashboard (Read & Write)
6. Create a gandi account for DNS (or cloudflare or namecheap)
1. generate a GANDI PAT (personal access token)
1. Create terraform.tfvars `hcloud_token = "{value}"`
1. Create terraform.tfvars `gandi_token = "{value}"`


## Create a new VM the Dyne way
1. insert into terraform.tfvars the zone of your domain name `domain`

```bash
cd devops-gpm/
tofu init
tofu plan # test before run
tofu apply
```
1. Create a VM using main.tf
1. Check on the hetzner dashboard if the VM was created correctly
