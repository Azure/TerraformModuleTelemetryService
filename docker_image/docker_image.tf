resource "docker_image" "proxy" {
  name = "${var.registry_url}/telemetry_proxy"
  build {
    context = path.module
    tag     = ["${var.registry_url}/telemetry_proxy:${var.image_tag}"]
  }
  triggers = {
    code_hash = filemd5("${path.module}/telemetry/main.go")
  }
}

resource "docker_registry_image" "proxy" {
  name = docker_image.proxy.name
  keep_remotely = true
}