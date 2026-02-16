POST http://127.0.0.1:9100/nodes/register
Content-Type: application/json
{
  "node_id": "node-123",
  "public_url": "https://node-123.local",
  "mcp": {
    "enabled": true,
    "http_url": "http://127.0.0.1:9090",
    "stdio": false,
    "capabilities": ["chat", "embeddings", "knowledge_search"],
    "tools": [],
    "resources": []
  }
}
HTTP/1.1 200

GET http://127.0.0.1:9100/nodes/node-123/mcp/info
HTTP/1.1 200

GET http://127.0.0.1:9100/nodes/mcp/search?capabilities=chat,knowledge_search
HTTP/1.1 200
