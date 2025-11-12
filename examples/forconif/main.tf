variable "numbers" {
  default = [1, 2, 3, 4, 5, 6]
}

locals {
  # Solo números pares
  even_numbers = [for n in var.numbers : n if n % 2 == 0]
  # Resultado: [2, 4, 6]
}

output "resultado" {
  value = local.even_numbers
}
# ```

# **Paso a paso con filtro:**
# ```
# Iteración 1: n = 1 → 1 % 2 == 0? NO  → Se descarta
# Iteración 2: n = 2 → 2 % 2 == 0? SÍ  → Se incluye: 2
# Iteración 3: n = 3 → 3 % 2 == 0? NO  → Se descarta
# Iteración 4: n = 4 → 4 % 2 == 0? SÍ  → Se incluye: 4
# Iteración 5: n = 5 → 5 % 2 == 0? NO  → Se descarta
# Iteración 6: n = 6 → 6 % 2 == 0? SÍ  → Se incluye: 6

# Resultado: [2, 4, 6]