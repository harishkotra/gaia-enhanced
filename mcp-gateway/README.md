# MCP Gateway

Intelligent reverse proxy that routes MCP traffic through the main GaiaNet gateway port.

## Purpose

The MCP Gateway eliminates the need for complex reverse proxy setup by providing a single entry point (port 8080) that intelligently routes traffic to:

- **MCP Server** (port 9090) - for `/health`, `/mcp/*`, `/v1/mcp/*` endpoints
- **Gaia Nexus** (port 8081) - for all other traffic (chat, embeddings, etc.)

This allows MCP endpoints to be accessible through the public node URL without additional configuration.

## Architecture

```
Public URL (https://0x....gaia.domains)
         ↓
    FRP Tunnel
         ↓
  MCP Gateway :8080  ← Single entry point
    ↓           ↓
MCP Server  Gaia Nexus
  :9090       :8081
```

## Building

```bash
# Build for current platform
go build -o mcp-gateway main.go

# Build for all platforms
./build.sh 0.1.0
```

## Running

The gateway is automatically started by `gaianet start`. Manual usage:

```bash
./mcp-gateway
```

Logs will show:
```
MCP Gateway starting on :8080
  - MCP endpoints → localhost:9090
  - Other traffic → localhost:8081 (gaia-nexus)
```

## Configuration

The gateway uses hardcoded ports for simplicity and reliability:
- Listens on: `8080`
- MCP server: `9090`
- Gaia Nexus: `8081`

To modify routing logic, edit `main.go` and rebuild.

## Development

Requirements:
- Go 1.21+

```bash
# Install dependencies (none - uses stdlib only)
go mod tidy

# Build
go build

# Test
./mcp-gateway
# In another terminal:
curl http://127.0.0.1:8080/health
```

## Deployment

The gateway is automatically deployed via `install.sh`:
1. Binary is downloaded for target platform
2. Placed in `$HOME/gaianet/bin/mcp-gateway`
3. Started automatically by gaianet CLI wrapper
4. Logs to `$HOME/gaianet/log/mcp-gateway.log`

## Features

- **Zero dependencies** - Pure Go stdlib
- **Stateless** - No configuration files needed
- **Fast** - Direct reverse proxy, minimal overhead
- **Reliable** - Crash recovery via process manager
- **Logged** - All routing decisions logged
- **Header-preserving** - Maintains all HTTP headers

## Future Enhancements

- [ ] Environment variable configuration
- [ ] Health check endpoints for gateway itself
- [ ] Metrics/prometheus export
- [ ] TLS termination support
- [ ] WebSocket support
