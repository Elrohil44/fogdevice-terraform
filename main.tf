provider "docker" {
  host = "unix:///var/run/docker.sock"
  version = "2.6.0"
}

resource "docker_network" "backend" {
  name = "backend"
  internal = true
}

resource "docker_network" "frontend" {
  name = "frontend"
}

data "docker_registry_image" "fogdevice_supervisor_api" {
  name = "elrohil/fogdevice-supervisor-api:latest"
}

resource "docker_image" "fogdevice_supervisor_api" {
  name = data.docker_registry_image.fogdevice_supervisor_api.name
  pull_triggers = [data.docker_registry_image.fogdevice_supervisor_api.sha256_digest]
}

data "docker_registry_image" "fogdevice_supervisor_app" {
  name = "elrohil/fogdevice-supervisor-app:latest"
}

resource "docker_image" "fogdevice_supervisor_app" {
  name = data.docker_registry_image.fogdevice_supervisor_app.name
  pull_triggers = [data.docker_registry_image.fogdevice_supervisor_app.sha256_digest]
}

resource "docker_image" "eclipse_mosquitto" {
  name = "eclipse-mosquitto"
}

resource "docker_image" "mongo" {
  name = "mongo:4.2"
}

resource "docker_volume" "python_code_repository" {}
resource "docker_volume" "emulation_configs" {}
resource "docker_volume" "database" {}

