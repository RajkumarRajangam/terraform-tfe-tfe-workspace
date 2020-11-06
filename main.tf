# ------------------------------------------------------------------------------------------
# Create TFE workspace
# ------------------------------------------------------------------------------------------


resource "tfe_workspace" "main" {
  name         = var.workspace_name
  organization = var.organization_name
  queue_all_runs     = false
}
