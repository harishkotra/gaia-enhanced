# GaiaNet-MCP (gaia-enhanced)

This fork adds Model Context Protocol (MCP) compatibility to GaiaNet nodes while keeping the core node behavior intact. It is intended to be a clean, forward-looking fork that can evolve independently.

## Goals

- Add MCP discovery and capability metadata to nodes.
- Provide a lightweight MCP server component that can be bundled with nodes.
- Keep the install and upgrade flow familiar for existing GaiaNet operators.

## Status

Phase 0 (fork identity + scaffolding) is in progress. See FORK-CHANGES.md for a running list of divergences.

## Installer Source

The installer now defaults to this fork's GitHub releases. If you need to point to a different owner or repo, set:

- GAIA_ENHANCED_REPO_OWNER
- GAIA_ENHANCED_REPO_NAME

Example:

```bash
GAIA_ENHANCED_REPO_OWNER=your-org GAIA_ENHANCED_REPO_NAME=gaia-enhanced ./install.sh
```

## Registry Integration

By default, the gaianet wrapper attempts to register MCP metadata to a registry service at `http://127.0.0.1:9100`. Override the target with:

- REGISTRY_URL

Example:

```bash
REGISTRY_URL=https://registry.example.com ./gaianet start
```

## Upstream

This fork started from GaiaNet-AI/gaianet-node. Upstream development appears inactive; we will periodically cherry-pick fixes if needed.
