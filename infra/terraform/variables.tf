variable "environment" {
  description = "Nome do ambiente (ex: dev, prod)"
  type        = string
  default     = "dev"
}

variable "file_name" {
  description = "Nome do arquivo de configuração simulado"
  type        = string
  default     = "infra_config.txt"
}
