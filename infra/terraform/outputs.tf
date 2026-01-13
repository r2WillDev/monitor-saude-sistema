output "file_path" {
  description = "Caminho absoluto do arquivo criado"
  value       = abspath(local_file.config_file.filename)
}
