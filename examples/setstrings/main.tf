variable "server_types" {
  type = set(string)
  default = ["web", "database", "cache", "worker"]
}

variable "include_legacy" {
  type = bool
  default = true
}

variable "excluded_types" {
  description = "Server types to exlude from inventory"
  type = list(string)
  default = []
// alltrue() - Verificar que todos sean true. Devuelve true solo si todos los elementos de la lista son true.
  validation {
    condition = alltrue([
      for type in var.excluded_types :
      contains(["web", "database", "cache", "worker", "legacy"], type)
    ])
    error_message = "excluded_types must contain valid server types."
  }
}

locals {
  # Definir los puertos en un local para reutilizar
  server_ports = {
    web      = 80
    database = 5432
    cache    = 6379
    worker   = 9000
    legacy   = 8080
  }
// setunion() - Unir sets (suma de conjuntos) Combina múltiples sets en uno solo, eliminando duplicados.
servers_with_legacy = var.include_legacy ? setunion(var.server_types, ["legacy"]) : var.server_types
##setsubtract(set1, set2) - Resta elementos de un set
// setsubtract() - Restar sets (diferencia de conjuntos). Elimina elementos del primer set que estén en el segundo.
final_servers = setsubtract(local.servers_with_legacy, toset(var.excluded_types))
}


resource "local_file" "server_inventory" {
    # Si include_legacy es true, agrega "legacy" al set de server_types
  for_each = local.final_servers
 // lookup() - Buscar valor en un map con default. Busca una clave en un map y devuelve su valor. Si no existe, devuelve un valor por defecto.
  filename = "${path.module}/configs/inventory_${each.key}.txt"
  content  = <<-EOF
    Server Type: ${each.key}
    Created at: ${timestamp()}
    Port: ${lookup(local.server_ports, each.key, 8000)}
    State : ${each.key == "legacy" ? "Deprecated" : "Active"}
  EOF
}

output "created_files" {
  value = [for server in local_file.server_inventory : server.filename]
}

output "total_servers" {
  value = length(local_file.server_inventory)
}
// La función keys() extrae todas las claves de un map y las devuelve como una lista.
output "server_types_list" {
  description = "List of server types configured"
  value       = sort(keys(local_file.server_inventory))
}
//La función keys() extrae todas las claves de un map y las devuelve como una lista.
#  Paso a paso:
# 1. keys(local_file.server_inventory) → ["web", "database", "cache", "legacy"]
# 2. for key in [...] → itera sobre cada clave
# 3. if key != "legacy" → filtra "legacy"
# 4. Resultado: ["web", "database", "cache"]

output "servers_by_status" {
  description = "Servers grouped by status"
  value = {
    active     = [for key in keys(local_file.server_inventory) : key if key != "legacy"]
    deprecated = [for key in keys(local_file.server_inventory) : key if key == "legacy"]
  }
}

output "excluded_types" {
  description = "Server types that were excluded"
  value       = var.excluded_types
}