#!/usr/bin/env bash
#
# install_docker.sh
# Instala o Docker CE usando o repositório oficial.
#
# Autor: Arthur O2B
# ----------------------------------------------------------------------

set -e
set -o pipefail

LOG_FILE="/var/log/provision.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [DOCKER] $1" | tee -a "$LOG_FILE"
}

# 1. Verifica se já está instalado
if command -v docker &> /dev/null; then
    log "Docker já está instalado. Versão: $(docker --version)"
    exit 0
fi

log "Iniciando instalação do Docker CE..."

# 2. Prepara chave GPG
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Adiciona Repositório
# Detecta a versão do Debian (ex: bookworm)
CODENAME=$(lsb_release -cs)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

log "Repositório adicionado. Atualizando cache..."
apt-get update -y

# 4. Instalação
log "Instalando pacotes do Docker..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Configuração de Usuários (Post-Install)
# Adiciona o usuário atual (SUDO_USER) e o usuário 'monitor' ao grupo docker
if [ -n "${SUDO_USER:-}" ]; then
    usermod -aG docker "$SUDO_USER"
    log "Usuário $SUDO_USER adicionado ao grupo docker."
fi

if id "monitor" &>/dev/null; then
    usermod -aG docker "monitor"
    log "Usuário monitor adicionado ao grupo docker."
fi

log "Docker instalado com sucesso!"
