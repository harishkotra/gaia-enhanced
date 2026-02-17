package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
)

func main() {
	// MCP server on port 9090
	mcpURL, err := url.Parse("http://127.0.0.1:9090")
	if err != nil {
		log.Fatal("Failed to parse MCP URL:", err)
	}

	// Gaia nexus on port 3389 (where it actually listens)
	nexusURL, err := url.Parse("http://127.0.0.1:3389")
	if err != nil {
		log.Fatal("Failed to parse nexus URL:", err)
	}

	mcpProxy := httputil.NewSingleHostReverseProxy(mcpURL)
	nexusProxy := httputil.NewSingleHostReverseProxy(nexusURL)

	// Configure proxies to preserve headers
	mcpProxy.Director = func(req *http.Request) {
		req.URL.Scheme = mcpURL.Scheme
		req.URL.Host = mcpURL.Host
		req.Host = mcpURL.Host
	}

	nexusProxy.Director = func(req *http.Request) {
		req.URL.Scheme = nexusURL.Scheme
		req.URL.Host = nexusURL.Host
		req.Host = nexusURL.Host
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Route MCP endpoints to MCP server
		if r.URL.Path == "/health" ||
			strings.HasPrefix(r.URL.Path, "/mcp/") ||
			strings.HasPrefix(r.URL.Path, "/v1/mcp/") {
			log.Printf("Routing to MCP: %s %s", r.Method, r.URL.Path)
			mcpProxy.ServeHTTP(w, r)
			return
		}

		// Serve dashboard at root
		if r.URL.Path == "/" {
			dashboardPath := os.Getenv("HOME") + "/gaianet/dashboard/index.html"
			http.ServeFile(w, r, dashboardPath)
			return
		}

		// Serve static files from dashboard directory
		if strings.HasPrefix(r.URL.Path, "/_next/") ||
			strings.HasPrefix(r.URL.Path, "/fonts/") ||
			strings.HasPrefix(r.URL.Path, "/chatbot-ui/") ||
			(!strings.HasPrefix(r.URL.Path, "/v1/") && !strings.HasPrefix(r.URL.Path, "/admin/")) {
			dashboardPath := os.Getenv("HOME") + "/gaianet/dashboard" + r.URL.Path
			http.ServeFile(w, r, dashboardPath)
			return
		}

		// Route everything else to gaia-nexus
		log.Printf("Routing to Nexus: %s %s", r.Method, r.URL.Path)
		nexusProxy.ServeHTTP(w, r)
	})

	log.Println("MCP Gateway starting on :8080")
	log.Println("  - MCP endpoints → localhost:9090")
	log.Println("  - Static files → ~/gaianet/dashboard")
	log.Println("  - Other API traffic → localhost:3389 (gaia-nexus)")

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal("Gateway failed:", err)
	}
}
