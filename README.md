# Valburga

Follow the steps in (this guide)[https://justobjects.nl/terraform-first-steps/]

## Prerequisites
1. Install Open Tofu
2. install ansible
3. Open an account on Hetzner provider (or any other provider of cloud)
4. Supply an (public) ssh key to a new hetzner cloud project
5. Create an API token on the dashboard (Read & Write)
6. Create a gandi account for DNS (or cloudflare or namecheap)
7. Generate a GANDI PAT (personal access token)
8. Create terraform.tfvars `hcloud_token = "{value}"`
9. Append terraform.tfvars `gandi_token = "{value}"`
10. Append terraform.tfvars `hetzner_ssh_key_name = "{value}"`
11. Append terraform.tfvars `private_ssh_key_path = "{value}"`


## Create a new VM the Dyne way

```bash
cd devops-gpm/
tofu init
tofu plan # test before run
tofu apply
```
1. Check on the hetzner dashboard if the VM was created correctly
