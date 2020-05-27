variable "emulator_ids" {
  type = set(string)
}
variable "emulation_environment_id" {
  type = string
}
variable "mqtt_broker" {
  type = string
}
variable "python_code_repository_volume_name" {
  type = string
}
variable "emulation_config_volume_name" {
  type = string
}
