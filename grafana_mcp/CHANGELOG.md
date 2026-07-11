# Changelog

## 1.0.1

- Correction de l'image source : `grafana/mcp-grafana:v0.17.1` (au lieu de
  `mcp/grafana:latest`).
- Migration de `build.yaml` obsolète vers un `Dockerfile` moderne avec image de
  base explicite.
- Correction du nom d'image HA : `grafana-mcp` (au lieu de `{arch}-grafana-mcp`).
- Ajout des options `allowed_hosts` et `allowed_origins` pour corriger les
  erreurs 403 dues à la validation Host/Origin du serveur MCP Grafana.
- Suppression de `jq` inutile et mise à jour des labels `io.hass.*`.
- Ajout d'un healthcheck et correction de la description du port (endpoint
  Streamable HTTP par défaut : `/`).

## 1.0.0

- Version initiale : packaging du serveur MCP Grafana officiel
  (`grafana/mcp-grafana`, alias `mcp/grafana`) comme App Home Assistant.
- Support des modes de transport Streamable HTTP (par défaut) et SSE.
- Authentification par token de service account ou identifiants
  utilisateur/mot de passe, support multi-organisation, en-têtes HTTP
  additionnels.
- Options `disable_write` / `disable_admin` / `enabled_tools` pour
  restreindre les capacités exposées au client IA.
