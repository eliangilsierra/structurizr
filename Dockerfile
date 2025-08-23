# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jre-jammy

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates tzdata bash dos2unix git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ===== Variables por defecto =====
ENV PORT=8080 \
    TZ=America/Bogota \
    USER_TIMEZONE=America/Bogota \
    STRUCTURIZR_API_KEY=abc123 \
    STRUCTURIZR_ALLOW_INSECURE=true \
    STRUCTURIZR_WAR_URL=https://github.com/structurizr/lite/releases/download/v2025.05.28/structurizr-lite.war \
    STRUCTURIZR_WORKSPACE_DIR=/app/workspace

# ===== Soporte para clonar repo en build (opcional) =====
# Si GIT_URL está vacío, usaremos COPY del workspace local.
ARG GIT_URL=
ARG GIT_REF=

# Creamos dir de workspace
RUN mkdir -p ${STRUCTURIZR_WORKSPACE_DIR}

# Si NO se pasa GIT_URL, copia la carpeta local "workspace/" al contenedor.
# (Si se pasa GIT_URL en build, este COPY no hará nada perjudicial; el clone lo sobrescribe.)
COPY workspace/ ${STRUCTURIZR_WORKSPACE_DIR}/

# Si se pasa GIT_URL, clona (y opcional checkout GIT_REF)
RUN if [ -n "$GIT_URL" ]; then \
      rm -rf "${STRUCTURIZR_WORKSPACE_DIR}" && \
      git clone "$GIT_URL" "${STRUCTURIZR_WORKSPACE_DIR}" && \
      if [ -n "$GIT_REF" ]; then \
        cd "${STRUCTURIZR_WORKSPACE_DIR}" && git checkout "$GIT_REF" ; \
      fi ; \
    fi

# Script de arranque
ADD <<'EOF' /app/docker-entrypoint.sh
#!/usr/bin/env bash
set -euo pipefail

FILE="structurizr-lite.war"
URL="${STRUCTURIZR_WAR_URL}"

echo "🛠️  Verificando archivo WAR...."
if [ ! -f "$FILE" ]; then
  echo "⬇️  Descargando Structurizr Lite desde $URL..."
  curl -L -f -o "$FILE" "$URL"
else
  echo "📦 $FILE ya existe, omitiendo descarga."
fi

# Verifica tamaño (>10MB) para evitar WAR corrupto
SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE")
if [ "$SIZE" -lt 10000000 ]; then
  echo "❌ ERROR: WAR corrupto o incompleto ($SIZE bytes)." >&2
  rm -f "$FILE"
  exit 1
fi
echo "✅ WAR verificado correctamente ($SIZE bytes)"

# Validación mínima del workspace (que exista workspace.dsl)
if [ ! -f "${STRUCTURIZR_WORKSPACE_DIR}/workspace.dsl" ]; then
  echo "⚠️  Advertencia: No se encontró ${STRUCTURIZR_WORKSPACE_DIR}/workspace.dsl"
  echo "    Asegúrate de que el workspace esté copiado o clonado correctamente."
fi

SERVER_PORT="${PORT:-8080}"
echo "🚀 Iniciando Structurizr en puerto ${SERVER_PORT}..."
exec java \
  -Dserver.port="${SERVER_PORT}" \
  -Duser.timezone="${USER_TIMEZONE}" \
  -Dstructurizr.apiKey="${STRUCTURIZR_API_KEY}" \
  -Dstructurizr.allowInsecure="${STRUCTURIZR_ALLOW_INSECURE}" \
  -jar structurizr-lite.war "${STRUCTURIZR_WORKSPACE_DIR}"
EOF

# Evita el error bash\r si editas en Windows
RUN dos2unix /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS "http://localhost:${PORT:-8080}/" >/dev/null || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
