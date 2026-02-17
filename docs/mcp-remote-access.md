# MCP Remote Access Guide

## Overview

The MCP server runs on `localhost:9090` and is designed for local development and testing. By default, it's **not accessible through your node's public domain** (e.g., `https://0x....gaia.domains`) because the GaiaNet gateway (`gaia-nexus`) doesn't proxy MCP endpoints.

##  Current Architecture

```
Internet → FRP Tunnel → gaia-nexus:8080 → Chat/Embedding APIs
                                        ↛ MCP Server:9090 (not proxied)
```

The MCP server is a separate process that needs explicit routing configuration to be accessible remotely.

## Access Options

### Option 1: Local Access (Recommended for Development)

The simplest and most secure approach for development and testing:

```bash
# Test locally on the node machine
curl http://127.0.0.1:9090/health
curl http://127.0.0.1:9090/v1/mcp/discover | jq .

# Use test scripts
./examples/test-mcp.sh
python3 examples/test-mcp.py
```

### Option 2: SSH Tunnel (Recommended for Remote Testing)

Securely access MCP endpoints from a remote machine:

```bash
# From your local machine, create SSH tunnel to your node
ssh -L 9090:localhost:9090 user@your-node-server

# In another terminal, access MCP as if it were local
curl http://127.0.0.1:9090/health
curl http://127.0.0.1:9090/v1/mcp/discover | jq .

# Or use test scripts with local URLs
./examples/test-mcp.sh
```

### Option 3: Reverse Proxy (For Production Public Access)

To make MCP endpoints publicly accessible, you need to configure a reverse proxy. Here are solutions for common setups:

#### Option 3a: Nginx Reverse Proxy

Add this to your nginx configuration:

```nginx
# /etc/nginx/sites-available/gaianet-mcp
server {
    listen 443 ssl http2;
    server_name 0xYOUR-NODE-ID.gaia.domains;
    
    # Your SSL certificates
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Proxy main traffic to gaia-nexus
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Proxy MCP endpoints to MCP server
    location /health {
        proxy_pass http://127.0.0.1:9090;
        proxy_set_header Host $host;
    }
    
    location /mcp/ {
        proxy_pass http://127.0.0.1:9090;
        proxy_set_header Host $host;
    }
    
    location /v1/mcp/ {
        proxy_pass http://127.0.0.1:9090;
        proxy_set_header Host $host;
    }
}
```

Enable and reload:
```bash
sudo ln -s /etc/nginx/sites-available/gaianet-mcp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### Option 3b: Caddy Reverse Proxy

Create a `Caddyfile`:

```caddy
0xYOUR-NODE-ID.gaia.domains {
    # Proxy MCP endpoints
    handle /health {
        reverse_proxy localhost:9090
    }
    
    handle /mcp/* {
        reverse_proxy localhost:9090
    }
    
    handle /v1/mcp/* {
        reverse_proxy localhost:9090
    }
    
    # Proxy everything else to gaia-nexus
    handle {
        reverse_proxy localhost:8080
    }
}
```

Run Caddy:
```bash
caddy run
```

#### Option 3c: Simple Go Proxy

For a lightweight solution, create a simple Go proxy:

```go
// proxy.go
package main

import (
    "log"
    "net/http"
    "net/http/httputil"
    "net/url"
    "strings"
)

func main() {
    mcpURL, _ := url.Parse("http://127.0.0.1:9090")
    nexusURL, _ := url.Parse("http://127.0.0.1:8080")
    
    mcpProxy := httputil.NewSingleHostReverseProxy(mcpURL)
    nexusProxy := httputil.NewSingleHostReverseProxy(nexusURL)
    
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        if r.URL.Path == "/health" || 
           strings.HasPrefix(r.URL.Path, "/mcp/") || 
           strings.HasPrefix(r.URL.Path, "/v1/mcp/") {
            mcpProxy.ServeHTTP(w, r)
        } else {
            nexusProxy.ServeHTTP(w, r)
        }
    })
    
    log.Println("Proxy listening on :8081")
    log.Fatal(http.ListenAndServe(":8081", nil))
}
```

Build and run:
```bash
go build -o gaianet-proxy proxy.go
./gaianet-proxy
```

Then update your FRP configuration to use port 8081 instead of 8080.

### Option 4: FRP Multi-Port Configuration

Modify `frpc.toml` to expose both gaia-nexus and MCP server:

```toml
serverAddr = "gaia.domains"
serverPort = 7000
metadatas.deviceId = "your-device-id"

# Main gateway (gaia-nexus)
[[proxies]]
name = "0xYOUR-NODE-ID.gaia.domains"
type = "http"
localPort = 8080
subdomain = "0xYOUR-NODE-ID"

# MCP server (requires available port on FRP server)
[[proxies]]
name = "0xYOUR-NODE-ID-mcp.gaia.domains"
type = "http"
localPort = 9090
subdomain = "0xYOUR-NODE-ID-mcp"
```

**Note:** This requires the FRP server to support multiple subdomains for your account.

## Recommended Setup by Use Case

| Use Case | Recommended Solution | Why |
|----------|---------------------|-----|
| Local development | Direct localhost access | Simple, secure, no setup |
| Testing from remote machine | SSH tunnel | Secure, no server config |
| Production API access | Nginx/Caddy reverse proxy | Professional, SSL support |
| Custom infrastructure | Simple Go proxy | Lightweight, customizable |

## Security Considerations

When exposing MCP endpoints publicly:

1. **Authentication**: Add API key validation in your reverse proxy
2. **Rate Limiting**: Implement rate limits to prevent abuse
3. **HTTPS**: Always use SSL/TLS for public endpoints
4. **Firewall**: Restrict access by IP if possible
5. **Monitoring**: Log and monitor MCP endpoint access

Example nginx with basic auth:

```nginx
location /mcp/ {
    auth_basic "MCP Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://127.0.0.1:9090;
}
```

## Testing Remote Access

After setting up remote access:

```bash
# Test health
curl https://0xYOUR-NODE-ID.gaia.domains/health

# Test discovery
curl https://0xYOUR-NODE-ID.gaia.domains/v1/mcp/discover | jq .

# Use test script with remote URL
NODE_URL=https://0xYOUR-NODE-ID.gaia.domains ./examples/test-mcp.sh
```

## Troubleshooting

### MCP endpoints return 404
- Verify MCP server is running: `ps aux | grep gaianet-mcp-server`
- Check MCP server port: `netstat -an | grep 9090`
- Test direct local access: `curl http://127.0.0.1:9090/health`

### Reverse proxy not working
- Check proxy logs for errors
- Verify proxy can reach localhost:9090
- Test proxy configuration: `nginx -t` or `caddy validate`
- Check firewall rules: `sudo ufw status`

### SSL/TLS errors
- Ensure certificates are valid and not expired
- Verify certificate paths in proxy config
- Check certificate permissions

## Future Improvements

We're working on making MCP endpoints accessible by default:

- [ ] Integrate MCP routing into gaia-nexus
- [ ] Add MCP port to default FRP configuration
- [ ] Create automated reverse proxy setup script
- [ ] Add MCP gateway to installer

## Need Help?

- GitHub Issues: https://github.com/harishkotra/gaia-enhanced/issues
- Documentation: https://github.com/harishkotra/gaia-enhanced/blob/main/README-MCP.md
- Examples: Explore `examples/` directory for testing scripts
