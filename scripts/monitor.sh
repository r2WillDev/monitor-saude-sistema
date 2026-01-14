#!/bin/bash
# -------------------------------------------------------------------------
# Projeto: Monitor de Saúde do Sistema (SRE Hardened Version)
# Arquivo: monitor.sh
# Descrição: Coleta métricas e sincroniza com Git.
#            Versão com tratamento de erros e Help Message.
#
# Autor: Arthur O2B Team
# -------------------------------------------------------------------------

set -u          # Erro se usar variável não declarada
set -o pipefail # Erro se qualquer parte de um pipe falhar

# --- Funções Auxiliares (Usage) ---
usage() {
    cat <<USAGE
Uso: $0 [opções]

Script principal de monitoramento do sistema.
Coleta métricas (CPU, RAM, Disco, Temperatura) baseadas nas variáveis de ambiente
definidas em configs/config.env e registra em logs/git.

Opções:
  -h, --help    Exibe esta mensagem de ajuda e sai.

Dependências:
  git, df, free, uptime, hostname

Exemplo:
  ./scripts/monitor.sh

USAGE
    exit 1
}

# --- Verificação de Argumentos ---
# Verifica help antes de qualquer lógica pesada
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

# --- Inicialização ---
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/configs/config.env"
ERROR_LOG="$BASE_DIR/logs/error.log"

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERRO: $1" >> "$ERROR_LOG"
}

# --- Carregamento de Configurações ---
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "CRITICAL: Configuração não encontrada em $CONFIG_FILE" >&2
    echo "Use --help para mais informações." >&2
    exit 1
fi

# --- Verificação de Dependências ---
for cmd in git df free uptime hostname; do
    if ! command -v $cmd &> /dev/null; then
        log_error "Comando obrigatório '$cmd' não encontrado. Abortando."
        exit 1
    fi
done

# --- Definição de Variáveis de Tempo ---
ANO_ATUAL=$(date +'%Y')
MES_ATUAL=$(date +'%m')
DIA_ATUAL=$(date +'%Y-%m-%d')
HORA_ATUAL=$(date +'%H:%M:%S')

# --- Preparação de Diretórios ---
LOG_PATH="$BASE_DIR/logs/$ANO_ATUAL/$MES_ATUAL"
mkdir -p "$LOG_PATH" || { log_error "Falha ao criar diretório $LOG_PATH"; exit 1; }

ARQUIVO_LOG="$LOG_PATH/monitor_$DIA_ATUAL.log"

# --- Execução da Coleta ---
(
    echo "======================================================================"
    echo "RELATÓRIO: ${PROJECT_NAME:-Monitor} (${ENV_TYPE:-Unknown})"
    echo "Data: $DIA_ATUAL | Hora: $HORA_ATUAL"
    echo "Hostname: $(hostname)"
    echo "======================================================================"
    echo ""

    # CPU
    if [ "${ENABLE_CPU_STATS:-false}" = "true" ]; then
        echo "=== [CPU] ==="
        uptime | awk -F'load average:' '{ print "Load Average:" $2 }' | xargs
        top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print "Uso: " $2 "% user, " $4 "% system, " $8 "% idle"}' || echo "Detalhes de CPU indisponíveis via Top."
        echo ""
    fi

    # Memória
    if [ "${ENABLE_MEM_STATS:-false}" = "true" ]; then
        echo "=== [MEMÓRIA] ==="
        free -h | grep -E "Mem|Swap" || echo "Erro ao ler memória."
        echo ""
    fi

    # Disco
    if [ "${ENABLE_DISK_STATS:-false}" = "true" ]; then
        echo "=== [DISCO] ==="
        df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs -x loop || echo "Erro ao ler disco."
        echo ""
    fi

    # Temperatura
    if [ "${ENABLE_TEMP_STATS:-false}" = "true" ]; then
        echo "=== [TEMPERATURA] ==="
        if [ -d "/sys/class/thermal/thermal_zone0" ]; then
             TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
             if [ -n "$TEMP" ]; then
                echo "CPU Zone0: $(awk "BEGIN {printf \"%.1f\", $TEMP/1000}")°C"
             else
                echo "Erro leitura sensor."
             fi
        else
             echo "Sensores não disponíveis."
        fi
        echo ""
    fi

    echo "----------------------------------------------------------------------"
    echo "Fim da execução: $HORA_ATUAL"
    echo "----------------------------------------------------------------------"
    echo ""

) >> "$ARQUIVO_LOG" 2>> "$ERROR_LOG"

chmod 640 "$ARQUIVO_LOG"

# --- Sincronização Git ---
cd "$BASE_DIR" || { log_error "Falha ao acessar $BASE_DIR para git sync"; exit 1; }

git add logs/

if ! git diff-index --quiet HEAD; then
    if git commit -m "chore(logs): auto-report $DIA_ATUAL [automated]"; then
        if command -v timeout &> /dev/null; then
            PUSH_CMD="timeout 30s git push origin main"
        else
            PUSH_CMD="git push origin main"
        fi

        if ! eval $PUSH_CMD > /dev/null 2>&1; then
            log_error "Falha no git push (Rede ou Permissão SSH)."
        fi
    else
        log_error "Falha ao realizar git commit."
    fi
fi
