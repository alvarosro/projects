# Datos de entrada
variable "names" {
  default = ["alice", "bob", "charlie", "david"]
}

# FOR básico
locals {
  uppercase_names = [for name in var.names : upper(name)]
  # Resultado: ["ALICE", "BOB", "CHARLIE"]
}

output "resultado" {
  value = local.uppercase_names
}