#!/usr/bin/env bash
#
# bootstrap.sh
# Orquestrador de provisionamento. Garante a execução ordenada dos scripts.
#
# Autor: Arthur
# ----------------------------------------------------------------------

set -e

# --- Configurações ---
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/bootstrap.log"

# --- Função de Log ---
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [BOOTSTRAP] $1" | tee -a "$LOG_FILE"
}

# --- Validação Inicial ---
if [ "$(id -u)" -ne 0 ]; then
    echo "ERRO: O bootstrap deve ser executado como root." >&2
    exit 1
fi

log "Iniciando processo de Bootstrap..."

# --- Orquestração ---

# Passo 1: Provisionamento do Sistema Operacional
if [ -f "$BASE_DIR/provision.sh" ]; then
    log "Executando provisionamento do sistema..."
    chmod +x "$BASE_DIR/provision.sh"
    "$BASE_DIR/provision.sh"
else
    log "ERRO: Script provision.sh não encontrado em $BASE_DIR"
    exit 1
fi

# Futuro: Aqui entrará a chamada para instalar Docker (Etapa 4)
# Futuro: Aqui entrará a configuração do Agente de Monitoramento

log "Bootstrap finalizado com sucesso. O ambiente está pronto."
