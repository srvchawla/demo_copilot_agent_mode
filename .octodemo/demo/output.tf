output "demo_creation_output" {
  value = jsonencode({
    demo_entrypoint_url = jsondecode(module.repository.output_json).repo_url
    custom_outputs = jsondecode(module.repository.output_json),
  })
}
