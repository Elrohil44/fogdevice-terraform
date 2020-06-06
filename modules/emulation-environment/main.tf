data "docker_registry_image" "emulation_environment" {
  name = "elrohil/fogdevice-environment-emulator:latest"
}

resource "docker_image" "emulation_environment" {
  name = data.docker_registry_image.emulation_environment.name
  pull_triggers = [data.docker_registry_image.emulation_environment.sha256_digest]
}

data "docker_registry_image" "software_emulator" {
  name = "elrohil/fogdevice-emulator:latest"
}

resource "docker_image" "software_emulator" {
  name = data.docker_registry_image.software_emulator.name
  pull_triggers = [data.docker_registry_image.software_emulator.sha256_digest]
}

resource "docker_container" "fogdevice-environment-emulator" {
  name  = "emulation_environment_${var.emulation_environment_id}"
  image = docker_image.emulation_environment.latest
  volumes {
    volume_name = var.emulation_config_volume_name
    container_path = "/app/emulation_configs/"
  }
  volumes {
    container_path = "/app/emulation-data/"
    host_path = "/home/elrohil/emulation-data/"
  }
  env = [
    "CLIENT_ID=${var.emulation_environment_id}",
    "MQTT_BROKER_URL=mqtt://${var.mqtt_broker}:1883",
    "CONFIG_PATH=/app/emulation_configs/${var.emulation_environment_id}.json",
    "DATA_DIR=/app/emulation-data"
  ]
}

resource "docker_container" "software_emulator" {
  for_each = var.emulator_ids
  name  = "emulator_${var.emulation_environment_id}_${each.value}"
  image = docker_image.software_emulator.latest
  volumes {
    volume_name = var.python_code_repository_volume_name
    container_path = "/app/python-code-repository/"
  }
  command = ["python", "-u", "/app/python-code-repository/${var.emulation_environment_id}_${each.value}.py"]
  env = [
    "MRAA_FOGDEVICES_PLATFORM_ID=${var.emulation_environment_id}_${each.value}",
    "MRAA_FOGDEVICES_PLATFORM_BROKER=${var.mqtt_broker}"
  ]
}