resource "docker_container" "fogdevice_supervisor_api" {
  image = docker_image.fogdevice_supervisor_api.latest
  name = "fogdevice_supervisor_api"
  working_dir = "/app"
  volumes {
    volume_name = docker_volume.python_code_repository.name
    container_path = "/app/python-code-repository/"
  }
  volumes {
    volume_name = docker_volume.emulation_configs.name
    container_path = "/app/emulation-configs/"
  }
  volumes {
    host_path = "/home/elrohil/terraform/"
    container_path = "/app/terraform/"
  }
  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  ports {
    internal = 5001
    external = 5001
  }
  networks_advanced {
    name = docker_network.backend.name
  }
  networks_advanced {
    name = docker_network.frontend.name
  }
  depends_on = [docker_container.mongo]
  env = [
    "MONGODB_URL=mongodb://${docker_container.mongo.ip_address}",
    "NODE_ENV=dev",
    "EMULATION_CONFIGS_DIR=/app/emulation-configs",
    "PYTHON_CODE_REPOSITORY_DIR=/app/python-code-repository",
    "TERRFORM_MAIN_FILE=main.tf",
    "TERRFORM_DIR=/app/terraform",
    "ALLOW_ORIGIN=http://13.95.124.212:3000",
    "JWT_PRIVATE_KEY=LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlKS0FJQkFBS0NBZ0VBcE4xVGVZb3lJZkdsdTBFS0U1dm93SUliK29UWHo5QWV0U1BSQ2RkaFFVMzR0MFhJCmlrUHRhV0g2bWowcU1XaWt4ZmxWektmRkd5UCtydDZyZ2kyN2x0eWFpWHBRK1BpVy9qWDFGc3VzQU14NldLRmMKOTZXYmcrVnk3TnFhYWtsVkgrYlQ1Y3Q4WkpFSGVZaGRReHJtRWgreWdvVENTYXJnV29yS3MvdW5mSUk0U3JwZQpoMlhBVk92VHk5KzdFQzBXcjRmTitWZ3dHNllObkVDeVY0MzdhdDJ0WEN5aUpUK295c1hQZzNtaDhZWmpsMjFxCnZxdnk4dnQ2WEcvNC8xbThna01zS29xRzI5alhyL0owLzI4Sm0yc2dIQld4ckUwZitHN2t4d3p5MGU5WmtRKzMKMnNHRVM4SFVvb3JUTEd2RFA1MmVjT2c3bUdUL29XUzFtM2JUeGU2eVMwSURTUjViRUxNTXYrOWl0ZmxHQ0sxTwpyWWkvTDFoZ0JHQlFQd3liUTk5Q05pNGFhV21qUnZhWDYxQ3FGMjVaaktoNURuelF4VDZnTHlnLytpcTRsTXRCCjA3N1dxdW9iaHhva0t1VkgvM2I0U1g5eXB1TDJZTkVFSnFOanFPU0d2K05NTjBqN291TU1SSU51aCtNeVg2Mm4KZXA4cWk0Q3BRSlBVTXg2OGJjaU40Y2N2ODAvV0dtOVA2UXROTzBFSXNQYW5ramdULytvdWk4RFFyNmx1cVNxVgpxSnNsYUJHbzNLRyttL0N0UGtteHQ2NkxjSW1aT3M2cDQvMXI3aHhqZmhqSGZTeWlNNUxYUldmaitoQTllZVE0CmV1dzVrZy9NbVR0cjVNSW13ZldQdlFRbk00ZHc3RDMxVFB0UEFYSlEyZ1J5bFZQNW43S3pkWnF5L0lVQ0F3RUEKQVFLQ0FnQm85QUVsR1lZS3QrUXl6aGZWSGViUlRzTHkrOGpMb2drNmRaK283VFVidHNDRUkrZWpwZFNveHRnYgpncDZ1cjVoZDgvbmIvRjN0aGorbklWZjcycE5XV2dBRFR4dm5NNUlrS1VOcWpLUm1LY1lsVUN4Mzl6U0doZlpnCnRGV2pIaVlUMWdYRmY0SWtIM09ydWRUdFdGMW80a2JvOGcwaGlxZWkzRUpveStiMnk0dDhmeUtZZlgwd1VxVVYKWDh1ZFk2YlNmZGp4U0dQdjVnazZGTEcwTFU0RjNUTjB2M0ZGMXoza1FJTjNobUpDK0xQRC9jTDd1VWxEeURaQQpUSVF1UXZsUHorVjQrNUVZdWZXdEsrT3hqUVdIckczWGt6UDFwVytaM3piRFJRbjcvYXgrUFl4a3RkYzd4eHhQCmthTVgzMDUvM0I2MmNCRW9WZnVxeWdzVytsR2I1T1M3UFJHcGJFZFUxajNRYnMxSS93YWd5aDhwYmxmdnkzLzAKN3JJUXpSVDlRMm5wcVY4L3F0OFBWNnprVGY4WEJ2d0hqaGFXZ2t1TDIzYXA5N1ZmeHBqeHNHYk4yYnNvUWZaQgp6cEJReDQvV0pWWVlvbzhXNVdDR3NWd1RwS09GdzhSUmprY2xCRHdTRFpTUlE4N3JJUmptd1UrRFRvOHdDYXU4Cjc0NW00YUtpbldkVEhQekQ3UThMVlhReE5PSWNkYzRhKzZiL2x6ZGhsbks3U1ArSEIxTUVWQVd1a1AzYjlkOWcKaXFBckZvMzVPczc2WWROYjlobHl3N1JmTEIwK3BRbXA2RllhRkcrY2ZKM2RJUlo5S0ZCeW5JeUVteU4yK2lPWgptOGR0TlpkNFZIWDhHM0ZURUdNdnBMQWV4eDhEWHZ4ODZiZDJqV0NFYXMyeXN3WWRUUUtDQVFFQTJvSDljZU1iCnZSWjZ0UzBxWlhaZmRETlI0aVd3UGJsQnpBdU9jNFlBQ2I4ZDNLeGJYZDhjVDJMTnNJdGJYcFh6SGdvZzRPMWMKNE9MZ09JSVczdDhiMUVRdndkbDVNVmI4eUJUeERURVBEVk1QQnBsc2xxdFdqOW5KdHJnSkFXc21lTUVIT29kVwpKNTNEaHlxd1ZRTHpOcE1OdlV4Ky9IQXJGS0c5aTlnbUtWaFo1bUZZeUpvbXJwSExjVU1EL0JBYUJ0RFFzYTBCCmlOdlNIcUQ1cVFnMzVXUTlLaWJ3NnFsdnJpQnpGTFRsYXF6eFJWWDZEcUNJcThLQXFMNCtVYWRKVVljUkIzQjMKaG54T3MyWS9nZU8zQ2pYVENyWHBzS1greW02Rnc1U0p5TThyaDh2NGl5Q1ZsdFY5aVVMZmZQV0NjU3cyT3dXZgpWZUQ0eFpuMEtUbzF3d0tDQVFFQXdTY0xQcWtCeTl1Y1M4V2pFaXkrSGp4dkR5VzBDZFVCTjYzZ3ZoaFhrcHBuCnY2dlZXMVJESGxpaXoxRHBTdWFtUDhrZ0QzN2Foay9UQUozVFIyYUhjSnVtcWs4VDk1REpsYXJ3dGdoUUN4UUIKOEJDNk1CTU53aXV3eFRMVjNpaGhTbnZxWWJqZ0p3TGkyamxFODNWVE9rY2ZSRG9LaHZ2eE9Gd0dmajlyMDdhaApQcEJteHpvWFd1K3FpMmlGQXlTTmtqM290czA1aTdxZ0VyRWJHdk5ObG55ZGJVcUt6bnNFL05hMkZEOFhmNXRxCkFUdmVnam9pa3E2N3lSYVFKaWQ2VElUWTV0cXQvS0YwZ2s2aDREWUMrN3h4ZW8rUCtobEtUZG1iaG9NZTFiL0sKSkxVa1U2TDFodUhpdzAxWEpROVFwQStXZWdGTm5BWXlQR1Q1cjV5NEZ3S0NBUUVBeFY2WFRKREVsSGJDbmZaUApEbGp1L2FvQmM1RnhjVDl1UkYzSDdXZURqMG8zTWdYcGZaQXpKUzNzOTJQWlEwV1UxWFIyb0ZVbkNPZEZleVZlCmZTL3dGanNGSEVkUTVoVlp2V3pWRTRKVncwWmNFeXp3WGVRa0MwbkFueS82eW5JN3pPVW1uMkp4bXRVeE1WMkkKNnpELytUSzVQVnprY3licWN2ZHBtL0RBLzZXVGhybzFsUFZRcld4NTVET1JYTlE2ZmgrTjhuK0FIRnZhbnRudQp5UlRvVUdiTHJOQ0IycVR6Z01oRXl0WmZSNDB4WGR5OFF3d1VoM2puK0FQbmpKL2JaUzNvWHR6aXlmSnNzRFZTCmRnUDNhTnlYWlZ4TjJzY0ZyMXBIcnhMenBoUWprTVRZR3V0eTAwekIyUU16bGM2NVpYcDIvYmNsWmxBUXhZUTcKZkNYZE93S0NBUUJsWVBiWDlxRUl2TVcyUjQrbDFISWRNSjhpRmluL0Z4dkNlN01BVTRweldqT21PS3lOZVJhWgpjUEJUWENaMnQ4VCtxYlA0TGg3SWJGRlZlNEVQY3RNWDJicUtuV0xmaDlFbWkwZzRZdmlRTi9va1pNTTB4R3R1ClJMeE5aTGM0R1gybk9JNzJwN0NQQ1ViRVAxYmZhZTg3SVdWWnpCVUdjR3BWcUllSDhBWEtZNHNTYVh4b2lTY0YKQmRJL3hhWTYxZzZ3ZVdvUnVIbkJ5enlGVXd2bEExcnY1NHhCZHVTUUo2V2doNW1kMnRlY2xKZjQrZEY2RE1WawpzKzNBUitWMUFUZUJ2aUNTV3FrRGRrTE91akxnbWJqTEpFZHppcktKRklrWmYyUFFJRFlvL3JjOHVRN09EelJMCmpYZ1dCaHY5U2FLTDJkcWpRdGZYVXJFL1hjaG4waHdWQW9JQkFDRkgzR2sxWjA4dVg2ajNTd0FnNTRuSXY5T08KenkvKzIrck5TZEpvelZnLzlVQXFsRERIWnRKcm95ZGxKY2N1c0FEU3orWUdQeFNWUXYrVitUTFB4Z0Z2STI4dwpqbTJQSVZ6OG9ONHljYmtIK2NEMEFaZ3Uxc3BveUVFT0EyTU5lakVRSmFralBDSGZjMTc5NlNCU01mcncvTXNBCmNJeS9rZ01EcmR4TGxEODhPWVFuRDU1cUM3UHpLNFZMRlZkeFo0ZU1HSGptWkV6U1FIeEJtSklBTWFYOG5VSmsKTlpTUFVpeUpXYnNTbUE0TGpadEROZXBXVzNBWEhpdGZJRUI2NXNRREJ5V2NxMThtTGdHbk41b0NEUXBVd0VHVAp0QzRKNm1TOGNtZnZpYnVhSkdmcnhWRy9yUThWTTM5RFIvcGYxakI0RXpmS3ZKekhmSWtXbmdQNmFYMD0KLS0tLS1FTkQgUlNBIFBSSVZBVEUgS0VZLS0tLS0K",
    "JWT_PUBLIC_KEY=LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQ0FnRUFwTjFUZVlveUlmR2x1MEVLRTV2bwp3SUliK29UWHo5QWV0U1BSQ2RkaFFVMzR0MFhJaWtQdGFXSDZtajBxTVdpa3hmbFZ6S2ZGR3lQK3J0NnJnaTI3Cmx0eWFpWHBRK1BpVy9qWDFGc3VzQU14NldLRmM5NldiZytWeTdOcWFha2xWSCtiVDVjdDhaSkVIZVloZFF4cm0KRWgreWdvVENTYXJnV29yS3MvdW5mSUk0U3JwZWgyWEFWT3ZUeTkrN0VDMFdyNGZOK1Znd0c2WU5uRUN5VjQzNwphdDJ0WEN5aUpUK295c1hQZzNtaDhZWmpsMjFxdnF2eTh2dDZYRy80LzFtOGdrTXNLb3FHMjlqWHIvSjAvMjhKCm0yc2dIQld4ckUwZitHN2t4d3p5MGU5WmtRKzMyc0dFUzhIVW9vclRMR3ZEUDUyZWNPZzdtR1Qvb1dTMW0zYlQKeGU2eVMwSURTUjViRUxNTXYrOWl0ZmxHQ0sxT3JZaS9MMWhnQkdCUVB3eWJROTlDTmk0YWFXbWpSdmFYNjFDcQpGMjVaaktoNURuelF4VDZnTHlnLytpcTRsTXRCMDc3V3F1b2JoeG9rS3VWSC8zYjRTWDl5cHVMMllORUVKcU5qCnFPU0d2K05NTjBqN291TU1SSU51aCtNeVg2Mm5lcDhxaTRDcFFKUFVNeDY4YmNpTjRjY3Y4MC9XR205UDZRdE4KTzBFSXNQYW5ramdULytvdWk4RFFyNmx1cVNxVnFKc2xhQkdvM0tHK20vQ3RQa214dDY2TGNJbVpPczZwNC8xcgo3aHhqZmhqSGZTeWlNNUxYUldmaitoQTllZVE0ZXV3NWtnL01tVHRyNU1JbXdmV1B2UVFuTTRkdzdEMzFUUHRQCkFYSlEyZ1J5bFZQNW43S3pkWnF5L0lVQ0F3RUFBUT09Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo="
  ]
  restart = "unless-stopped"
}

resource "docker_container" "fogdevice_supervisor_app" {
  image = docker_image.fogdevice_supervisor_app.latest
  name = "fogdevice_supervisor_app"
  ports {
    internal = 80
    external = 3000
  }
  restart = "unless-stopped"
  networks_advanced {
    name = docker_network.frontend.name
  }
}

resource "docker_container" "mosquitto" {
  image = docker_image.eclipse_mosquitto.latest
  name = "mosquitto"
  restart = "unless-stopped"
  ports {
    internal = 1883
    external = 1883
  }
  ports {
    internal = 9001
    external = 9001
  }
}

resource "docker_container" "mongo" {
  image = docker_image.mongo.latest
  name = "mongo"
  restart = "unless-stopped"
  volumes {
    container_path = "/data/db"
    volume_name = docker_volume.database.name
  }
  networks_advanced {
    name = docker_network.backend.name
  }
  networks_advanced {
    name = docker_network.frontend.name
  }
  ports {
    internal = 27017
    external = 27017
  }
}
