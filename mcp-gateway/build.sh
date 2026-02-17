#!/bin/bash

set -e

VERSION="${1:-0.1.0}"
DIST_DIR="dist"

echo "Building MCP Gateway v${VERSION} for multiple platforms..."

mkdir -p "$DIST_DIR"

# Build for macOS (x86_64)
echo "Building for macOS x86_64..."
GOOS=darwin GOARCH=amd64 go build -o "$DIST_DIR/mcp-gateway-darwin-x86_64" main.go
cd "$DIST_DIR"
tar -czf "mcp-gateway-darwin-x86_64.tar.gz" "mcp-gateway-darwin-x86_64"
rm "mcp-gateway-darwin-x86_64"
cd ..

# Build for macOS (arm64)
echo "Building for macOS arm64..."
GOOS=darwin GOARCH=arm64 go build -o "$DIST_DIR/mcp-gateway-darwin-arm64" main.go
cd "$DIST_DIR"
tar -czf "mcp-gateway-darwin-arm64.tar.gz" "mcp-gateway-darwin-arm64"
rm "mcp-gateway-darwin-arm64"
cd ..

# Build for Linux (x86_64)
echo "Building for Linux x86_64..."
GOOS=linux GOARCH=amd64 go build -o "$DIST_DIR/mcp-gateway-linux-x86_64" main.go
cd "$DIST_DIR"
tar -czf "mcp-gateway-linux-x86_64.tar.gz" "mcp-gateway-linux-x86_64"
rm "mcp-gateway-linux-x86_64"
cd ..

# Build for Linux (arm64)
echo "Building for Linux arm64..."
GOOS=linux GOARCH=arm64 go build -o "$DIST_DIR/mcp-gateway-linux-arm64" main.go
cd "$DIST_DIR"
tar -czf "mcp-gateway-linux-arm64.tar.gz" "mcp-gateway-linux-arm64"
rm "mcp-gateway-linux-arm64"
cd ..

echo "✅ Build complete! Archives available in $DIST_DIR/"
ls -lh "$DIST_DIR"/*.tar.gz
