#!/usr/bin/env python3
"""
Example script demonstrating MCP usage with GaiaNet node

Dependencies:
    pip install requests

Usage:
    # Test locally
    python3 test-mcp.py
    
    # Test remote node
    NODE_URL=https://your-node.gaia.domains python3 test-mcp.py

Or use curl/httpie for testing without Python dependencies.
"""

import json
import os
import sys

# Check for requests library
try:
    import requests
except ImportError:
    print("❌ Error: 'requests' library not found")
    print("\nInstall it with:")
    print("  pip install requests")
    print("\nOr use curl to test MCP endpoints:")
    print("  curl http://127.0.0.1:9090/health")
    print("  curl http://127.0.0.1:9090/v1/mcp/discover | jq .")
    sys.exit(1)

# Get node URL from environment or use localhost
NODE_URL = os.environ.get('NODE_URL', 'http://127.0.0.1:8080')

# Determine if we're testing locally or remotely
is_local = '127.0.0.1' in NODE_URL or 'localhost' in NODE_URL

if is_local:
    # Local testing - MCP gateway on 8080, direct chat/embed ports
    MCP_BASE = NODE_URL
    CHAT_BASE = "http://127.0.0.1:9068"
    EMBED_BASE = "http://127.0.0.1:9069"
else:
    # Remote testing - all through same public URL (proxied via gateway)
    MCP_BASE = NODE_URL
    CHAT_BASE = NODE_URL
    EMBED_BASE = NODE_URL

def test_mcp_health():
    """Test MCP server health"""
    print("🔍 Testing MCP server health...")
    try:
        response = requests.get(f'{MCP_BASE}/health', timeout=5)
        print(f"✅ MCP server is healthy: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ MCP server health check failed: {e}")
        return False

def discover_capabilities():
    """Discover node MCP capabilities"""
    print("\n🔍 Discovering MCP capabilities...")
    try:
        response = requests.get(f'{MCP_BASE}/v1/mcp/discover', timeout=5)
        data = response.json()
        
        print(f"✅ MCP Discovery successful!")
        print(f"   Version: {data['version']}")
        print(f"   Capabilities: {', '.join(data['mcp']['capabilities'])}")
        print(f"   Tools available: {len(data['mcp']['tools'])}")
        
        for tool in data['mcp']['tools']:
            print(f"     - {tool['name']}: {tool['description']}")
        
        return data
    except Exception as e:
        print(f"❌ MCP discovery failed: {e}")
        return None

def test_chat_completion():
    """Test chat completion through discovered endpoint"""
    print("\n🔍 Testing chat completion...")
    try:
        chat_url = f'{CHAT_BASE}/v1/chat/completions' if is_local else f'{CHAT_BASE}/chat/completions'
        response = requests.post(
            chat_url,
            json={
                "messages": [
                    {"role": "system", "content": "You are a helpful assistant."},
                    {"role": "user", "content": "In one sentence, what is the Model Context Protocol?"}
                ]
            },
            timeout=30
        )
        
        data = response.json()
        content = data['choices'][0]['message']['content']
        
        print(f"✅ Chat completion successful!")
        print(f"   Response: {content}")
        return True
    except Exception as e:
        print(f"❌ Chat completion failed: {e}")
        return False

def test_embeddings():
    """Test embeddings endpoint"""
    print("\n🔍 Testing embeddings...")
    try:
        embed_url = f'{EMBED_BASE}/v1/embeddings' if is_local else f'{EMBED_BASE}/embeddings'
        response = requests.post(
            embed_url,
            json={
                "input": "Model Context Protocol enables AI discovery"
            },
            timeout=10
        )
        
        data = response.json()
        embedding = data['data'][0]['embedding']
        
        print(f"✅ Embeddings successful!")
        print(f"   Embedding dimensions: {len(embedding)}")
        print(f"   First 5 values: {embedding[:5]}")
        return True
    except Exception as e:
        print(f"❌ Embeddings failed: {e}")
        return False

def main():
    print("=" * 60)
    print("GaiaNet MCP Integration Test")
    print("=" * 60)
    print(f"\nTesting node at: {NODE_URL}")
    if is_local:
        print("Mode: Local testing (using explicit ports)")
    else:
        print("Mode: Remote testing (using proxied endpoints)")
    print("")
    
    # Test 1: Health check
    if not test_mcp_health():
        print("\n❌ MCP server is not running. Start your node with 'gaianet start'")
        if not is_local:
            print("   Or check that MCP endpoints are properly proxied on the remote node")
        sys.exit(1)
    
    # Test 2: Capability discovery
    mcp_info = discover_capabilities()
    if not mcp_info:
        print("\n❌ Could not discover MCP capabilities")
        sys.exit(1)
    
    # Test 3: Chat completion
    test_chat_completion()
    
    # Test 4: Embeddings (optional - may not be available on all nodes)
    test_embeddings()
    
    print("\n" + "=" * 60)
    print("✅ All MCP tests completed!")
    print("=" * 60)
    print("\n💡 Next steps:")
    print("   - View dashboard: https://<your-node-id>.gaia.domains/")
    print("   - Read docs: README.md (MCP section)")
    print("   - Explore APIs: curl http://127.0.0.1:9090/mcp/info")

if __name__ == '__main__':
    main()
