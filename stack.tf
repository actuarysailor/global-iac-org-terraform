# We should move this to another repo and have it target specific branches
resource "spacelift_stack" "sdlc_environments" {
  for_each = toset(["development"])  # keys(locals.sdlc_environments)

  # This block is required if not using the Spacelift GitHub App installed from marketplace
  github_enterprise {
      namespace = "sassy-bulldog"
    }

  space_id    = spacelift_space.enterprise.id
  name        = "${each.key} stack"
  description = "${each.key} environment stack for ${var.enterprise_name}."

  repository   = data.spacelift_stack.this.repository
  branch       = data.spacelift_stack.this.branch
  project_root = "enterprise"  # Subdirectory in this repository to use

  autodeploy = true
  labels     = setunion(
    local.labels,
    [
      each.key,
      "azure",
      "depends-on:${data.spacelift_current_stack.this.id}"
    ]
  )
}

# This is an environment variable defined on the stack level. Stack-level
# environment variables take precedence over those attached via contexts.
# This evironment variable has its write_only bit explicitly set to false, which
# means that you'll be able to read back its valie from both the GUI and the API.
#
# You can read more about environment variables here:
#
# https://docs.spacelift.io/concepts/environment#environment-variables
# resource "spacelift_environment_variable" "stack-plaintext" {
#   stack_id   = spacelift_stack.managed.id
#   name       = "STACK_PUBLIC"
#   value      = "This should be visible!"
#   write_only = false
# }

# For another (secret) variable, let's create programmatically create a super
# secret password.
# resource "random_password" "stack-password" {
#   length  = 32
#   special = true
# }

# This is a secret environment variable. Note how we didn't set the write_only
# bit at all here. This setting always defaults to "true" to protect you against
# an accidental leak of secrets. There will be no way to retrieve the value of
# this variable programmatically, but it will be available to your Spacelift
# runs.
#
# If you accidentally print it out to the logs, no worries: we will obfuscate
# every secret thing we know of.
# resource "spacelift_environment_variable" "stack-writeonly" {
#   stack_id = spacelift_stack.managed.id
#   name     = "STACK_SECRET"
#   value    = random_password.stack-password.result
# }

# This mounted file contains a JSON-encoded list of Spacelift's outgoing IPs.
# Note how we explicitly set the "write_only" bit for this file to "false".
# Thanks to that, you can download the file from the Spacelift GUI.
#
# You can read more about mounted files here: 
#
# https://docs.spacelift.io/concepts/environment#mounted-files
# resource "spacelift_mounted_file" "stack-plaintext-file" {
#   stack_id      = spacelift_stack.managed.id
#   relative_path = "stack-plaintext-ips.json"
#   content       = base64encode(jsonencode(data.spacelift_ips.ips.ips))
#   write_only    = false
# }

# Mounted-files can be write-only, too, and they are by default. The content of
# write-only mounted files cannot be accessed neither from the GUI nor from the
# GraphQL API.
# resource "spacelift_mounted_file" "stack-secret-file" {
#   stack_id      = spacelift_stack.managed.id
#   relative_path = "stack-secret-password.json"
#   content       = base64encode(jsonencode({ password = random_password.stack-password.result }))
# }
