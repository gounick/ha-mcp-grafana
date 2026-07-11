# Dépôt d'Apps Home Assistant — Grafana MCP

Dépôt personnalisé contenant l'App **Grafana MCP Server**, qui package le
serveur [MCP](https://modelcontextprotocol.io/) officiel de Grafana
([grafana/mcp-grafana](https://github.com/grafana/mcp-grafana)) pour Home Assistant, afin de
permettre à un client IA de dialoguer avec une instance Grafana.

## Table des matières

- [Home Assistant add-on store](#home-assistant-add-on-store)
- [Structure du dépôt](#structure-du-dépôt)
- [Publication](#publication)
  - [Créer une release](#créer-une-release)
  - [Mise à jour automatique des images](#mise-à-jour-automatique-des-images)
- [Développement](#développement)
- [Notes de sécurité](#notes-de-sécurité)

## Home Assistant add-on store

Cette App est publiée via un **dépôt personnalisé** Home Assistant. Pour
l'installer :

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FGounick%2Fha-mcp-grafana)

Ou dans la boutique d'add-ons Home Assistant, ajoutez manuellement ce dépôt
avec l'URL suivante :

```text
https://github.com/Gounick/ha-mcp-grafana
```

1. Ouvrez Home Assistant : **Paramètres → Add-ons/Apps → Boutique des Apps**
   (ou `Settings → Apps → App Store` selon la version).
2. Cliquez sur le menu **⋮** (trois points, en haut à droite) puis sur **Dépôts**.
3. Ajoutez l'URL ci-dessus.
4. Rafraîchissez la boutique. L'App **Grafana MCP Server** apparaît dans la
   liste.
5. Cliquez sur **Installer** pour télécharger l'image et l'installer sur votre
   instance.
6. Renseignez les options requises (URL Grafana, token de service account,
   hôtes autorisés, etc.) — voir l'onglet **Documentation** de l'App ou le
   fichier `grafana_mcp/DOCS.md` de ce dépôt.
7. Démarrez l'App.

## Structure du dépôt

```text
.
├── .github/
│   └── workflows/
│       ├── builder.yaml      # Build & publish multi-arch GHCR
│       ├── release.yaml      # Création automatique des releases GitHub
│       └── validate.yaml     # Lint YAML / Shellcheck / Hadolint
├── repository.yaml           # Manifeste du dépôt (nom, mainteneur)
├── renovate.json             # Mise à jour automatique des images
├── .pre-commit-config.yaml   # Hooks pre-commit (lint + auto-fix)
└── grafana_mcp/
    ├── config.yaml           # Configuration de l'App (options, ports, arch)
    ├── Dockerfile            # Multi-stage: copie le binaire mcp-grafana
    ├── run.sh                # Script de démarrage (bashio → flags CLI)
    ├── DOCS.md               # Documentation affichée dans l'UI HA
    ├── CHANGELOG.md
    └── translations/
        └── fr.yaml           # Libellés des options en français
```

## Publication

Les images sont construites et publiées automatiquement sur **GitHub Container
Registry** (`ghcr.io`) par le workflow `.github/workflows/builder.yaml` :

- Sur chaque `release` publiée, une image multi-arch `ghcr.io/Gounick/ha-mcp-grafana:<tag>`
  est publiée.
- Sur chaque push sur `main`, une image `edge` est publiée (utile pour les tests).
- `config.yaml` pointe directement vers le manifest multi-arch sur GHCR.

Pour que le workflow fonctionne, assurez-vous que :

1. Le dépôt GitHub permet l'écriture de packages (`Settings → Actions → General →
Workflow permissions` → `Read and write permissions`).
2. Le package GHCR est public ou partagé avec les utilisateurs du dépôt.

### Créer une release

Pour publier une version stable :

1. Mettez à jour `grafana_mcp/config.yaml` (`version:`) et `grafana_mcp/CHANGELOG.md`.
2. Committez et poussez sur `main`.
3. Créez et poussez un tag :

   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

4. Le workflow `.github/workflows/release.yaml` crée automatiquement la release
   GitHub en extrayant la section correspondante du `CHANGELOG.md`.
5. Le workflow `builder.yaml` publie alors
   `ghcr.io/Gounick/ha-mcp-grafana:1.0.1`.

### Mise à jour automatique des images

`renovate.json` configure Renovate pour proposer des PR automatiques lorsque :

- L'image de base Home Assistant (`ghcr.io/hassio-addons/base`) est mise à jour.
- L'image source Grafana MCP (`grafana/mcp-grafana`) est mise à jour.
- Les actions GitHub utilisées dans les workflows sont mises à jour.

## Développement

Un hook `pre-commit` est configuré pour garder le dépôt propre et corriger
automatiquement les petites erreurs. Vous pouvez l'exécuter localement avec
`pre-commit` ou avec [`prek`](https://github.com/j178/prek) (alternative rapide
en Rust, compatible drop-in) :

```bash
# Avec pre-commit
pip install pre-commit
pre-commit install
pre-commit run --all-files

# Avec prek
prek run --all-files
```

Les vérifications incluent : suppression des espaces en fin de ligne,
validation YAML/JSON, `yamllint`, `shellcheck`, `hadolint`, `markdownlint`
(auto-fix) et `prettier`.

Dans les pull requests, le workflow `.github/workflows/prek.yaml` exécute
automatiquement `prek run --all-files` via `j178/prek-action@v2`.

## Notes de sécurité

- Le token de service account Grafana est stocké dans les options de l'App
  (chiffré via le champ `password` du schéma HA), jamais en clair dans le
  Dockerfile ou l'image.
- Par défaut, les outils d'administration Grafana (`disable_admin: true`)
  sont désactivés pour limiter la surface d'action du client IA. Activez-les
  uniquement si nécessaire.
