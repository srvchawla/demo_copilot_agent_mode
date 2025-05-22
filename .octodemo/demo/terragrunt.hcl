inputs = {
  github_token = get_env("GITHUB_TOKEN", "")
  demo_app_token = get_env("DEMO_APP_TOKEN", "")
  metadata = local.metadata
}

locals {
  metadata = file("../metadata.json")
}

terraform {
  source = "./"
}
