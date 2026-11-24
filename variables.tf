variable "project_name" {
  description = "Prefix used for Docker resources created by this lab."
  type        = string
  default     = "sdi4213-week12"
}

variable "web_port" {
  description = "Host port for the Week 12 status portal."
  type        = number
  default     = 8080
}

variable "adminer_port" {
  description = "Host port for the Adminer database UI."
  type        = number
  default     = 8081
}

variable "postgres_db" {
  description = "Name of the PostgreSQL database created on first start."
  type        = string
  default     = "helpdesk"
}

variable "postgres_user" {
  description = "PostgreSQL superuser name for the Help Desk database."
  type        = string
  default     = "student"
}

variable "postgres_password" {
  description = "PostgreSQL password. Supply it in terraform.tfvars (git-ignored); there is intentionally no default."
  type        = string
  sensitive   = true
}
