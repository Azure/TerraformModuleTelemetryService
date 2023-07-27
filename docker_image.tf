resource "docker_image" "proxy" {
  name = "${azurerm_container_registry.this.login_server}/telemetry_proxy"
  build {
    context = "."
    tag = [var.image_tag]
  }
  triggers = {
    code_hash = filemd5("${path.module}/telemetry/main.go")
  }
}

resource "terraform_data" "docker_push" {
  triggers_replace  = {
    code_hash = filemd5("${path.module}/telemetry/main.go")
  }
  provisioner "local-exec" {
    command = "docker login -u ${azurerm_container_registry_token.push.name} -p ${azurerm_container_registry_token_password.push_password.password1[0].value} https://${azurerm_container_registry.this.login_server}"
  }
  provisioner "local-exec" {
    command = "docker push ${docker_image.proxy.name}:${var.image_tag}"
  }

  depends_on = [docker_image.proxy]
}