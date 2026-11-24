output "portal_url" {
  description = "URL for the Week 12 status portal."
  value       = "http://localhost:${var.web_port}"
}

output "adminer_url" {
  description = "URL for the Adminer database UI."
  value       = "http://localhost:${var.adminer_port}"
}

output "database_server" {
  description = "Server name to enter in Adminer (the PostgreSQL container name on the lab network)."
  value       = docker_container.db.name
}

output "postgres_volume" {
  description = "Named Docker volume holding PostgreSQL data."
  value       = docker_volume.postgres_data.name
}
