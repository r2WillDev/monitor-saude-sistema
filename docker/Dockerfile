# 1. Imagem Base
FROM debian:stable-slim

# Metadados
LABEL maintainer="Arthur <monitor-saude>"
LABEL description="Container para monitoramento de saúde do sistema"

# 2. Instalação de Dependências
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 3. Criação de Usuário
RUN groupadd -r monitor && useradd -r -g monitor -m -d /home/monitor monitor

# 4. Diretório de Trabalho
WORKDIR /app

# 5. Cópia dos Arquivos
COPY --chown=monitor:monitor scripts/ ./scripts/
COPY --chown=monitor:monitor configs/ ./configs/

# 6. Permissões e Diretórios (CORREÇÃO AQUI)
# Cria o diretório de logs e garante que 'monitor' é o dono de tudo em /app
RUN mkdir -p logs && chown -R monitor:monitor /app && chmod +x ./scripts/*.sh

# 7. Troca para Usuário Seguro
USER monitor

# 8. Execução
CMD ["./scripts/monitor.sh"]
