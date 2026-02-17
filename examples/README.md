# MCP Examples

Example scripts and code demonstrating how to use the Model Context Protocol with GaiaNet nodes.

## Quick Start

Make sure your GaiaNet node is running:

```bash
gaianet start
```

Then run one of the test scripts:

```bash
# Test locally (default - recommended)
./examples/test-mcp.sh

# Python version - local
python3 examples/test-mcp.py
```

**Note:** MCP endpoints run on `localhost:9090` by default. For remote access, see [docs/mcp-remote-access.md](../docs/mcp-remote-access.md).

## Available Examples

### test-mcp.sh

**Zero-dependency shell script** for testing MCP endpoints using curl.

**Features:**
- Health check
- Capability discovery
- MCP info retrieval
- Chat completion test
- Colored output
- JSON pretty-printing (if jq is installed)
- Supports both local and remote testing

**Usage:**
```bash
# Local testing (default)
./examples/test-mcp.sh

# Remote testing
NODE_URL=https://0xYOUR-NODE-ID.gaia.domains ./examples/test-mcp.sh
```

**Requirements:**
- curl (standard on macOS/Linux)
- jq (optional, for pretty JSON output)

**How it works:**
- For local URLs (127.0.0.1, localhost): Uses explicit ports (9090, 9068, 9069)
- For remote URLs: Uses same base URL (endpoints are proxied through the node's gateway)

### test-mcp.py

**Python script** demonstrating MCP integration.

**Features:**
- Health check
- Capability discovery with detailed output
- Chat completion
- Embeddings test
- Comprehensive error handling
- Supports both local and remote testing

**Usage:**
```bash
# Install dependencies
pip install requests

# Local testing
python3 examples/test-mcp.py

# Remote testing
NODE_URL=https://0xYOUR-NODE-ID.gaia.domains python3 examples/test-mcp.py
```

**Requirements:**
- Python 3.6+
- requests library

**How it works:**
- Reads `NODE_URL` from environment variable (defaults to http://127.0.0.1)
- For local URLs: Uses explicit ports
- For remote URLs: Uses proxied endpoints through the same domain

## What Gets Tested

Both scripts test the following MCP endpoints:

1. **Health Check** - `GET /health`
   - Verifies MCP server is running
   
2. **MCP Discovery** - `GET /v1/mcp/discover`
   - Returns full MCP metadata including version, capabilities, and tools
   
3. **MCP Info** - `GET /mcp/info`
   - Returns MCP configuration and capabilities
   
4. **Chat Completion** - `POST /v1/chat/completions`
   - Tests the OpenAI-compatible chat endpoint
   
5. **Embeddings** (Python only) - `POST /v1/embeddings`
   - Tests the text embedding endpoint

## Local vs Remote Testing

The test scripts intelligently handle both local and remote node testing:

### Local Testing (Default)
When testing on the same machine where the node is running:
- **MCP endpoints**: `http://127.0.0.1:9090`
- **Chat endpoint**: `http://127.0.0.1:9068`
- **Embedding endpoint**: `http://127.0.0.1:9069`

```bash
./examples/test-mcp.sh
```

### Remote Testing
When testing a node via its public URL:
- **All endpoints**: `https://0xYOUR-NODE-ID.gaia.domains` (proxied)
- No explicit ports needed
- Works from anywhere with internet access

```bash
NODE_URL=https://0xYOUR-NODE-ID.gaia.domains ./examples/test-mcp.sh
```

The scripts automatically detect whether you're testing locally or remotely and adjust the endpoint URLs accordingly.

## Building Your Own Integration

Use these examples as templates for your own applications:

### Basic Pattern

```bash
# 1. Discover capabilities
curl http://127.0.0.1:9090/v1/mcp/discover

# 2. Parse the response to find available endpoints

# 3. Use the endpoints (chat, embeddings, etc.)
curl -X POST http://127.0.0.1:9068/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"messages":[...]}'
```

### Python Pattern

```python
import requests

# Discover
mcp = requests.get('http://127.0.0.1:9090/v1/mcp/discover').json()

# Use
chat = requests.post(
    'http://127.0.0.1:9068/v1/chat/completions',
    json={"messages": [...]}
)
```

## More Examples

For language-specific examples and advanced usage, see:
- [README-MCP.md](../README-MCP.md) - Complete MCP documentation
- [docs/mcp-capabilities.md](../docs/mcp-capabilities.md) - Capability reference
- Node dashboard - `https://<node-id>.gaia.domains/` (includes live examples)

## Troubleshooting

**MCP server not responding?**
- Check if node is running: `gaianet status`
- Verify MCP port: `netstat -an | grep 9090`
- Check logs: `tail -f ~/gaianet/log/mcp-server.log`

**Chat endpoint failing?**
- Ensure node is initialized: `gaianet init`
- Check chat server status on port 9068
- Review node logs: `tail -f ~/gaianet/log/start-llamaedge.log`
