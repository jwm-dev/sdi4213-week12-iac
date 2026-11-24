locals {
  prefix = var.project_name
}

# ---------- Starter infrastructure: network + status portal ----------
resource "docker_network" "lab" {
  name = "${local.prefix}-network"
}

resource "docker_image" "nginx" {
  name         = "nginx:1.30.6-alpine-slim"
  keep_locally = true
}

resource "docker_container" "web" {
  name  = "${local.prefix}-web"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.web_port
  }

  networks_advanced {
    name = docker_network.lab.name
  }

  volumes {
    host_path      = abspath("${path.module}/site")
    container_path = "/usr/share/nginx/html"
    read_only      = true
  }

  restart = "unless-stopped"
}

# ---------- Week 12: PostgreSQL with persistent storage ----------
resource "docker_volume" "postgres_data" {
  name = "${local.prefix}-pgdata"
}

resource "docker_image" "postgres" {
  name         = "postgres:18.6-alpine"
  keep_locally = true
}

resource "docker_container" "db" {
  name  = "${local.prefix}-db"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_DB=${var.postgres_db}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
  ]

  networks_advanced {
    name = docker_network.lab.name
  }

  # postgres 18+ images store data in a version-specific subdirectory
  # (/var/lib/postgresql/18/docker) and refuse to start if a volume is mounted
  # at the old /var/lib/postgresql/data path, so mount the parent directory.
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql"
  }

  restart = "unless-stopped"
}

# ---------- Week 12: Adminer database UI ----------
resource "docker_image" "adminer" {
  name         = "adminer:5.5.1"
  keep_locally = true
}

resource "docker_container" "adminer" {
  name  = "${local.prefix}-adminer"
  image = docker_image.adminer.image_id

  env = [
    "ADMINER_DEFAULT_SERVER=${docker_container.db.name}",
  ]

  ports {
    internal = 8080
    external = var.adminer_port
  }

  networks_advanced {
    name = docker_network.lab.name
  }

  restart = "unless-stopped"
}
