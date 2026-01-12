#!/bin/bash
# -------------------------------------------------------------------------
# Projeto: Monitor de Saúde do Sistema
# Arquivo: monitor.sh
# Descrição: Coleta métricas vitais do sistema (CPU, RAM, Disco, Proc)
#            e salva em log diário para auditoria e versionamento.
# Autor: O2B Team
# -------------------------------------------------------------------------

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$BASE_DIR/logs"
DATA_ATUAL=$(date +'%Y-%m-%d')
HORA_ATUAL=$(date +'%H:%M:%S')
ARQUIVO_LOG="$LOG_DIR/monitor_$DATA_ATUAL.log"

mkdir -p "$LOG_DIR"

{
    echo "======================================================================"
    echo "RELATÓRIO DE SAÚDE DO SISTEMA"
    echo "Data: $DATA_ATUAL | Hora: $HORA_ATUAL"
    echo "Hostname: $(hostname)"
    echo "Sistema: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    echo "======================================================================"
    echo ""

    echo "=== [1] MÉTRICAS DE CPU ==="
    uptime | awk -F'load average:' '{ print "Load Average:" $2 }' | xargs
    top -bn1 | grep "Cpu(s)" | awk '{print "Uso: " $2 "% user, " $4 "% system, " $8 "% idle"}'
    echo ""

    echo "=== [2] USO DE MEMÓRIA ==="
    free -h | awk 'NR==1{printf "%-10s %-10s %-10s %-10s\n", "Tipo", "Total", "Usado", "Livre"} NR==2{printf "%-10s %-10s %-10s %-10s\n", "RAM", $2, $3, $4} NR==3{printf "%-10s %-10s %-10s %-10s\n", "Swap", $2, $3, $4}'
    echo ""

    echo "=== [3] USO DE DISCO (Filesystems Físicos) ==="
    df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs -x loop
    echo ""

    echo "=== [4] TEMPERATURA DO SISTEMA ==="
    if command -v sensors > /dev/null; then
        sensors | grep -E 'Package|Core' | head -4
    elif [ -d "/sys/class/thermal/thermal_zone0" ]; then
        TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        if [ -n "$TEMP_RAW" ]; then
            TEMP_CELSIUS=$(awk "BEGIN {printf \"%.1f\", $TEMP_RAW/1000}")
            echo "Sensor Térmico (Zone0): ${TEMP_CELSIUS}°C"
        else
            echo "Nenhum dado térmico legível encontrado."
        fi
    else
        echo "Sensores não detectados."
    fi
    echo ""

    echo "=== [5] TOP 5 PROCESSOS (Por Consumo de CPU) ==="
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
    echo ""

    echo "======================================================================"
    echo "Fim do relatório."
    echo "======================================================================"

} > "$ARQUIVO_LOG" 2>&1

echo "Coleta finalizada com sucesso."
echo "Relatório salvo em: $ARQUIVO_LOG"

