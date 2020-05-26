//resource "docker_image" "emulator" {
//  name = "elrohil/fogdevice-emulator"
//}
//
//resource "docker_container" "emulator" {
////  name  = "emulator_${var.emulation_environment_id}_${var.emulator_id}"
//  name  = "emulator"
//  image = docker_image.emulator.latest
//  mounts {
//    target = "/app/main.py"
//    type = "bind"
//    source = ""
//  }
//  env = [
//    "MRAA_FOGDEVICES_PLATFORM_ID=${var.emulation_environment_id}_${var.emulator_id}",
//    "MRAA_FOGDEVICES_PLATFORM_BROKER=${var.mqtt_broker}"
//  ]
//}
