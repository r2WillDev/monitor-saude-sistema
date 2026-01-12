#!/bin/bash
# -------------------------------------------------------------------------
# Projeto: Monitor de Saúde do Sistema
# Arquivo: monitor.sh
# Descrição: Coleta métricas e salva em log diário (com rotação mensal).
# Autor: O2B team
# -------------------------------------------------------------------------

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/configs/config.env"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Erro: Arquivo de configuração não encontrado em $CONFIG_FILE"
    exit 1
fi

ANO_ATUAL=$(date +'%Y')
MES_ATUAL=$(date +'%m')
DIA_ATUAL=$(date +'%Y-%m-%d')
HORA_ATUAL=$(date +'%H:%M:%S')

LOG_PATH="$BASE_DIR/logs/$ANO_ATUAL/$MES_ATUAL"
mkdir -p "$LOG_PATH"

ARQUIVO_LOG="$LOG_PATH/monitor_$DIA_ATUAL.log"

{
    echo "======================================================================"
    echo "RELATÓRIO: $PROJECT_NAME ($ENV_TYPE)"
    echo "Data: $DIA_ATUAL | Hora: $HORA_ATUAL"
    echo "Hostname: $(hostname)"
    echo "======================================================================"
    echo ""

    if [ "$ENABLE_CPU_STATS" = "true" ]; then
        echo "=== [CPU] ==="
        uptime | awk -F'load average:' '{ print "Load Average:" $2 }' | xargs
        top -bn1 | grep "Cpu(s)" | awk '{print "Uso: " $2 "% user, " $4 "% system, " $8 "% idle"}'
        echo ""
    fi

    if [ "$ENABLE_MEM_STATS" = "true" ]; then
        echo "=== [MEMÓRIA] ==="
        free -h | grep -E "Mem|Swap"
        echo ""
    fi

    if [ "$ENABLE_DISK_STATS" = "true" ]; then
        echo "=== [DISCO] ==="
        df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs -x loop
        echo ""
    fi

    if [ "$ENABLE_TEMP_STATS" = "true" ]; then
        echo "=== [TEMPERATURA] ==="
        if [ -d "/sys/class/thermal/thermal_zone0" ]; then
             TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
             echo "CPU Zone0: $(awk "BEGIN {printf \"%.1f\", $TEMP/1000}")°C"
        else
             echo "Sensores não disponíveis."
        fi
        echo ""
    fi

    echo "----------------------------------------------------------------------"
    echo "Fim da execução: $HORA_ATUAL"
    echo "----------------------------------------------------------------------"
    echo ""

} >> "$ARQUIVO_LOG" 2>&1

chmod 640 "$ARQUIVO_LOG"

echo "Coleta realizada."
echo "Log salvo em: $ARQUIVO_LOG"
