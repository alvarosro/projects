variable "message" {
  default = "Hello World"
}

resource "null_resource" "test" {
  triggers = {
    message   = var.message
    timestamp = timestamp()
  }
  
  provisioner "local-exec" {
    command = "echo '[${timestamp()}] Message: ${var.message}' >> log.txt"
  }
}