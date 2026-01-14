#!/usr/bin/env bash
#
# monitor.sh
# Coleta métricas do sistema e registra em logs (Arquivo + JSON Stdout)
#
# Autor: Arthur O2B
#
# ----------------------------------------------------------------------

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/configs/config.env"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/system_metrics.txt"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

mkdir -p "$LOG_DIR"

log_file() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_json() {
    local level="$1"
    local component="$2"
    local msg="$3"
    local metric_name="${4:-null}"
    local metric_value="${5:-0}"
    local timestamp
    timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

    printf '{"timestamp": "%s", "level": "%s", "component": "%s", "message": "%s", "metric": "%s", "value": %s}\n' \
        "$timestamp" "$level" "$component" "$msg" "$metric_name" "$metric_value"
}

check_cpu() {
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    log_file "CPU Usage: ${cpu_usage}%"
    log_json "INFO" "cpu" "Coleta de CPU realizada" "cpu_usage_percent" "$cpu_usage"
}

check_memory() {
    local mem_usage
    mem_usage=$(free -m | awk '/Mem:/ { print $3 }')

    log_file "Memory Usage: ${mem_usage}MB"
    log_json "INFO" "memory" "Coleta de Memoria realizada" "memory_usage_mb" "$mem_usage"
}

check_disk() {
    local disk_usage
    disk_usage=$(df -h / | awk '/\// {print $5}' | sed 's/%//')

    log_file "Disk Usage: ${disk_usage}%"
    log_json "INFO" "disk" "Coleta de Disco realizada" "disk_usage_percent" "$disk_usage"
}

log_file "--- Iniciando Monitoramento ---"
log_json "INFO" "main" "Iniciando ciclo de monitoramento"

if [ "${ENABLE_CPU_STATS:-true}" = "true" ]; then check_cpu; fi
if [ "${ENABLE_MEM_STATS:-true}" = "true" ]; then check_memory; fi
if [ "${ENABLE_DISK_STATS:-true}" = "true" ]; then check_disk; fi

if [ -d "$BASE_DIR/.git" ]; then
    cd "$BASE_DIR"
    git config user.name "${GIT_AUTHOR_NAME:-Monitor Bot}"
    git config user.email "${GIT_AUTHOR_EMAIL:-bot@monitor.local}"

    git add "$LOG_FILE"

if ! git diff --staged --quiet; then
        COMMIT_MSG="chore(logs): auto-report $(date +'%Y-%m-%d') [automated]"
        git commit -m "$COMMIT_MSG" > /dev/null
        log_json "INFO" "git" "Relatorio salvo no git"

        # eval "$PUSH_CMD" > /dev/null 2>&1 || true
    else
        log_json "INFO" "git" "Sem mudancas nos logs para commitar"
    fi
else
    log_json "WARN" "git" "Diretorio .git nao encontrado. Pulo etapa de versionamento."
fi

log_file "--- Fim do Ciclo ---"
log_json "INFO" "main" "Ciclo finalizado"
