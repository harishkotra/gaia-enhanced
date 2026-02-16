# GaiaNet-MCP Server

Minimal MCP server skeleton for gaia-enhanced. It exposes placeholder endpoints to be wired into node startup and discovery in later phases.

## Endpoints

- GET /health
- GET /mcp/info
- GET /v1/mcp/discover

## Config

Set MCP_CONFIG to a JSON file path. If missing, defaults are used.

Example:

```bash
MCP_CONFIG=mcp_config.sample.json MCP_PORT=9090 cargo run
```
