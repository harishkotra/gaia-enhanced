# Scripts Directory

Utility scripts for GaiaNet-MCP enhanced fork.

## Available Scripts

### package-mcp-server.sh

Packages the MCP server binary for distribution. Creates platform-specific tarballs ready for GitHub releases.

**Usage:**
```bash
./scripts/package-mcp-server.sh
```

**Output:**
- `dist/gaianet-mcp-server-{platform}-{arch}.tar.gz`

### patch-dashboard-mcp.sh

Patches the GaiaNet node dashboard to include MCP information and usage examples **at the end of the page**, after node information.

**Usage:**
```bash
# Patch default installation
./scripts/patch-dashboard-mcp.sh

# Patch specific dashboard
./scripts/patch-dashboard-mcp.sh /path/to/dashboard/index.html
```

**What it does:**
- Adds MCP endpoints section with links to test endpoints (at the end, after node info)
- Includes Python code examples for MCP usage
- Includes cURL examples for testing
- Creates backup of original dashboard as `index.html.backup`
- Skips patching if MCP section already exists

**Note:** This script is automatically called during `gaianet` installation when the dashboard is downloaded/updated.
