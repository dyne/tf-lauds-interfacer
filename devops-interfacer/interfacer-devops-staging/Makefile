# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2022-2023 Dyne.org foundation <foundation@dyne.org>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

VAULT_KEYFILE = .vault_pass
ANSIPLAY = ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --vault-password-file ${VAULT_KEYFILE} --inventory hosts.yaml --ssh-common-args '-o StrictHostKeyChecking=accept-new -o IdentitiesOnly=yes' --private-key ./sshkey $(1)

##@ General
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile
##@ client management
create: ## 🔒 Open a vault file
create: FILE=hosts.yaml
create:
	ansible-vault create --vault-password-file ${VAULT_KEYFILE}  ${FILE}

open: ## 🔒 Open a vault file
open: FILE=hosts.yaml
open:
	ansible-vault edit --vault-password-file ${VAULT_KEYFILE}  ${FILE}
##@ Server management
install: setup
install: ## 🔨 Install controller
	$(call ANSIPLAY, install-proxy.yaml)

.PHONY: setup
setup:
	ansible-galaxy collection install community.docker
