#!/bin/bash
#
# Simple MCP test script using curl
# No dependencies required except curl and jq (optional)
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default to localhost, but can be overridden with NODE_URL environment variable
NODE_URL="${NODE_URL:-http://127.0.0.1:8080}"

# For localhost, use port 8080 (MCP gateway). For remote URLs, use same base URL
if [[ "$NODE_URL" == *"127.0.0.1"* ]] || [[ "$NODE_URL" == *"localhost"* ]]; then
    # Local testing through MCP gateway on port 8080
    MCP_URL="${NODE_URL}"
    CHAT_URL="http://127.0.0.1:9068"
    EMBED_URL="http://127.0.0.1:9069"
else
    # Remote testing - all through same public URL
    MCP_URL="${NODE_URL}"
    CHAT_URL="${NODE_URL}"
    EMBED_URL="${NODE_URL}"
fi

echo "============================================================"
echo "GaiaNet MCP Integration Test"
echo "============================================================"
echo ""
echo "Testing node at: $NODE_URL"
if [[ "$NODE_URL" == *"127.0.0.1"* ]] || [[ "$NODE_URL" == *"localhost"* ]]; then
    echo "Local testing mode - using explicit ports"
else
    echo "Remote testing mode - using proxied endpoints"
    echo "Set NODE_URL=http://127.0.0.1 to test locally"
fi
echo ""

# Test 1: Health check
echo -e "${BLUE}🔍 Testing MCP server health...${NC}"
if response=$(curl -sf "$MCP_URL/health" 2>/dev/null); then
    echo -e "${GREEN}✅ MCP server is healthy${NC}"
    if command -v jq >/dev/null 2>&1; then
        echo "$response" | jq .
    else
        echo "$response"
    fi
else
    echo -e "${RED}❌ MCP server health check failed${NC}"
    echo -e "${YELLOW}Make sure your node is running: gaianet start${NC}"
    exit 1
fi

echo ""

# Test 2: MCP Discovery
echo -e "${BLUE}🔍 Discovering MCP capabilities...${NC}"
if response=$(curl -sf "$MCP_URL/v1/mcp/discover" 2>/dev/null); then
    echo -e "${GREEN}✅ MCP discovery successful${NC}"
    
    if command -v jq >/dev/null 2>&1; then
        version=$(echo "$response" | jq -r '.version')
        capabilities=$(echo "$response" | jq -r '.mcp.capabilities | join(", ")')
        tools=$(echo "$response" | jq -r '.mcp.tools[].name')
        
        echo "   Version: $version"
        echo "   Capabilities: $capabilities"
        echo "   Tools:"
        echo "$tools" | while read -r tool; do
            echo "     - $tool"
        done
    else
        echo "$response"
        echo ""
        echo -e "${YELLOW}💡 Install jq for prettier output: brew install jq${NC}"
    fi
else
    echo -e "${RED}❌ MCP discovery failed${NC}"
    exit 1
fi

echo ""

# Test 3: MCP Info endpoint
echo -e "${BLUE}🔍 Getting MCP info...${NC}"
if response=$(curl -sf "$MCP_URL/mcp/info" 2>/dev/null); then
    echo -e "${GREEN}✅ MCP info retrieved${NC}"
    
    if command -v jq >/dev/null 2>&1; then
        echo "$response" | jq .
    else
        echo "$response"
    fi
else
    echo -e "${RED}❌ MCP info request failed${NC}"
fi

echo ""

# Test 4: Chat completion
echo -e "${BLUE}🔍 Testing chat completion...${NC}"
if response=$(curl -sf -X POST "$CHAT_URL/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d '{"messages":[{"role":"system","content":"You are a helpful assistant."},{"role":"user","content":"In one sentence, what is the Model Context Protocol?"}]}' 2>/dev/null); then
    
    echo -e "${GREEN}✅ Chat completion successful${NC}"
    
    if command -v jq >/dev/null 2>&1; then
        content=$(echo "$response" | jq -r '.choices[0].message.content')
        echo "   Response: $content"
    else
        echo "$response"
    fi
else
    echo -e "${RED}❌ Chat completion failed${NC}"
fi

echo ""
echo "============================================================"
echo -e "${GREEN}✅ All MCP tests completed!${NC}"
echo "============================================================"
echo ""
echo "💡 Next steps:"
echo "   - View dashboard: https://<your-node-id>.gaia.domains/"
echo "   - Read docs: cat README-MCP.md"
echo "   - Explore API: curl $MCP_URL/mcp/info | jq ."
echo ""
