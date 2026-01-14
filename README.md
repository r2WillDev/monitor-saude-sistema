# 📊 Monitor de Saúde do Sistema

![CI Pipeline](https://github.com/r2WillDev/monitor-saude-sistema/actions/workflows/ci.yml/badge.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue?logo=docker)
![Bash](https://img.shields.io/badge/script-bash-success?logo=gnu-bash)

Um sistema automatizado para monitoramento de recursos (CPU, Memória, Disco) em servidores Linux Debian, com suporte a containerização e pipelines de CI/CD.

---

## 🚀 Funcionalidades

* **Coleta de Métricas:** Monitoramento em tempo real de uso de recursos.
* **Logs Automatizados:** Geração de relatórios com timestamp.
* **Git Ops:** Commit automático dos logs para histórico de auditoria.
* **Containerização:** Execução isolada via Docker e Docker Compose.
* **CI/CD:** Pipeline automatizado no GitHub Actions para Lint e Build.

---

## 🛠️ Como Usar

### Opção 1: Rodando com Docker (Recomendado)
A maneira mais fácil e segura de rodar o monitor sem instalar dependências no seu host.

```bash
# 1. Clone o repositório
git clone [https://github.com/r2WillDev/monitor-saude-sistema.git](https://github.com/r2WillDev/monitor-saude-sistema.git)
cd monitor-saude-sistema

# 2. Inicie o ambiente (Isso fará o build da imagem automaticamente)
docker compose -f docker/docker-compose.yml up --build
```

### Opção 2: Instalação Nativa (Linux Debian/Ubuntu)
Para servidores onde você deseja que o monitor rode diretamente no SO.

```bash
# 1. Execute o script de provisionamento (Instala git, curl, cria usuário)
sudo ./scripts/provision.sh

# 2. Configure as variáveis
cp configs/config.env.example configs/config.env
# (Edite o arquivo config.env se necessário)

# 3. Execute o monitor
./scripts/monitor.sh
```

## 📂 Estrutura do Projeto
```plaintext
.
├── .github/        # Pipelines de CI/CD (GitHub Actions)
├── configs/        # Arquivos de configuração (.env)
├── docker/         # Dockerfile e docker-compose.yml
├── logs/           # Diretório onde os relatórios são salvos
├── scripts/        # Scripts principais (monitor, provision, install)
└── README.md       # Documentação
```

## 🤝 Contribuição
1. Faça um Fork do projeto

2. Crie uma Branch para sua Feature (git checkout -b feature/Incrivel)

3. Commit suas mudanças (git commit -m 'feat: Adiciona algo incrivel')

4. Push para a Branch (git push origin feature/Incrivel)

5. Abra um Pull Request

