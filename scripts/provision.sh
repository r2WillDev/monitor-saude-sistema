#!/usr/bin/env bash
#
# provision.sh
# Script de provisionamento base para o projeto Monitor Saúde Sistema.
#
# Autor: Arthur
# Data: 2026
# ----------------------------------------------------------------------

# --- Modo de Segurança (Bash Strict Mode) ---
set -e          # Para o script se um comando falhar
set -u          # Para o script se uma variável não estiver definida
set -o pipefail # Retorna erro se qualquer comando em um pipe falhar

# --- Variáveis de Configuração ---
LOG_FILE="/var/log/provision.log"

# --- Funções Auxiliares ---

usage() {
    cat <<USAGE
Uso: $0 [opções]

Este script provisiona o ambiente para o Monitor Saúde Sistema.
Ele deve ser executado como root (sudo).

Opções:
  -h, --help    Exibe esta mensagem de ajuda e sai.

Exemplo:
  sudo $0

USAGE
    exit 1
}

log() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [PROVISION] $msg" | tee -a "$LOG_FILE"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

log "Iniciando provisionamento do sistema..."
log "Usuário atual: $(whoami)"

log "Atualizando cache de pacotes e sistema..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
apt-get autoremove -y
apt-get clean
log "Sistema atualizado."

log "Instalando pacotes essenciais..."
PACKAGES="curl wget git ca-certificates gnupg lsb-release htop tree "
apt-get install -y $PACKAGES
log "Dependências instaladas."

log "Configurando usuário de serviço 'monitor'..."

PROJECT_USER="monitor"
PROJECT_GROUP="monitor"

if id "$PROJECT_USER" &>/dev/null; then
    log "Usuário $PROJECT_USER já existe. Pulando criação."
else
    useradd -m -r -s /bin/bash "$PROJECT_USER"
    log "Usuário $PROJECT_USER criado com sucesso."
fi

# Adiciona o usuário ao grupo sudo (para poder rodar comandos privilegiados se necessário)
usermod -aG sudo "$PROJECT_USER"
log "Usuário $PROJECT_USER adicionado ao grupo sudo."


# --- Fase 4: Estrutura de Diretórios ---
log "Preparando diretórios da aplicação..."

APP_DIR="/opt/monitor-saude"
LOG_DIR="/var/log/monitor-saude"

# Cria diretórios se não existirem (-p)
mkdir -p "$APP_DIR"
mkdir -p "$LOG_DIR"

# Define o dono dos diretórios como o usuário 'monitor'
chown -R "$PROJECT_USER":"$PROJECT_GROUP" "$APP_DIR"
chown -R "$PROJECT_USER":"$PROJECT_GROUP" "$LOG_DIR"

# Ajusta permissões (Dono lê/escreve, Grupo lê, Outros leem)
chmod -R 755 "$APP_DIR"
chmod -R 755 "$LOG_DIR"

log "Estrutura de diretórios configurada em $APP_DIR e $LOG_DIR."
log "Provisionamento concluído com sucesso!"
