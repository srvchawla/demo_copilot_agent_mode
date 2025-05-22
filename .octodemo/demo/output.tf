output "demo_creation_output" {
  value = jsonencode({
    demo_entrypoint_url = jsondecode(module.repository.output_json).repo_url
    notification_body = "Notification body example"
    custom_outputs = jsondecode(module.repository.output_json),
  })
}
