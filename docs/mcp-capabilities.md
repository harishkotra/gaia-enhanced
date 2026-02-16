# MCP Capabilities for GaiaNet Nodes

This document lists the initial MCP capabilities a node can advertise.

## Capability Catalog (v1)

- chat
  - Chat completion style interactions.
- embeddings
  - Vector embedding generation.
- knowledge_search
  - RAG-style retrieval over local content.
- node_info
  - Node metadata and health status.

## Tool Shapes (high level)

- chat.complete
  - Input: messages[], params
  - Output: message

- embeddings.create
  - Input: text[]
  - Output: vectors[]

- knowledge.search
  - Input: query, top_k
  - Output: results[]

- node.info
  - Input: none
  - Output: node_version, servers, health

## Notes

- Tool naming mirrors existing API concepts to reduce mapping complexity.
- Additional tools can be added per node based on custom config.
