variable "users" {
  type = map(object({
    role        = string
    permissions = list(string)
    active      = bool
  }))
  
  default = {
    "alice" = {
      role        = "admin"
      permissions = ["read", "write", "delete"]
      active      = true
    }
    "bob" = {
      role        = "developer"
      permissions = ["read", "write"]
      active      = true
    }
    "charlie" = {
      role        = "viewer"
      permissions = ["read"]
      active      = false
    }
  }
}

resource "null_resource" "user_setup" {
  for_each = var.users
  
  triggers = {
    username    = each.key
    role        = each.value.role
    permissions = join(",", each.value.permissions)
    active      = each.value.active
  }
  
  provisioner "local-exec" {
    command = "echo 'Creating user ${each.key} with role ${each.value.role}'"
  }
}

output "active_users" {
  value = {
    for username, config in var.users :
    username => config.role
    if config.active
  }
}