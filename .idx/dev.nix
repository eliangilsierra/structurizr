{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = [
    pkgs.openjdk21
    pkgs.cloudflared
    pkgs.curl
    pkgs.gnugrep
    pkgs.coreutils
  ];

  idx = {
    previews.enable = false;

    workspace = {
      onStart = {
        lanzar-structurizr-lite = ''
          set -e

          FILE=structurizr-lite.war
          URL=https://github.com/structurizr/lite/releases/download/v2025.05.28/structurizr-lite.war

          echo "🛠️  Verificando archivo WAR...."

          if [ ! -f "$FILE" ]; then
            echo "⬇️  Descargando Structurizr Lite desde $URL..."
            curl -L -f -o "$FILE" "$URL"
          else
            echo "📦 $FILE ya existe, omitiendo descarga."
          fi

          SIZE=$(stat -c%s "$FILE")
          if [ "$SIZE" -lt 10000000 ]; then
            echo "❌ ERROR: WAR corrupto o incompleto ($SIZE bytes)."
            rm -f "$FILE"
            exit 1
          fi
          echo "✅ WAR verificado correctamente ($SIZE bytes)"

          echo "🚀 Iniciando Structurizr en puerto 8080..."
          java -Dserver.port=8080 \
               -Dstructurizr.apiKey=abc123 \
               -Dstructurizr.allowInsecure=true \
               -jar structurizr-lite.war ./workspace > structurizr.log 2>&1 &

          sleep 5

          echo "🌐 Iniciando túnel Cloudflared..."
          cloudflared tunnel --url http://localhost:8080 | tee cloudflared.log &

          echo "⏳ Esperando URL pública de Cloudflare..."
          until grep -m1 -oE "https://[a-z0-9\\-]+\\.trycloudflare\\.com" cloudflared.log > cf-url.log; do
            sleep 1
          done

          echo "✅ Túnel activo. URL pública:"
          cat cf-url.log
        '';
      };
    };
  };
}
