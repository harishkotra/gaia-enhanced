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

# Create backup
cp "$dashboard_file" "${dashboard_file}.backup"

# Insert MCP section before the closing </body> tag or at the end
cat >> "$dashboard_file" << 'MCP_SECTION'

<hr>

<div id="mcp-info" class="container">
    <h4>Model Context Protocol (MCP) Support</h4>
    <p>This node supports MCP for programmatic access to AI capabilities. MCP provides a standardized way to discover and interact with node features.</p>
    <p><strong>Your Node URL:</strong> Open the browser console to see your node's public address in the network tab, or check the startup output for <code>https://0x....gaia.domains</code></p>
    
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
                <td><code>/health</code></td>
                <td>Health check</td>
            </tr>
            <tr>
                <td><code>/mcp/info</code></td>
                <td>MCP metadata and capabilities</td>
            </tr>
            <tr>
                <td><code>/v1/mcp/discover</code></td>
                <td>Full MCP discovery information</td>
            </tr>
        </tbody>
    </table>

    <h5>Using MCP with Python</h5>
    <pre><code>import requests

# Replace with your actual node URL from gaianet start output
NODE_URL = "https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaia.domains"

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
    <pre><code># Replace NODE_URL with your actual node URL from gaianet start output
NODE_URL="https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaia.domains"

# Check node health
curl $NODE_URL/health

# Get MCP capabilities
curl $NODE_URL/mcp/info | jq .

# Discover all features
curl $NODE_URL/v1/mcp/discover | jq .
</code></pre>

    <div class="alert alert-info" role="alert">
        <strong>Integrated Gateway:</strong> MCP endpoints are accessible through your public node URL via an integrated gateway. 
        No additional configuration required!
    </div>
</div>
MCP_SECTION

echo "✅ Dashboard patched successfully!"
echo "   Backup saved to: ${dashboard_file}.backup"
