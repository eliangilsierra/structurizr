# Proyecto base: Structurizr Lite + Cloudflared en Project IDX (Firebase Studio) 🚀

Este repositorio ofrece un **ambiente reproducible con Nix** para **levantar Structurizr Lite** y **exponerlo públicamente** mediante **Cloudflared** (URL `*.trycloudflare.com`) dentro de **Google Project IDX / Firebase Studio**.  
El arranque es **automático** gracias a `dev.nix` y una tarea `onStart`.

---

## ✨ Características

- **OpenJDK 21** preinstalado.
- **Descarga verificada** del `structurizr-lite.war` (detecta WAR corrupto).
- **Ejecución automática** de Structurizr Lite en `:8080`.
- **Zona horaria** fijada a `America/Bogota` para evitar desfaces de fecha/hora.
- **Túnel Cloudflared** automático con URL pública imprimida en consola.
- **Logs** persistidos en archivos (`structurizr.log`, `cloudflared.log`, `cf-url.log`).

---

## 📦 Requisitos

- Un entorno que soporte **Nix** y el archivo `dev.nix` (p. ej., **Project IDX / Firebase Studio**).
- Salida de consola visible para capturar la **URL pública** del túnel.

> Si corres localmente fuera de IDX, necesitas Nix (`nix`), y permisos para ejecutar `cloudflared`.

---

## 🗂️ Estructura esperada

```
.
├─ dev.nix                 # Define paquetes y tareas de arranque (onStart)
├─ structurizr-lite.war    # Se descarga automáticamente si no existe
├─ workspace/              # Carpeta con tu Workspace de Structurizr
│  └─ workspace.dsl        # Ejemplo: tu modelo/diagramas/documentación
├─ structurizr.log         # Log de Structurizr Lite
├─ cloudflared.log         # Log del túnel Cloudflared
└─ cf-url.log              # URL pública extraída del log de Cloudflared
```

> **Importante:** Structurizr Lite toma como raíz `./workspace`. Asegúrate de colocar allí tu `workspace.dsl`, documentación, ADRs, etc.

---

## ▶️ ¿Cómo se ejecuta?

### En Project IDX / “Firebase Studio”
1. Abre el proyecto en tu espacio de trabajo.
2. IDX lee `dev.nix` y **lanza automáticamente** la tarea `onStart` llamada `lanzar-structurizr-lite`.
3. Espera a que aparezca el texto:
   ```
   ✅ Túnel activo. URL pública:
   https://<algo>.trycloudflare.com
   ```
4. Abre la **URL pública** para acceder a Structurizr Lite.

### Local con Nix (opcional)
Si quieres replicar localmente:
```bash
# Entra a un shell con las dependencias declaradas en dev.nix
nix develop -c bash

# Ejecuta manualmente la tarea (copiada del dev.nix si fuera necesario)
# o vuelve a abrir la carpeta en un IDE que respete dev.nix onStart.
```

---

## ⚙️ Qué hace exactamente `dev.nix`

- Instala: `openjdk21`, `cloudflared`, `curl`, `gnugrep`, `coreutils`.
- **Descarga** `structurizr-lite.war` (si no existe) desde:
  ```
  https://github.com/structurizr/lite/releases/download/v2025.05.28/structurizr-lite.war
  ```
- **Valida** el tamaño del WAR (≥ 10 MB) para evitar archivos truncados.
- **Lanza** Structurizr Lite:
  ```bash
  java \
    -Dserver.port=8080 \
    -Duser.timezone=America/Bogota \
    -Dstructurizr.apiKey=abc123 \
    -Dstructurizr.allowInsecure=true \
    -jar structurizr-lite.war ./workspace > structurizr.log 2>&1 &
  ```
- **Abre** un túnel con Cloudflared a `http://localhost:8080` y **extrae** la URL pública al archivo `cf-url.log`.

---

## 🔐 Configuración y seguridad

- `-Dstructurizr.apiKey=abc123` está fijo como **ejemplo**.  
  - **Cámbialo** en `dev.nix` por una clave más robusta antes de exponer el servicio.
- `-Dstructurizr.allowInsecure=true` permite trabajar sin `apiSecret`.  
  - Para entornos más estrictos, considera desactivarlo y usar `apiSecret`.
- La URL `*.trycloudflare.com` es **efímera** (cambia en cada arranque).  
  - Si necesitas un subdominio estable, configura un **túnel autenticado** de Cloudflare con una cuenta y un túnel nombrado.

---

## 📝 Personalizaciones comunes

- **Cambiar puerto**: edita `-Dserver.port=8080` en `dev.nix`.
- **Cambiar zona horaria**: edita `-Duser.timezone=America/Bogota`.  
  Útil si veías **doble fecha** o desfases por TZ.
- **Actualizar versión de Structurizr Lite**: reemplaza la **URL** del WAR por la versión deseada.
- **Ruta del Workspace**: el script usa `./workspace`. Puedes cambiarla en la línea del `java -jar`.

---

## 🔎 Ver la URL pública y los logs

- **URL pública**:
  ```bash
  cat cf-url.log
  ```
- **Log de Structurizr** (aplicación):
  ```bash
  tail -f structurizr.log
  ```
- **Log del túnel**:
  ```bash
  tail -f cloudflared.log
  ```

---

## 🧰 Consejos para tu `workspace/`

- Coloca tu `workspace.dsl` en `./workspace`.
- Carpeta típica:
  ```
  workspace/
  ├─ workspace.dsl
  ├─ documentation/
  ├─ images/
  └─ decisions/          # ADRs
  ```
- Si utilizas ADRs, asegúrate de que la **hora/fecha** de tus decisiones coincida con tu TZ (ver `-Duser.timezone`).

---

## 🆘 Solución de problemas

- **“Could not find or load main class / ClassNotFoundException”**  
  - WAR corrupto o descarga incompleta. El script ya valida tamaño; si falla, borra `structurizr-lite.war` y reinicia.
  - Asegura que **OpenJDK 21** está disponible (lo instala `dev.nix`).
- **No aparece la URL de Cloudflared**  
  - Espera unos segundos más o revisa `cloudflared.log`.  
  - Verifica que el puerto `8080` esté libre y que Structurizr realmente inició (`tail -f structurizr.log`).
- **Fechas desfasadas / dos fechas distintas en ADRs o documentación**  
  - Revisa `-Duser.timezone`. Cambia a tu zona (p. ej., `America/Bogota`) y vuelve a iniciar.
- **Permisos de red restringidos en el entorno**  
  - Algunos entornos bloquean túneles salientes. Revisa las políticas o expón el puerto con la alternativa del propio IDE/plataforma.

---

## 🧪 Comprobación rápida

1. Abre el proyecto en IDX.
2. Espera el mensaje:
   ```
   ✅ Túnel activo. URL pública:
   https://<algo>.trycloudflare.com
   ```
3. Abre la URL y verifica que Structurizr Lite carga y detecta tu `workspace.dsl`.

---