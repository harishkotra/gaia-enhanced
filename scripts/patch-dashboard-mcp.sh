#!/bin/bash
#
# Patch dashboard HTML to include MCP information
# This script adds a dedicated MCP section to the GaiaNet node dashboard
# at the end of the page, after node information, showing MCP endpoints
# and usage examples in Python and cURL
#

set -e

dashboard_file="${1:-$HOME/gaianet/dashboard/index.html}"

if [ ! -f "$dashboard_file" ]; then
    echo "Error: Dashboard file not found at $dashboard_file"
    exit 1
fi

# Check if MCP section already exists
if grep -q "mcp-info" "$dashboard_file"; then
    echo "MCP section already exists in dashboard"
    exit 0
fi

echo "Patching dashboard with MCP information..."

# Create backup
cp "$dashboard_file" "${dashboard_file}.backup"

# Insert MCP section after the node info table, before the scripts
# Use perl for more reliable multiline replacement
perl -i -pe 'BEGIN{undef $/;} s{(</table>\s*</div>\s*<script src="https://cdn\.jsdelivr\.net/npm/sweetalert2)}{</table>
</div>

<hr>

<div id="mcp-info" class="container">
    <h4>Model Context Protocol (MCP) Support</h4>
    <p>This node supports MCP for programmatic access to AI capabilities. MCP provides a standardized way to discover and interact with node features.</p>
    
    <h5>MCP Endpoints</h5>
    <table class="table table-striped">
        <thead>
            <tr>
                <th scope="col">Endpoint</th>
                <th scope="col">Description</th>
                <th scope="col">Example</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>/health</code></td>
                <td>Health check</td>
                <td><a id="mcp-health-link" href="#" target="_blank">Try it</a></td>
            </tr>
            <tr>
                <td><code>/mcp/info</code></td>
                <td>MCP metadata and capabilities</td>
                <td><a id="mcp-info-link" href="#" target="_blank">Try it</a></td>
            </tr>
            <tr>
                <td><code>/v1/mcp/discover</code></td>
                <td>Full MCP discovery information</td>
                <td><a id="mcp-discover-link" href="#" target="_blank">Try it</a></td>
            </tr>
        </tbody>
    </table>

    <h5>Using MCP with Python</h5>
    <pre><code id="mcp-python-example">import requests

# Discover node capabilities
response = requests.get('\''<mcp_base_url>/v1/mcp/discover'\'')
mcp_info = response.json()
print(f"Capabilities: {mcp_info['\''mcp'\'']['\''capabilities'\'']}")

# Use the chat API through MCP discovery
chat_url = "<public_url>/v1/chat/completions"
chat_response = requests.post(chat_url, json={
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"}
    ]
})
print(chat_response.json()['\''choices'\''][0]['\''message'\'']['\''content'\''])
</code></pre>

    <h5>Using MCP with cURL</h5>
    <pre><code id="mcp-curl-example"># Check node health
curl <mcp_base_url>/health

# Get MCP capabilities
curl <mcp_base_url>/mcp/info | jq .

# Discover all features
curl <mcp_base_url>/v1/mcp/discover | jq .
</code></pre>

    <div class="alert alert-info" role="alert">
        <strong>Integrated Gateway:</strong> MCP endpoints are accessible through your public node URL via an integrated gateway. 
        No additional configuration required!
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2$1}sm' "$dashboard_file"

# Now add the JavaScript to update MCP URLs dynamically
perl -i -pe 'BEGIN{undef $/;} s{(document\.getElementById\("api-req"\)\.innerHTML = code_snippet\.replace\("<public_url>", window\.location\.protocol \+ "//" \+ window\.location\.host\);)(.*?)(}\)\.catch)}{$1

        // Update MCP URLs dynamically
        var baseUrl = window.location.protocol + "//" + window.location.host;
        var mcpBaseUrl = baseUrl;
        
        // Update MCP endpoint links
        if (document.getElementById("mcp-health-link")) {
            document.getElementById("mcp-health-link").href = mcpBaseUrl + "/health";
        }
        if (document.getElementById("mcp-info-link")) {
            document.getElementById("mcp-info-link").href = mcpBaseUrl + "/mcp/info";
        }
        if (document.getElementById("mcp-discover-link")) {
            document.getElementById("mcp-discover-link").href = mcpBaseUrl + "/v1/mcp/discover";
        }
        
        // Update MCP Python example
        if (document.getElementById("mcp-python-example")) {
            var pythonExample = document.getElementById("mcp-python-example").innerHTML;
            pythonExample = pythonExample.replace(/<mcp_base_url>/g, "'\''" + mcpBaseUrl + "'\''");
            pythonExample = pythonExample.replace(/<public_url>/g, "'\''" + baseUrl + "'\''");
            document.getElementById("mcp-python-example").innerHTML = pythonExample;
        }
        
        // Update MCP cURL example
        if (document.getElementById("mcp-curl-example")) {
            var curlExample = document.getElementById("mcp-curl-example").innerHTML;
            curlExample = curlExample.replace(/<mcp_base_url>/g, mcpBaseUrl);
            document.getElementById("mcp-curl-example").innerHTML = curlExample;
        }
$2$3}sm' "$dashboard_file"

echo "✅ Dashboard patched successfully!"
echo "   Backup saved to: ${dashboard_file}.backup"
