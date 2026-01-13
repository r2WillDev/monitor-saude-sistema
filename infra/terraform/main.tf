resource "local_file" "config_file" {
  content  = "Ambiente: ${var.environment}\nGerenciado por: Terraform\nData: 2026"
  filename = "${path.module}/${var.file_name}"
}
