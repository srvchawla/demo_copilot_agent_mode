locals {
  metadata = jsondecode(var.metadata)
  context = jsondecode(var.context_json)
  target_token = var.demo_app_token != "" ? var.demo_app_token : var.github_token

  # Slash is required by GitHub provider
  target_github_api_url_slash = !endswith(local.context.demo_org.github_api_url, "/") ? "/" : ""
  target_github_api_url = "${local.context.demo_org.github_api_url}${local.target_github_api_url_slash}"

  parameters_json = jsonencode({
    "requestor_handle": local.context.actor,
    "source_directory": local.context.source_directory,
    "target_repository": {
      "name": local.context.demo_instance_name,
      "owner": local.context.demo_org.owner,
      "github_instance_url": local.context.demo_org.github_instance_url
    },
    "content": {
      "name": local.metadata.shortname,
      "type": "demo-contents"
    },
    "metadata": {
      "name": local.metadata.name
    },
    "od_repo_type": "Octodemo Demo",
    "od_demo_slug_property": local.metadata.shortname
  })
}

provider "github" {
  alias    = "demo_org_provider"
  token    = local.target_token
  owner    = local.context.demo_org.owner
  base_url = local.target_github_api_url
}

module "repository" {
  source = "git::https://github.com/octodemo-framework/terraform-modules.git//modules/repository?ref=main"
  providers = {
    github = github.demo_org_provider
  }

  parameters_json         = local.parameters_json
  deployment_context_json = var.context_json
  github_token            = var.github_token
  target_app_token        = var.demo_app_token
}
