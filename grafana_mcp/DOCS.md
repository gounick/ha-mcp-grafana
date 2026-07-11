# Grafana MCP Server

Cette App déploie le [serveur MCP officiel de Grafana](https://github.com/grafana/mcp-grafana)
sur votre instance Home Assistant, afin qu'un client IA (Claude, Cursor, etc.)
puisse dialoguer avec une instance Grafana — typiquement celle déployée via
l'App HA "Grafana" du store officiel.

## Prérequis

1. Une instance Grafana accessible depuis Home Assistant (version 9.0+
   recommandée), par exemple l'App Grafana du store HA.
2. Un **service account token** Grafana avec les permissions nécessaires
   (rôle `Editor` en simple, ou des scopes RBAC granulaires — voir le
   [README amont](https://github.com/grafana/mcp-grafana#rbac-permissions)).

## Configuration rapide

1. Renseignez `grafana_url` (ex : `http://<ip_grafana>:3000` ou l'URL interne
   de l'App Grafana sur le même réseau Docker HA, généralement
   `http://<hostname_app>:3000`).
2. Renseignez `grafana_service_account_token`.
3. Choisissez le **mode de transport** :
   - `streamable-http` _(par défaut, recommandé)_ : protocole HTTP moderne,
     supporte plusieurs clients/sessions simultanés. Endpoint exposé sur
     `http://<ip_ha>:8000/` (défaut du serveur MCP Grafana).
   - `sse` _(legacy)_ : nécessaire pour certains clients plus anciens
     (ex. anciennes configurations VS Code). Endpoint sur
     `http://<ip_ha>:8000/sse`.
4. Démarrez l'App.

## Connexion depuis un client IA

**Streamable HTTP :**

```json
{
  "mcpServers": {
    "grafana": {
      "url": "http://<ip_ha>:8000/"
    }
  }
}
```

**SSE :**

```json
{
  "mcpServers": {
    "grafana": {
      "url": "http://<ip_ha>:8000/sse"
    }
  }
}
```

## Options avancées

- `enabled_tools` : restreint les catégories d'outils exposées (ex :
  `search,dashboard,prometheus,loki`). Voir la liste complète dans le
  [README amont](https://github.com/grafana/mcp-grafana#cli-flags-reference).
- `disable_write` : bascule le serveur en lecture seule (aucune création/
  modification de dashboards, alertes, incidents, annotations…).
- `disable_admin` : activé par défaut, empêche l'exposition des outils de
  gestion des utilisateurs/rôles/permissions Grafana.
- `grafana_extra_headers` : en-têtes HTTP additionnels envoyés à Grafana
  (utile derrière un reverse proxy ou pour un tenant multi-organisation).
- `allowed_hosts` : allowlist des en-têtes `Host` acceptés par le serveur MCP.
  Défaut `"*"` (tous les hôtes). À restreindre si le serveur est exposé.
- `allowed_origins` : allowlist des en-têtes `Origin` acceptés. Laisser vide
  pour refuser les requêtes avec `Origin` (comportement par défaut).
- `metrics` : expose `/metrics` (Prometheus) en plus de l'endpoint MCP.

## Vérification

Un endpoint de santé est exposé (modes `streamable-http`/`sse` uniquement) :

```bash
curl http://<ip_ha>:8000/healthz
```

## Notes

- L'image sous-jacente utilisée pour extraire le binaire est
  `grafana/mcp-grafana:v0.17.1`. Elle est définie directement dans le
  `Dockerfile` via l'argument `MCP_GRAFANA_IMAGE`.
- En mode `stdio` (non exposé ici, réservé aux intégrations locales), aucun
  port HTTP n'est ouvert — ce mode n'est pas proposé par cette App, qui est
  pensée pour un accès réseau depuis un client distant.
