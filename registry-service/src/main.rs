use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::collections::HashMap;
use std::env;
use std::fs;
use std::net::SocketAddr;
use std::path::Path as FsPath;
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::{info, warn};

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct McpMetadata {
    enabled: bool,
    http_url: Option<String>,
    stdio: bool,
    capabilities: Vec<String>,
    tools: Vec<Value>,
    resources: Vec<Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct NodeEntry {
    node_id: String,
    public_url: Option<String>,
    mcp: McpMetadata,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct RegistryStore {
    nodes: HashMap<String, NodeEntry>,
}

#[derive(Clone)]
struct AppState {
    data_path: String,
    store: Arc<RwLock<RegistryStore>>,
}

#[derive(Debug, Deserialize)]
struct SearchQuery {
    capabilities: Option<String>,
}

async fn health() -> Json<Value> {
    Json(json!({ "status": "ok" }))
}

async fn register_node(State(state): State<AppState>, Json(payload): Json<NodeEntry>) -> impl IntoResponse {
    if payload.node_id.trim().is_empty() {
        return (StatusCode::BAD_REQUEST, Json(json!({ "error": "node_id is required" })));
    }

    let mut store = state.store.write().await;
    store.nodes.insert(payload.node_id.clone(), payload);

    if let Err(err) = persist_store(&state.data_path, &store) {
        warn!("Failed to persist registry: {err}");
    }

    (StatusCode::OK, Json(json!({ "status": "registered" })))
}

async fn get_mcp_info(
    State(state): State<AppState>,
    Path(node_id): Path<String>,
) -> impl IntoResponse {
    let store = state.store.read().await;
    match store.nodes.get(&node_id) {
        Some(node) => (StatusCode::OK, Json(json!({ "node_id": node.node_id, "mcp": node.mcp }))),
        None => (
            StatusCode::NOT_FOUND,
            Json(json!({ "error": "node not found" })),
        ),
    }
}

async fn search_nodes(
    State(state): State<AppState>,
    Query(query): Query<SearchQuery>,
) -> impl IntoResponse {
    let required: Vec<String> = query
        .capabilities
        .unwrap_or_default()
        .split(',')
        .filter(|item| !item.trim().is_empty())
        .map(|item| item.trim().to_string())
        .collect();

    let store = state.store.read().await;
    let mut matches: Vec<Value> = Vec::new();

    for node in store.nodes.values() {
        if required.iter().all(|cap| node.mcp.capabilities.contains(cap)) {
            matches.push(json!({
                "node_id": node.node_id,
                "public_url": node.public_url,
                "mcp": {
                    "http_url": node.mcp.http_url,
                    "capabilities": node.mcp.capabilities
                }
            }));
        }
    }

    (StatusCode::OK, Json(json!({ "results": matches })))
}

fn load_store(path: &str) -> RegistryStore {
    if !FsPath::new(path).exists() {
        return RegistryStore::default();
    }

    match fs::read_to_string(path) {
        Ok(contents) => match serde_json::from_str::<RegistryStore>(&contents) {
            Ok(store) => store,
            Err(err) => {
                warn!("Failed to parse registry store {path}: {err}");
                RegistryStore::default()
            }
        },
        Err(err) => {
            warn!("Failed to read registry store {path}: {err}");
            RegistryStore::default()
        }
    }
}

fn persist_store(path: &str, store: &RegistryStore) -> Result<(), String> {
    let serialized = serde_json::to_string_pretty(store).map_err(|err| err.to_string())?;
    fs::write(path, serialized).map_err(|err| err.to_string())
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter("info")
        .init();

    let port = env::var("REGISTRY_PORT").unwrap_or_else(|_| "9100".to_string());
    let data_path = env::var("REGISTRY_DATA").unwrap_or_else(|_| "registry.json".to_string());

    let store = load_store(&data_path);
    let state = AppState {
        data_path,
        store: Arc::new(RwLock::new(store)),
    };

    let app = Router::new()
        .route("/health", get(health))
        .route("/nodes/register", post(register_node))
        .route("/nodes/:node_id/mcp/info", get(get_mcp_info))
        .route("/nodes/mcp/search", get(search_nodes))
        .with_state(state);

    let addr: SocketAddr = format!("0.0.0.0:{port}")
        .parse()
        .expect("Invalid REGISTRY_PORT value");

    info!("GaiaNet registry service listening on {addr}");

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .expect("Registry service failed");
}
