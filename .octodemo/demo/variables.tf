variable "github_token" {
  description = "GitHub token used for repository operations"
  type        = string
  sensitive   = true
}

variable "demo_app_token" {
  type = string
  sensitive = true
  description = "GitHub token for accessing the demo organization"
}

variable "metadata" {
  description = "Metadata JSON file content"
  type        = string
}

variable "context_json" {
  description = "This is a Octodemo Framework variable that will get passed in automatically."
  type = string
    validation {
    condition = can(jsondecode(var.context_json)) && alltrue([
      can(jsondecode(var.context_json).actor),

      can(jsondecode(var.context_json).source.version),

      can(jsondecode(var.context_json).demo_org.owner),
      can(jsondecode(var.context_json).demo_org.github_instance_url),
      can(jsondecode(var.context_json).demo_org.github_api_url),

      can(jsondecode(var.context_json).demo_instance_name)
    ])
    error_message = "context_json must be a valid JSON string containing actor, source, demo_org and demo_instance_name"
  }
}
