#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Grafana MCP Server - démarrage
# ==============================================================================
set -e

# ---- Lecture des options utilisateur ---------------------------------------
TRANSPORT_MODE=$(bashio::config 'transport_mode')
ADDRESS=$(bashio::config 'address')
GRAFANA_URL=$(bashio::config 'grafana_url')
SA_TOKEN=$(bashio::config 'grafana_service_account_token')
GRAFANA_USERNAME=$(bashio::config 'grafana_username')
GRAFANA_PASSWORD=$(bashio::config 'grafana_password')
GRAFANA_ORG_ID=$(bashio::config 'grafana_org_id')
EXTRA_HEADERS=$(bashio::config 'grafana_extra_headers')
ENABLED_TOOLS=$(bashio::config 'enabled_tools')
ALLOWED_HOSTS=$(bashio::config 'allowed_hosts')
ALLOWED_ORIGINS=$(bashio::config 'allowed_origins')
LOG_LEVEL=$(bashio::config 'log_level')
IDLE_TIMEOUT=$(bashio::config 'session_idle_timeout_minutes')

# ---- Validation minimale ----------------------------------------------------
if bashio::var.is_empty "${GRAFANA_URL}"; then
    bashio::exit.nok "L'option 'grafana_url' est obligatoire."
fi

if bashio::var.is_empty "${SA_TOKEN}" && bashio::var.is_empty "${GRAFANA_USERNAME}"; then
    bashio::log.warning "Aucun token de compte de service ni identifiants définis : les appels à Grafana échoueront tant que l'authentification n'est pas configurée."
fi

# ---- Choix du mode de transport --------------------------------------------
# Le binaire mcp-grafana accepte: stdio | sse | streamable-http
case "${TRANSPORT_MODE}" in
    "sse")
        TRANSPORT_FLAG="sse"
        bashio::log.info "Mode de transport : SSE"
        ;;
    "streamable-http"|*)
        TRANSPORT_FLAG="streamable-http"
        bashio::log.info "Mode de transport : Streamable HTTP"
        ;;
esac

# ---- Construction des variables d'environnement pour l'authentification ----
export GRAFANA_URL="${GRAFANA_URL}"

if ! bashio::var.is_empty "${SA_TOKEN}"; then
    export GRAFANA_SERVICE_ACCOUNT_TOKEN="${SA_TOKEN}"
fi

if ! bashio::var.is_empty "${GRAFANA_USERNAME}"; then
    export GRAFANA_USERNAME="${GRAFANA_USERNAME}"
    export GRAFANA_PASSWORD="${GRAFANA_PASSWORD}"
fi

if ! bashio::var.is_empty "${GRAFANA_ORG_ID}"; then
    export GRAFANA_ORG_ID="${GRAFANA_ORG_ID}"
fi

if ! bashio::var.is_empty "${EXTRA_HEADERS}"; then
    export GRAFANA_EXTRA_HEADERS="${EXTRA_HEADERS}"
fi

# ---- Construction des arguments CLI ----------------------------------------
ARGS=(
    "-t" "${TRANSPORT_FLAG}"
    "--address" "${ADDRESS}"
    "--log-level" "${LOG_LEVEL}"
    "--session-idle-timeout-minutes" "${IDLE_TIMEOUT}"
)

if ! bashio::var.is_empty "${ENABLED_TOOLS}"; then
    ARGS+=("--enabled-tools" "${ENABLED_TOOLS}")
fi

if ! bashio::var.is_empty "${ALLOWED_HOSTS}"; then
    ARGS+=("--allowed-hosts" "${ALLOWED_HOSTS}")
fi

if ! bashio::var.is_empty "${ALLOWED_ORIGINS}"; then
    ARGS+=("--allowed-origins" "${ALLOWED_ORIGINS}")
fi

if bashio::config.true 'disable_write'; then
    ARGS+=("--disable-write")
fi

if bashio::config.true 'disable_admin'; then
    ARGS+=("--disable-admin")
fi

if bashio::config.true 'debug'; then
    ARGS+=("--debug")
fi

if bashio::config.true 'metrics'; then
    ARGS+=("--metrics")
fi

bashio::log.info "URL Grafana cible : ${GRAFANA_URL}"
bashio::log.info "Démarrage de mcp-grafana avec les arguments : ${ARGS[*]}"

exec /usr/bin/mcp-grafana "${ARGS[@]}"
