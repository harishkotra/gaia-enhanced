# MCP Remote Access Guide

> **Note:** As of v0.6.0, MCP endpoints are **accessible by default** through your public node URL via an integrated gateway. This guide is kept for reference and advanced use cases.

## Overview

GaiaNet nodes now include an integrated MCP gateway that automatically routes MCP traffic through your public domain (e.g., `https://0x....gaia.domains`). The gateway runs on port 8080 and intelligently proxies:

- **MCP endpoints** (`/health`, `/mcp/*`, `/v1/mcp/*`) → MCP server on port 9090
- **All other traffic** → gaia-nexus on port 8081

##  Current Architecture

```
Internet → FRP Tunnel → MCP Gateway:8080 → MCP Server:9090 (for MCP endpoints)
                                         → gaia-nexus:8081 (for other APIs)
```

The MCP gateway is automatically started when you run `gaianet start`.

## Default Access

### Finding Your Node URL

When you run `gaianet start`, the output displays your node's public URL:

```
... https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaia.domains
```

### Using Your Node URL

Replace `0xf63939431ee11267f4855a166e11cc44d24960c0` with your actual node ID in all requests:

```bash
# Public access works out of the box
curl https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaia.domains/health
curl https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaia.domains/v1/mcp/discover | jq .

# Local access also works
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/v1/mcp/discover | jq .
```

## Advanced: Custom Gateway Configuration

If you need to customize the gateway behavior or use a different architecture, you can modify the MCP gateway source at `mcp-gateway/main.go` in the repository.

### Gateway Features

- Written in Go for performance and reliability
- Intelligent path-based routing
- Preserves all HTTP headers
- Logs all routing decisions
- Zero-configuration deployment

### Manual Installation (Advanced)

If you want to run the gateway separately:

1. Build the gateway:
```bash
cd mcp-gateway
go build -o mcp-gateway main.go
```

2. Run it:
```bash
./mcp-gateway
```

The gateway will listen on port 8080 and route traffic to:
- MCP server on `localhost:9090`
- gaia-nexus on `localhost:8081`

## Need Help?

- GitHub Issues: https://github.com/harishkotra/gaia-enhanced/issues
- Documentation: https://github.com/harishkotra/gaia-enhanced/blob/main/README.md#model-context-protocol
- Examples: Explore `examples/` directory for testing scripts
