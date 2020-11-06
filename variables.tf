# TFE
variable "organization_name" {
  description = "Name of the organization in which this workspace should be created"
}
variable "hostname" {
  description = "The hostname of the terraform enterprise instance"
  default = ""
}
variable "workspace_name" {
  description = "The name of the workspace to be created"
}
variable "tfe_token" {
  description = "A team token created on organization level. It should at least have the access to create other workspaces."
}


# VAULT
variable "vault_token" {
  description = "A very scoped vault token that ONLY allows you to speak with the approle-backend for login with roleID."
}
variable "vault_addr" {
  description = "Vault address."
}
variable "vault_namespace" {
  description = "The vault namespace that this workspace has a valid vault token in."
}
variable "vault_policy" {
  description = "The policy that will be attached to the token generated for the workspace."
}


# CONSUL
variable "consul_namespace" {
  description = "Consul namespace the vault namespace is connected to."
}
variable "consul_acl_namespace_token" {
  description = "Acl token that gives broad access to your consul-namespace. "
}
variable "consul_gossip_encryption_key" {
  description = "This key is use to encrypt the gossip communication between consul-nodes."
}
variable "consul_address" {
  description = "The address to the consul instance."
}
variable "consul_agent_token" {
  description = "This consul token is used to register the agent in the default namespace."
}


# VSPHERE
variable "vsphere_user" {
  description = "vsphere user to be put in env var. Should be a service user for the team"
}
variable "vsphere_password" {
  description = "vsphere password linked to the vsphere user"
}
variable "vsphere_server" {
  description = "The address of the vcenter server"
  default = "vcenter01.sikker.infra.minerva.loc"
}
variable "vsphere_allow_unverified_ssl" {
  description = "should be set to false"
  default = false
}

#GitLab

variable "gitlab_url" {
  description = "The URL where GitLab can be found."
}

# LDAP
variable "ldap_bind_user" {
  description = "This user is used to create an LDAP connection in your Vault namespace"
}
variable "ldap_bind_password" {
  description = "Password to the according LDAP bind user."
}

#VCS
variable "vcs_repo_identifier" {
  description = " A path to the gitlab project that is used to set up a VCS connection between a GitLab project and the workspace"
}
variable "vcs_oauth_token_id" {
  description = "This token is used to establish connection between GitLab VCS project and Terraform workspace"
  default = ""
}
variable "gitlab_oauth_token" {
  description = "This token is used to establish connection between GitLab and Terraform organization"
  default = ""
}

locals {
  vcs_repo = { identifier = var.vcs_repo_identifier }
}

