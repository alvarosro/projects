/*
Crea una variable databases que sea un map de objetos con esta estructura:

engine: string (postgres, mysql, mongodb, redis)
version: string
port: number
max_connections: number
backup_enabled: bool
environment: string (dev, staging, prod)

Define al menos 4 bases de datos diferentes con distintas configuraciones
Crea una variable booleana enable_prod_databases (por defecto false) que controle si se crean las bases de datos de producción.

Usa null_resource con for_each para simular la creación de cada base de datos con:

triggers que incluyan: nombre, engine, version, port
Un provisioner local-exec que imprima un mensaje de creación


Crea un archivo de configuración local_file para cada base de datos con:

Nombre del archivo: db-config-{nombre}.ini
Contenido que incluya todas las propiedades de la base de datos
Formato INI style

*/

variable "databases" {
  type = map(object({
    engine = string
    version = string
    port = number
    max_connections = number
    backup_enabled = bool
    environment = string
  }))
  default = {
    "Oracle" = {
      engine = "postgres"
      version = "13"
      port = 5432
      max_connections = 100
      backup_enabled = true
      environment = "dev"
    }
    "Mysql" = {
      engine = "mysql"
      version = "8.0"
      port = 3306
      max_connections = 150
      backup_enabled = true
      environment = "staging"
    }
    "mongodb" = {
      engine = "mongodb"
      version = "4.4"
      port = 27017
      max_connections = 200
      backup_enabled = false
      environment = "prod"
    }
    "redis" = {
      engine = "redis"
      version = "6"
      port = 6379
      max_connections = 300
      backup_enabled = true
      environment = "dev"
    }
  }
}

variable "enable_prod_databases" {
  type    = bool
  default = false
}

// its means for 
locals {
  filtered_databases = {
    for name, config in var.databases :
    name => config
    if config.environment != "prod" || var.enable_prod_databases
  }
}

resource "null_resource" "db" {
  for_each = local.filtered_databases
  triggers = {
    name  = each.key
    engine = each.value.engine
    version = each.value.version
    port = tostring(each.value.port)
  }

  provisioner "local-exec" {
    command = "echo Creating database ${each.key} with engine ${each.value.engine}, version ${each.value.version} on port ${each.value.port}"
  }

}

# Archivo de configuración para cada base de datos
resource "local_file" "database_config" {
  for_each = local.filtered_databases
  
  filename = "${path.module}/db-config-${each.key}.ini"
  content  = <<-EOF
    [database]
    name = ${each.key}
    engine = ${each.value.engine}
    version = ${each.value.version}
    
    [connection]
    port = ${each.value.port}
    max_connections = ${each.value.max_connections}
    
    [settings]
    backup_enabled = ${each.value.backup_enabled}
    environment = ${each.value.environment}
  EOF
}

# 1. Bases de datos agrupadas por engine
output "databases_by_engine" {
  description = "Databases grouped by engine type"
  value = {
    for engine in distinct([for db in local.filtered_databases : db.engine]) :
    engine => [
      for name, config in local.filtered_databases :
      name if config.engine == engine
    ]
  }
}

# 2. Total de conexiones máximas
output "total_max_connections" {
  description = "Sum of all max_connections"
  value = sum([
    for name, config in local.filtered_databases :
    config.max_connections
  ])
}

# 3. Bases de datos con backup habilitado
output "databases_with_backup" {
  description = "List of databases with backup enabled"
  value = [
    for name, config in local.filtered_databases :
    name if config.backup_enabled
  ]
}

# 4. Bases de datos agrupadas por environment
output "databases_by_environment" {
  description = "Databases grouped by environment"
  value = {
    for env in distinct([for db in local.filtered_databases : db.environment]) :
    env => [
      for name, config in local.filtered_databases :
      name if config.environment == env
    ]
  }
}