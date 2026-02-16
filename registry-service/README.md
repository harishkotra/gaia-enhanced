# GaiaNet Registry Service (MCP)

Lightweight registry service for MCP discovery in the gaia-enhanced fork.

## Endpoints

- POST /nodes/register
- GET /nodes/{nodeId}/mcp/info
- GET /nodes/mcp/search?capabilities=chat,knowledge_search
- GET /health

## Usage

```bash
REGISTRY_DATA=registry.json REGISTRY_PORT=9100 cargo run
```

## Register example

```bash
curl -X POST http://127.0.0.1:9100/nodes/register \
  -H 'Content-Type: application/json' \
  -d @registry.sample.json
```
