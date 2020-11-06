# ------------------------------------------------------------------------------------------
# Create TFE workspace
# ------------------------------------------------------------------------------------------

resource "null_resource" "setting_ws_master_vault_token" {
  provisioner "local-exec" {
    environment = {
      VAULT_TOKEN     = var.vault_token
      VAULT_POLICY    = var.vault_policy
      VAULT_ADDR      = var.vault_addr
      TFE_TOKEN       = var.tfe_token
      TFE_HOSTNAME    = var.hostname
      TFE_WORKSPACE   = tfe_workspace.main.id
      VAULT_NAMESPACE = var.vault_namespace
    }
    command = <<EOT
    vault_token=$(curl -s -k --header "X-Vault-Token: $VAULT_TOKEN" --header "X-Vault-Namespace: $VAULT_NAMESPACE"  --request POST  --data "{\"policies\":[\"$VAULT_POLICY\"]}"  $VAULT_ADDR/v1/auth/token/create-orphan | grep -Eo '\"client_token\"[a-zA-Z0-9\.\"\:]*' | sed -e 's/"//g' | awk -F ':' '{print $2}')
    curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data "{\"data\":{\"type\":\"vars\",\"attributes\":{\"key\":\"vault_token\",\"value\":\"$vault_token\",\"description\":\"vault token\",\"category\":\"terraform\",\"hcl\":false,\"sensitive\":true}}}" https://$TFE_HOSTNAME/api/v2/workspaces/$TFE_WORKSPACE/vars
    curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data "{\"data\":{\"type\":\"vars\",\"attributes\":{\"key\":\"VAULT_TOKEN\",\"value\":\"$vault_token\",\"description\":\"vault token\",\"category\":\"env\",\"hcl\":false,\"sensitive\":true}}}" https://$TFE_HOSTNAME/api/v2/workspaces/$TFE_WORKSPACE/vars
    EOT
  }
}

resource "tfe_workspace" "main" {
  name         = var.workspace_name
  organization = var.organization_name
  queue_all_runs     = false

  dynamic "vcs_repo" {
    for_each = lookup(local.vcs_repo, "identifier", "void") == "void" ? [] : [local.vcs_repo]
    content {
      branch             = lookup(local.vcs_repo, "branch", null)
      identifier         = lookup(local.vcs_repo, "identifier", null)
      ingress_submodules = lookup(local.vcs_repo, "ingress_submodules", null)
      oauth_token_id     = var.vcs_oauth_token_id
    }
  }
}

## TFE workspace variables
locals {
  ENV = {
    "CONSUL_HTTP_ADDR"             = { "value" = var.consul_address, "sensitive" = false, "category" = "env" },
    "CONSUL_NAMESPACE"             = { "value" = var.consul_namespace, "sensitive" = false, "category" = "env" },
    "CONSUL_HTTP_TOKEN"            = { "value" = var.consul_acl_namespace_token, "sensitive" = true, "category" = "env" },
    "VAULT_NAMESPACE"              = { "value" = var.vault_namespace, "sensitive" = false, "category" = "env" },
    "VAULT_ADDR"                   = { "value" = var.vault_addr, "sensitive" = false, "category" = "env" },
    "TFE_TOKEN"                    = { "value" = var.tfe_token, "sensitive" = true, "category" = "env" },
    "TFE_HOSTNAME"                 = { "value" = var.hostname, "sensitive" = false, "category" = "env" },
    "VSPHERE_USER"                 = { "value" = var.vsphere_user, "sensitive" = false, "category" = "env" },
    "VSPHERE_PASSWORD"             = { "value" = var.vsphere_password, "sensitive" = true, "category" = "env" },
    "VSPHERE_SERVER"               = { "value" = var.vsphere_server, "sensitive" = false, "category" = "env" },
    "VSPHERE_ALLOW_UNVERIFIED_SSL" = { "value" = var.vsphere_allow_unverified_ssl, "sensitive" = false, "category" = "env" },
  }
  ## Environment
  TERRAFORM = {
    "consul_address"               = { "value" = var.consul_address, "sensitive" = false, "category" = "terraform" },
    "consul_namespace"             = { "value" = var.consul_namespace, "sensitive" = false, "category" = "terraform" },
    "consul_gossip_encryption_key" = { "value" = var.consul_gossip_encryption_key, "sensitive" = true, "category" = "terraform" },
    "gitlab_url"                   = { "value" = var.gitlab_url, "sensitive" = false, "category" = "terraform" },
    "vault_namespace"              = { "value" = var.vault_namespace, "sensitive" = false, "category" = "terraform" },
    "organization_name"            = { "value" = var.organization_name, "sensitive" = false, "category" = "terraform" },
    "vault_addr"                   = { "value" = var.vault_addr, "sensitive" = false, "category" = "terraform" },
    "ldap_bind_user"               = { "value" = var.ldap_bind_user, "sensitive" = true, "category" = "terraform" },
    "ldap_bind_password"           = { "value" = var.ldap_bind_password, "sensitive" = true, "category" = "terraform" },
    "consul_agent_token"           = { "value" = var.consul_agent_token, "sensitive" = true, "category" = "terraform" },
    "consul_acl_namespace_token"   = { "value" = var.consul_acl_namespace_token, "sensitive" = true, "category" = "terraform" },
    "tfe_token"                    = { "value" = var.tfe_token, "sensitive" = true, "category" = "terraform" },
    "hostname"                     = { "value" = var.hostname, "sensitive" = false, "category" = "terraform" },
    "vsphere_user"                 = { "value" = var.vsphere_user, "sensitive" = false, "category" = "terraform" },
    "vsphere_password"             = { "value" = var.vsphere_password, "sensitive" = true, "category" = "terraform" },
    "vsphere_server"               = { "value" = var.vsphere_server, "sensitive" = false, "category" = "terraform" },
    "vsphere_allow_unverified_ssl" = { "value" = var.vsphere_allow_unverified_ssl, "sensitive" = false, "category" = "terraform" },
    "vcs_oauth_token_id"           = { "value" = var.vcs_oauth_token_id, "sensitive" = true, "category" = "terraform" },
  }
}

resource "tfe_variable" "main-env" {
  depends_on   = [tfe_workspace.main]
  count        = length(keys(local.ENV))
  key          = keys(local.ENV)[count.index]
  value        = lookup(values(local.ENV)[count.index], "value", "empty")
  category     = lookup(values(local.ENV)[count.index], "category", "terraform")
  sensitive    = lookup(values(local.ENV)[count.index], "sensitive", "true")
  workspace_id = tfe_workspace.main.id
  description  = keys(local.ENV)[count.index]
}

resource "tfe_variable" "main-terraform" {
  depends_on   = [tfe_workspace.main]
  count        = length(keys(local.TERRAFORM))
  key          = keys(local.TERRAFORM)[count.index]
  value        = lookup(values(local.TERRAFORM)[count.index], "value", "empty")
  category     = lookup(values(local.TERRAFORM)[count.index], "category", "terraform")
  sensitive    = lookup(values(local.TERRAFORM)[count.index], "sensitive", "true")
  workspace_id = tfe_workspace.main.id
  description  = keys(local.TERRAFORM)[count.index]
}

resource "tfe_variable" "gitlab_oauth_token" {
  depends_on   = [tfe_workspace.main]
  count        = var.vault_namespace == "minerva" ? 1 : 0
  workspace_id = tfe_workspace.main.id
  key = "gitlab_oauth_token"
  value = var.gitlab_oauth_token
  sensitive = true
  category = "terraform"
  description = "This token is used to establish connection between GitLab and Terraform organization"
}
