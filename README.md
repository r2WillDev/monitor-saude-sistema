# Monitor de Saúde do Sistema

Ferramenta baseada em Shell Script para coleta de métricas de servidor (CPU, Memória, Disco) e versionamento de logs para auditoria em ambientes Linux Debian.

## 📂 Estrutura do Projeto

```text
monitor-saude-sistema/
├── configs/   # Arquivos de configuração e variáveis
├── docs/      # Documentação técnica adicional
├── logs/      # Histórico de relatórios (Audit Trail)
├── scripts/   # Scripts de execução (Coleta e Versionamento)
└── README.md  # Este arquivo
```

## 🚀 Pré-requisitos

* **SO:** Linux Debian 10/11/12
* **Pacotes:** `git`, `sysstat` (recomendado)
* **Acesso:** Permissão de escrita no diretório do projeto

## 🛠️ Como Utilizar

1.  Clone o repositório.
2.  Configure as variáveis em `configs/config.env` (futuro).
3.  Execute o script principal:
    `./scripts/monitor.sh`

## 📜 Versionamento de Logs
Este projeto utiliza o Git como ferramenta de auditoria. Os logs gerados na pasta `logs/` são automaticamente commitados pelo sistema para garantir imutabilidade histórica.

---
*Projeto DevOps - Fase 2: Estruturação*
