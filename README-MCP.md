# GaiaNet-MCP (gaia-enhanced)

This fork adds Model Context Protocol (MCP) compatibility to GaiaNet nodes while keeping the core node behavior intact. It is intended to be a clean, forward-looking fork that can evolve independently.

## Goals

- Add MCP discovery and capability metadata to nodes.
- Provide a lightweight MCP server component that can be bundled with nodes.
- Keep the install and upgrade flow familiar for existing GaiaNet operators.

## Status

Phase 0 (fork identity + scaffolding) is in progress. See FORK-CHANGES.md for a running list of divergences.

## Installer Source

The installer now defaults to this fork's GitHub releases. If you need to point to a different owner or repo, set:

- GAIA_ENHANCED_REPO_OWNER
- GAIA_ENHANCED_REPO_NAME

Example:

```bash
GAIA_ENHANCED_REPO_OWNER=your-org GAIA_ENHANCED_REPO_NAME=gaia-enhanced ./install.sh
```

## Registry Integration

By default, the gaianet wrapper attempts to register MCP metadata to a registry service at `http://127.0.0.1:9100`. Override the target with:

- REGISTRY_URL

Example:

```bash
REGISTRY_URL=https://registry.example.com ./gaianet start
```

## Upstream

This fork started from GaiaNet-AI/gaianet-node. Upstream development appears inactive; we will periodically cherry-pick fixes if needed.

## Using MCP

Once your GaiaNet node is running, the MCP server is automatically started and **accessible through your public node URL**. An integrated gateway routes MCP traffic seamlessly through the same domain as your main node APIs.

### MCP Endpoints

| Endpoint | Description | Method |
|----------|-------------|--------|
| `/health` | Health check | GET |
| `/mcp/info` | MCP metadata and capabilities | GET |
| `/v1/mcp/discover` | Full MCP discovery information | GET |

### Quick Test

```bash
# Test from anywhere using your public node URL
curl https://0xYOUR-NODE-ID.gaia.domains/health
curl https://0xYOUR-NODE-ID.gaia.domains/v1/mcp/discover | jq .

# Or test locally on the node machine
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/v1/mcp/discover | jq .

# Use test scripts
NODE_URL=https://0xYOUR-NODE-ID.gaia.domains ./examples/test-mcp.sh
python3 examples/test-mcp.py
```

### Python Example

```python
import requests

# Use your public node URL
mcp_base = "https://0xYOUR-NODE-ID.gaia.domains"
chat_base = "https://0xYOUR-NODE-ID.gaia.domains"

# Discover node capabilities
response = requests.get(f'{mcp_base}/v1/mcp/discover')
mcp_info = response.json()

print(f"MCP Version: {mcp_info['version']}")
print(f"Capabilities: {mcp_info['mcp']['capabilities']}")
print(f"Available Tools: {[tool['name'] for tool in mcp_info['mcp']['tools']]}")

# Use the chat API
chat_url = f"{chat_base}/v1/chat/completions"
chat_response = requests.post(chat_url, json={
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What is MCP?"}
    ]
})

print(f"\nChat Response: {chat_response.json()['choices'][0]['message']['content']}")
```

### JavaScript/Node.js Example

```javascript
const fetch = require('node-fetch');

// Use your public node URL
const mcpBase = 'https://0xYOUR-NODE-ID.gaia.domains';
const chatBase = 'https://0xYOUR-NODE-ID.gaia.domains';

async function discoverMCP() {
  // Discover capabilities
  const discoverResponse = await fetch(`${mcpBase}/v1/mcp/discover`);
  const mcpInfo = await discoverResponse.json();
  
  console.log('MCP Capabilities:', mcpInfo.mcp.capabilities);
  
  // Use chat endpoint
  const chatUrl = `${chatBase}/v1/chat/completions`;
  const chatResponse = await fetch(chatUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      messages: [
        { role: 'system', content: 'You are a helpful assistant.' },
        { role: 'user', content: 'Explain the Model Context Protocol.' }
      ]
    })
  });
  
  const chatData = await chatResponse.json();
  console.log('Response:', chatData.choices[0].message.content);
}

discoverMCP();
```

### Dashboard

Your node dashboard at `https://<node-id>.gaia.domains/` includes a dedicated MCP section with:
- Interactive endpoint links (accessible via your public URL)
- Code examples in Python and cURL
- Live testing capabilities

### Configuration

MCP configuration is stored in `$HOME/gaianet/mcp_config.json`:

```json
{
  "enabled": true,
  "http_url": "http://127.0.0.1:9090",
  "stdio": false,
  "capabilities": ["chat", "embeddings", "knowledge_search", "node_info"],
  "tools": [
    {
      "name": "chat.complete",
      "description": "Chat completion",
      "input_schema": {
        "type": "object"
      }
    }
  ],
  "resources": []
}
```

Edit this file and restart the node to customize MCP features.
