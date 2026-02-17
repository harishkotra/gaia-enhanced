# Fork Changes (gaia-enhanced)

All changes that diverge from upstream (GaiaNet-AI/gaianet-node) are tracked here.

## 2026-02-17

- Added comprehensive asset validation with upstream fallbacks:
  - `is_valid_nodeid()` - Validates nodeid.json with JSON parsing
  - `is_valid_config()` - Validates config.json structure (requires "address" and "chat" fields)
  - `is_valid_shell_script()` - Validates gaianet CLI script (checks for shebang)
  - All validators check for "Not Found" errors and HTML content
- Enhanced installer to automatically fall back to upstream (GaiaNet-AI/gaianet-node) when fork assets are invalid or missing
- Validated assets: gaianet CLI, config.json, nodeid.json, llama-api-server.wasm, frpc.toml
- Added MCP information to node dashboard:
  - Created `scripts/patch-dashboard-mcp.sh` to inject MCP documentation into dashboard HTML
  - Integrated dashboard patching into install.sh
  - MCP section positioned at the end of the dashboard (after node info, OpenAI config, and API examples)
  - Dashboard displays:
    * MCP endpoints table with live test links (dynamically updated to use node's public URL)
    * Python usage examples for MCP discovery and chat (URLs auto-updated via JavaScript)
    * cURL examples for testing MCP endpoints (URLs auto-updated via JavaScript)
    * JavaScript dynamically replaces placeholder URLs with actual node URL for seamless local/remote access
- Created comprehensive MCP examples:
  - `examples/test-mcp.sh` - Zero-dependency shell script for testing all MCP endpoints
    * Supports both local (127.0.0.1:9090) and remote testing via NODE_URL environment variable
    * Automatically detects testing mode and adjusts endpoint URLs accordingly
  - `examples/test-mcp.py` - Python script with detailed MCP integration examples
    * Supports NODE_URL environment variable for testing remote nodes
    * Intelligently handles URL construction for local vs remote testing
  - `examples/README.md` - Documentation for using and building on the examples
    * Comprehensive guide for local and remote testing scenarios
- Updated documentation:
  - Enhanced README-MCP.md with complete usage examples (Python, JavaScript, cURL)
    * Includes both local (localhost:9090) and remote (public URL) access patterns
    * Documents NODE_URL environment variable for flexible testing
  - Added MCP configuration documentation
  - Updated main README.md with MCP quick start section
  - Created `scripts/README.md` documenting utility scripts
  - All code examples now support both local development and production remote access
- **Updated MCP Remote Access Documentation (late 2026-02-17)**:
  - Created comprehensive `docs/mcp-remote-access.md` guide with multiple deployment options
  - **Architecture Clarification**: MCP server runs on localhost:9090 as a separate process from gaia-nexus
  - **Default Behavior**: MCP endpoints are accessible locally only; gaia-nexus (port 8080) doesn't route MCP paths
  - **FRP Tunnel Limitation**: Default FRP configuration only exposes port 8080 (gaia-nexus), not port 9090 (MCP server)
  - **Solutions Provided**:
    1. Local access (localhost:9090) - simplest for development
    2. SSH tunnel - secure remote testing without infrastructure changes
    3. Reverse proxy (Nginx/Caddy/Go) - production-ready public API access
    4. FRP multi-port configuration - requires FRP server support
  - Updated all documentation to accurately reflect local-only default access:
    * README-MCP.md - Clarified local vs remote access, added SSH tunnel quick start
    * Dashboard alert - Changed to "requires additional reverse proxy configuration"
    * Examples README - Simplified to focus on local testing
    * Code examples - Removed confusing remote URL logic, simplified to localhost
  - **Design Decision**: Kept MCP server as separate service (port 9090) rather than integrating into gaia-nexus
    * Rationale: Preserves upstream compatibility, allows independent MCP deployment
    * Trade-off: Requires additional proxy setup for public API access
    * Benefit: Clean separation of concerns, easier to maintain fork

## 2026-02-16

- Added README-MCP.md to document MCP fork goals and status.
- Updated installer/uninstaller branding to GaiaNet-MCP.
- Centralized gaianet-node download URLs to point at this fork via env-configurable repo settings in install.sh.
- Added registry registration on node start via the gaianet wrapper.

