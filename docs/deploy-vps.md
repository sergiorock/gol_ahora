# Deploy simple en VPS

Este proyecto queda preparado para deploy automático con GitHub Actions hacia un VPS usando:

- `main` como branch de deploy
- `docker compose` en el servidor
- `Caddy` para HTTPS
- `Postgres` en el mismo `compose`

## Estructura en el VPS

La app vive en:

```text
/home/deploy/apps/gol_ahora
```

El workflow hace esto en cada push exitoso a `main`:

1. actualiza `/home/deploy/apps/gol_ahora`
2. escribe `.env.production`
3. reconstruye contenedores
4. corre `bin/rails db:prepare`

## Requisitos del VPS

El usuario `deploy` tiene que:

- poder entrar por SSH con clave
- pertenecer al grupo `docker`
- tener instalado Docker Engine y el plugin `docker compose`

Chequeos útiles:

```bash
ssh deploy@187.77.46.31
docker --version
docker compose version
groups
```

## Bootstrap inicial

Esto se hace una sola vez en el VPS:

```bash
mkdir -p /home/deploy/apps/gol_ahora
sudo usermod -aG docker deploy
```

Después cerrá sesión y volvé a entrar para que tome el grupo `docker`.

## GitHub Secrets

Configurá estos secrets en el repo:

- `VPS_SSH_KEY`: clave privada que GitHub Actions va a usar para entrar al VPS
- `APP_ENV_FILE`: contenido completo de `.env.production`

## Ejemplo de `APP_ENV_FILE`

Tomá como base [`../.env.production.example`](/home/sergio/workspace/ingenieria/gol_ahora/.env.production.example).

Puntos mínimos:

- `APP_DOMAIN=golahora.gemaroja.com.ar`
- `POSTGRES_PASSWORD=` con una contraseña real
- `SECRET_KEY_BASE=` generado con `bin/rails secret`

## Logs

Para ver errores en el VPS:

```bash
cd /home/deploy/apps/gol_ahora
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f web
docker compose --env-file .env.production -f docker-compose.prod.yml logs -f caddy
```

## Nota sobre errores detallados

Por defecto el deploy corre en `RAILS_ENV=production`.

Si durante QA querés mostrar páginas de error detalladas temporalmente, podés poner:

```text
RAILS_SHOW_FULL_ERRORS=true
```

en `.env.production` y redeployar. No conviene dejarlo prendido de forma permanente.
