#!/bin/bash
#
# Patch dashboard HTML to include MCP information
# This script adds a dedicated MCP section to the GaiaNet node dashboard
# at the end of the page, after node information, showing MCP endpoints
# and usage examples in Python and cURL
#

set -e

dashboard_file="${1:-$HOME/gaianet/dashboard/chatbot-ui/dashboard/index.html}"

# Fall back to old path if it exists
if [ ! -f "$dashboard_file" ] && [ -f "$HOME/gaianet/dashboard/index.html" ]; then
    dashboard_file="$HOME/gaianet/dashboard/index.html"
fi

if [ ! -f "$dashboard_file" ]; then
    echo "Error: Dashboard file not found at $dashboard_file"
    exit 1
fi

# Check if MCP section already exists
if grep -q "mcp-info" "$dashboard_file" 2>/dev/null; then
    echo "MCP section already exists in dashboard"
    exit 0
fi

echo "Patching dashboard with MCP information..."

# Extract node address from nodeid.json
NODE_ADDRESS=""
if [ -f "$HOME/gaianet/nodeid.json" ]; then
    NODE_ADDRESS=$(grep -o '"address"[[:space:]]*:[[:space:]]*"[^"]*"' "$HOME/gaianet/nodeid.json" | cut -d'"' -f4)
fi

# If nodeid exists, create the full URL, otherwise use a placeholder
if [ -n "$NODE_ADDRESS" ]; then
    NODE_URL="https://${NODE_ADDRESS}.gaia.domains"
else
    NODE_URL="https://YOUR_NODE_ID.gaia.domains"
fi

echo "Using node URL: $NODE_URL"

# Create backup
cp "$dashboard_file" "${dashboard_file}.backup"

# Insert MCP section before the closing </body> tag or at the end
cat >> "$dashboard_file" << MCP_SECTION

<hr>

<div id="mcp-info" class="container">
    <h4>Model Context Protocol (MCP) Support</h4>
    <p>This node supports MCP for programmatic access to AI capabilities. MCP provides a standardized way to discover and interact with node features.</p>
    <p><strong>Your Node URL:</strong> <code>${NODE_URL}</code></p>
    
    <h5>MCP Endpoints</h5>
    <table class="table table-striped">
        <thead>
            <tr>
                <th scope="col">Endpoint</th>
                <th scope="col">Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>${NODE_URL}/health</code></td>
                <td>Health check</td>
            </tr>
            <tr>
                <td><code>${NODE_URL}/mcp/info</code></td>
                <td>MCP metadata and capabilities</td>
            </tr>
            <tr>
                <td><code>${NODE_URL}/v1/mcp/discover</code></td>
                <td>Full MCP discovery information</td>
            </tr>
        </tbody>
    </table>

    <h5>Using MCP with Python</h5>
    <pre><code>import requests

NODE_URL = "${NODE_URL}"

# Discover node capabilities  
response = requests.get(f'{NODE_URL}/v1/mcp/discover')
mcp_info = response.json()
print(f"Capabilities: {mcp_info['mcp']['capabilities']}")

# Use the chat API
chat_url = f"{NODE_URL}/v1/chat/completions"
chat_response = requests.post(chat_url, json={
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"}
    ]
})
print(chat_response.json()['choices'][0]['message']['content'])
</code></pre>

    <h5>Using MCP with cURL</h5>
    <pre><code>NODE_URL="${NODE_URL}"

# Check node health
curl \$NODE_URL/health

# Get MCP capabilities
curl \$NODE_URL/mcp/info | jq .

# Discover all features
curl \$NODE_URL/v1/mcp/discover | jq .
</code></pre>

    <div class="alert alert-info" role="alert">
        <strong>Integrated Gateway:</strong> MCP endpoints are accessible through your public node URL via an integrated gateway. 
        No additional configuration required!
    </div>
</div>

MCP_SECTION

echo "✅ Dashboard patched with MCP information from node: $NODE_ADDRESS"
echo "   Backup saved to: ${dashboard_file}.backup"
