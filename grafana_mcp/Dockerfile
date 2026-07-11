# syntax=docker/dockerfile:1

# Upstream image containing the official mcp-grafana binary.
# Pin an explicit version instead of "latest" for reproducible builds.
ARG MCP_GRAFANA_VERSION="0.17.1"
FROM grafana/mcp-grafana:${MCP_GRAFANA_VERSION} AS mcp-grafana-src

# Final image based on the Home Assistant App base image (bashio, s6).
FROM ghcr.io/hassio-addons/base:15.0.4

# The upstream image exposes the binary at /app/mcp-grafana.
COPY --from=mcp-grafana-src /app/mcp-grafana /usr/bin/mcp-grafana
RUN chmod +x /usr/bin/mcp-grafana

COPY run.sh /
RUN chmod a+x /run.sh

LABEL \
    io.hass.name="Grafana MCP Server" \
    io.hass.description="MCP server bridging Grafana to AI clients" \
    io.hass.type="app" \
    io.hass.version="1.0.1" \
    io.hass.arch="aarch64|amd64" \
    org.opencontainers.image.title="Grafana MCP Server" \
    org.opencontainers.image.description="MCP server bridging Grafana to AI clients" \
    org.opencontainers.image.source="https://github.com/grafana/mcp-grafana" \
    org.opencontainers.image.licenses="Apache-2.0"

# Run the startup script directly (no s6-overlay needed for a single process).
# bashio is provided by the Home Assistant base image.
CMD ["/run.sh"]
