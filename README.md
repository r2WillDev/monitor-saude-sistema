# 🏥 Monitor de Saúde do Sistema (System Health Monitor)

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square)
![Linux](https://img.shields.io/badge/OS-Debian%20Linux-A81D33?style=flat-square)
![Status](https://img.shields.io/badge/Status-Stable%20v1.0.0-blue?style=flat-square)

> Sistema automatizado de observabilidade, hardening e backup de logs para servidores Linux Debian.

---

## 📘 Descrição do Projeto

Este projeto implementa uma solução de monitoramento *agentless* (sem agente pesado) para servidores Linux. Ele coleta métricas vitais, gera relatórios de auditoria imutáveis e realiza backup automático offsite via Git.

**Problema Resolvido:** Elimina a necessidade de verificação manual diária da saúde do servidor e garante histórico de dados para auditoria em caso de incidentes.

---

## 🧱 Arquitetura e Estrutura

=======
O sistema opera com base na filosofia Unix: ferramentas pequenas e modulares conectadas por pipes e arquivos de texto.


```text
monitor-saude-sistema/
├── configs/
│   └── config.env       # Variáveis de ambiente (Feature flags, caminhos)
├── logs/
│   ├── YYYY/MM/         # Rotação automática de logs por Ano/Mês
│   ├── error.log        # Registro segregado de falhas críticas
│   └── cron_launcher.log # Logs de execução do agendador (Cron)
├── scripts/
│   └── monitor.sh       # Script principal (Engine)
└── README.md            # Esta documentação
```

## ⚙️ Instalação e Configuração

### 1. Pré-requisitos
* Linux Debian/Ubuntu
* Git configurado com chaves SSH
* Pacotes: `coreutils`, `lm-sensors` (opcional)

### 2. Configuração do Cron
O sistema roda automaticamente às 09:00 AM.
Para verificar ou instalar:

```bash
# Verifique se o job existe
crontab -l

# Exemplo de entrada (Caminhos absolutos são obrigatórios):
0 9 * * * /usr/bin/bash /home/usuario/monitor-saude-sistema/scripts/monitor.sh >> /home/usuario/monitor-saude-sistema/logs/cron_launcher.log 2>&1
```

## 🛡️ Segurança (Hardening)

As permissões foram endurecidas para evitar execução não autorizada:

* `scripts/monitor.sh`: **700** (Apenas dono executa)
* `configs/config.env`: **600** (Apenas dono lê)
* `.git/`: **700** (Proteção do histórico)

## 🆘 Disaster Recovery (Restauração)

Se o servidor for perdido, os logs estão salvos no GitHub. Para restaurar em um novo servidor:

1.  Clone o repositório:
    `git clone git@github.com:r2WillDev/monitor-saude-sistema.git`
2.  Restaure as permissões de segurança:
    `chmod 700 scripts/monitor.sh && chmod 600 configs/config.env`
3.  Reconfigure o Cron (ver seção acima).

---

**Status do Projeto:** ✅ Estável / Produção
**Mantenedor:** Equipe DevOps O2B

## ⚙️ Instalação

### Pré-requisitos
- **OS:** Linux Debian 10+ (ou derivados do Ubuntu).
- **Dependências:** `git`, `coreutils`, `curl`.
- **Opcional:** `lm-sensors` (para temperatura de hardware)

### Passo a Passo
1. **Clone o Repositório**
```bash
git clone git@github.com:r2WillDev/monitor-saude-sistema.git
cd monitor-saude-sistema
```
2. **Configure as Permissões (Hardening):** O Script possui travas de segurança. Aplique as permissões restritas:

```bash
chmod 700 scripts/monitor.sh
chmod 600 configs/config.env
```
3. **Teste Manual**

```bash
./scripts/monitor.sh
# verifique se o log foi gerado em logs/yyyy/mm/
```

## 🔄 Automação e Agendamento

A execução é gerenciada pelo `cron`. Para configurar a execução diária às 09:00 AM: 

```bash
# Adicione ao crontab do usuário (crontab -e)
0 9 * * * /usr/bin/bash /caminho/absoluto/para/monitor-saude-sistema/scripts/monitor.sh >> /caminho/absoluto/para/monitor-saude-sistema/logs/cron_launcher.log 2>&1
```

### Fluxo de Dados
1. `Cron` aciona o script.
2. Script coleta métricas (CPU, RAM, Disco, Temp)
3. Dados são anexados ao log do dia (`monitor_YYYY-MM-DD.log`)
4. Script verifica conexão com Git
5. Se houver mudança, realiza `commit` e `push` automáticos

## 🛡 Segurança e Boas Práticas
Este projeto segue práticas de **SRE/DevOps:**
- **Principio de Menor Privilégio:** Arquivos de configuração são legivéis apenas pelo dono (`600`)
- **Fail-Safe:** O script detecta falhas de rede (Git) e registra em `error.log` sem interromper a coleta de dados locais.
- **Idempotência** Execuções repetidas não duplicam commits nem corrompem arquivos
- **Sanitização** Uso de `set -u` e `pipefail` para evitar execução com variáveis não definidas. 
