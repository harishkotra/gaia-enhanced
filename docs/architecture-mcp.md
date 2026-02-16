# GaiaNet-MCP Architecture

This document defines the MCP integration architecture for the gaia-enhanced fork.

## Goals

- Add MCP discovery endpoints to nodes and the registry.
- Expose MCP tool and resource metadata for agents.
- Keep the node runtime lightweight and compatible with existing install flows.

## Components

1. Node MCP metadata
   - Stored alongside existing node registration data.
   - Includes MCP server URL(s), supported transports, and capability list.

2. Node MCP server (new)
   - Runs locally on the node host.
   - Serves MCP over HTTP (primary) and optional stdio.
   - Provides tool/resource schemas and health info.

3. Registry MCP discovery
   - A registry endpoint allows querying nodes by capability.
   - Returns node ID, endpoint URL(s), and capability descriptors.

4. Agent SDK (optional)
   - Helper library for discovery + connection to MCP servers.

## Data Model (high level)

- mcp:
  - enabled: bool
  - http_url: string
  - stdio: bool
  - capabilities: [string]
  - tools: [object]
  - resources: [object]

## API Endpoints

Node:
- GET /v1/mcp/discover
  - Returns MCP metadata and capability descriptors.

Registry:
- GET /nodes/{nodeId}/mcp/info
  - Returns MCP metadata for a specific node.
- GET /nodes/mcp/search?capabilities=chat,knowledge_search
  - Returns nodes matching the requested capabilities.

## Integration Notes

- Node startup scripts start the MCP server after the main node services are live.
- The MCP server reads config.json plus an optional mcp_config.json.
- All MCP endpoints are read-only; no control plane actions in v1.

## Non-goals (v1)

- Push-based discovery or pubsub.
- Multi-tenant MCP routing.
- Automatic tool execution within the node.
